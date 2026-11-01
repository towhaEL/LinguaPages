import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/domain/entity/premium/premium_entitlement_entity.dart';
import 'package:lingua_pages/domain/repository/premium/premium_entitlement_repository.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:logger/logger.dart';

/// App-wide premium appearance entitlement.
///
/// The cached entitlement decides immediately, so the reader never waits on
/// the store and an offline user keeps what they bought. The store is then
/// asked once per launch; only a definite "not owned" (a refund) locks again.
@lazySingleton
class PremiumCubit extends Cubit<PremiumState> {
  PremiumCubit(
    this._billing,
    this._entitlements,
    this._flags,
    this._logger, {
    @ignoreParam DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(PremiumState(unlocked: !_flags.premiumEnabled));

  final BillingService _billing;
  final PremiumEntitlementRepository _entitlements;
  final AppFeatureFlags _flags;
  final Logger _logger;
  final DateTime Function() _clock;
  StreamSubscription<BillingEvent>? _events;

  Future<void> start() async {
    if (!_flags.premiumEnabled || _events != null) return;
    // Listen first: purchases finished while the app was closed arrive here.
    _events = _billing.events.listen(_onEvent);
    final cached = await _entitlements.getCurrent();
    if (isClosed) return;
    emit(state.copyWith(unlocked: cached.isActive));
    await Future.wait([_verify(), loadProduct()]);
  }

  Future<void> loadProduct() async {
    final product = await _billing.loadProduct();
    if (isClosed || product == null) return;
    emit(state.copyWith(product: product));
  }

  Future<void> buy() async {
    if (state.isBusy) return;
    emit(state.copyWith(status: PremiumStatus.purchasing));
    try {
      await _billing.buy();
    } on Object catch (error) {
      _logger.w('Purchase could not start', error: error);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: state.product == null
              ? PremiumStatus.storeUnavailable
              : PremiumStatus.failed,
        ),
      );
    }
  }

  Future<void> restore() async {
    if (state.isBusy) return;
    emit(state.copyWith(status: PremiumStatus.restoring));
    final owned = await _billing.ownsPremium();
    if (isClosed) return;
    switch (owned) {
      case null:
        emit(state.copyWith(status: PremiumStatus.storeUnavailable));
      case true:
        await _grant(PremiumEntitlementSource.restored);
        emit(state.copyWith(status: PremiumStatus.restored));
      case false:
        emit(state.copyWith(status: PremiumStatus.nothingToRestore));
    }
  }

  Future<void> _verify() async {
    final owned = await _billing.ownsPremium();
    if (isClosed || owned == null) return;
    if (owned) {
      final cached = await _entitlements.getCurrent();
      await _grant(
        cached.isActive ? cached.source : PremiumEntitlementSource.restored,
      );
    } else {
      await _entitlements.clear();
      if (!isClosed) emit(state.copyWith(unlocked: false));
    }
  }

  Future<void> _onEvent(BillingEvent event) async {
    if (isClosed) return;
    switch (event) {
      case BillingPurchased(:final restored):
        await _grant(
          restored
              ? PremiumEntitlementSource.restored
              : PremiumEntitlementSource.purchase,
        );
        if (!isClosed) {
          emit(
            state.copyWith(
              status: restored
                  ? PremiumStatus.restored
                  : PremiumStatus.purchased,
            ),
          );
        }
      case BillingPending():
        emit(state.copyWith(status: PremiumStatus.pending));
      case BillingCanceled():
        emit(state.copyWith(status: PremiumStatus.idle));
      case BillingFailed(:final message):
        _logger.w('Purchase failed: $message');
        emit(state.copyWith(status: PremiumStatus.failed));
    }
  }

  Future<void> _grant(PremiumEntitlementSource source) async {
    await _entitlements.save(
      PremiumEntitlementEntity(
        isPremium: true,
        source: source,
        lastVerifiedAt: _clock(),
      ),
    );
    if (!isClosed) emit(state.copyWith(unlocked: true));
  }

  @override
  Future<void> close() async {
    await _events?.cancel();
    return super.close();
  }
}
