import 'package:auto_route/auto_route.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(
      page: DashboardRoute.page,
      children: [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: SettingsRoute.page),
      ],
    ),
    AutoRoute(page: ReaderRoute.page),
  ];
}
