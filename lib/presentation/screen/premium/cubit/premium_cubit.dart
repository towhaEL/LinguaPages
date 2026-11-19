import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/domain/entity/premium/premium_entitlement_entity.dart';
import 'package:lingua_pages/domain/repository/premium/premium_entitlement_repository.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:logger/logger.dart';

/// App-wide premium entitlement, from either the yearly or lifetime plan.
///
/// The cached entitlement decides immediately, so the reader never waits on
/// the store and an offline user keeps what they bought. The store is then
/// asked at launch and whenever the app returns to the foreground; only a
/// definite "not owned" (a refund or a lapsed subscription) locks again.
///
/// A lifetime unlock is cached for good. A yearly subscription is cached for
/// [subscriptionGrace] past its last check, so a subscription that lapses
/// while the device stays offline does not unlock forever.
@lazySingleton
class PremiumCubit extends Cubit<PremiumState> {
  /// How long a yearly subscription stays unlocked without reaching the
  /// store.
  static const subscriptionGrace = Duration(days: 14);

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
  Future<void>? _verifying;

  Future<void> start() async {
    if (!_flags.premiumEnabled || _events != null) return;
    // Listen first: purchases finished while the app was closed arrive here.
    _events = _billing.events.listen(_onEvent);
    final cached = await _entitlements.getCurrent();
    if (isClosed) return;
    emit(state.copyWith(unlocked: cached.isActiveAt(_clock())));
    await Future.wait([refresh(), loadProducts()]);
  }

  /// Asks the store again, for example when the app returns to the
  /// foreground. Calls made while a check is running share it.
  Future<void> refresh() {
    if (!_flags.premiumEnabled || _events == null) return Future.value();
    return _verifying ??= _verify().whenComplete(() => _verifying = null);
  }

  /// A fresh start for the offer: the last attempt's message is cleared,
  /// and prices the store could not give earlier are asked for again.
  Future<void> paywallOpened() async {
    if (!state.isBusy && state.status != PremiumStatus.idle) {
      emit(state.copyWith(status: PremiumStatus.idle));
    }
    if (_flags.premiumEnabled && state.products.isEmpty) await loadProducts();
  }

  Future<void> loadProducts() async {
    final products = await _billing.loadProducts();
    if (isClosed || products.isEmpty) return;
    emit(state.copyWith(products: products));
  }

  Future<void> buy(PremiumPlan plan) async {
    if (state.isBusy) return;
    emit(state.copyWith(status: PremiumStatus.purchasing));
    try {
      await _billing.buy(plan);
    } on Object catch (error) {
      _logger.w('Purchase could not start', error: error);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: state.products.containsKey(plan)
              ? PremiumStatus.failed
              : PremiumStatus.storeUnavailable,
        ),
      );
    }
  }

  Future<void> restore() async {
    if (state.isBusy) return;
    emit(state.copyWith(status: PremiumStatus.restoring));
    final owned = await _billing.ownedPlans();
    if (isClosed) return;
    if (owned == null) {
      emit(state.copyWith(status: PremiumStatus.storeUnavailable));
    } else if (owned.isEmpty) {
      emit(state.copyWith(status: PremiumStatus.nothingToRestore));
    } else {
      await _grant(PremiumEntitlementSource.restored, _bestOf(owned));
      if (!isClosed) emit(state.copyWith(status: PremiumStatus.restored));
    }
  }

  Future<void> _verify() async {
    final owned = await _billing.ownedPlans();
    if (isClosed) return;
    final cached = await _entitlements.getCurrent();
    if (isClosed) return;
    if (owned == null) {
      // Offline: the cache decides, and a subscription past its grace
      // locks.
      emit(state.copyWith(unlocked: cached.isActiveAt(_clock())));
    } else if (owned.isEmpty) {
      await _entitlements.clear();
      if (!isClosed) emit(state.copyWith(unlocked: false));
    } else {
      await _grant(
        cached.isActiveAt(_clock())
            ? cached.source
            : PremiumEntitlementSource.restored,
        _bestOf(owned),
      );
    }
  }

  static PremiumPlan _bestOf(Set<PremiumPlan> owned) =>
      owned.contains(PremiumPlan.lifetime)
      ? PremiumPlan.lifetime
      : PremiumPlan.yearly;

  Future<void> _onEvent(BillingEvent event) async {
    if (isClosed) return;
    switch (event) {
      case BillingPurchased(:final plan, :final restored):
        await _grant(
          restored
              ? PremiumEntitlementSource.restored
              : PremiumEntitlementSource.purchase,
          plan,
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

  Future<void> _grant(PremiumEntitlementSource source, PremiumPlan plan) async {
    final now = _clock();
    await _entitlements.save(
      PremiumEntitlementEntity(
        isPremium: true,
        source: source,
        expiresAt: plan == PremiumPlan.lifetime
            ? null
            : now.add(subscriptionGrace),
        lastVerifiedAt: now,
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
