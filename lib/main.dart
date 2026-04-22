import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/ticket_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/notification/presentation/providers/notification_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/ticket/presentation/providers/ticket_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  timeago.setLocaleMessages('id', timeago.IdMessages());

  final authService = AuthService();
  final ticketService = TicketService();
  final notificationService = NotificationService();

  Get.put<AuthService>(authService, permanent: true);
  Get.put<TicketService>(ticketService, permanent: true);
  Get.put<NotificationService>(notificationService, permanent: true);

  final authProvider = AuthProvider();
  final dashboardProvider = DashboardProvider();
  final ticketProvider = TicketProvider();
  final profileProvider = ProfileProvider();
  final notificationProvider = NotificationProvider();

  Get.put<AuthProvider>(authProvider, permanent: true);
  Get.put<DashboardProvider>(dashboardProvider, permanent: true);
  Get.put<TicketProvider>(ticketProvider, permanent: true);
  Get.put<ProfileProvider>(profileProvider, permanent: true);
  Get.put<NotificationProvider>(notificationProvider, permanent: true);

  dashboardProvider.onInit();
  ticketProvider.onInit();
  notificationProvider.onInit();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: authService),
        Provider.value(value: ticketService),
        Provider.value(value: notificationService),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: dashboardProvider),
        ChangeNotifierProvider.value(value: ticketProvider),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}