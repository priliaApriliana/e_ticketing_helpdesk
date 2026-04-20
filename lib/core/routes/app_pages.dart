import 'package:get/get.dart';
import 'package:e_ticketing_helpdesk/features/splash/presentation/pages/splash_page.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/pages/login_page.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/pages/register_page.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/providers/auth_provider.dart';
import 'package:e_ticketing_helpdesk/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:e_ticketing_helpdesk/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/pages/ticket_list_page.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/pages/ticket_detail_page.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:e_ticketing_helpdesk/features/profile/presentation/pages/profile_page.dart';
import 'package:e_ticketing_helpdesk/features/profile/presentation/providers/profile_provider.dart';
import 'package:e_ticketing_helpdesk/features/notification/presentation/pages/notification_page.dart';
import 'package:e_ticketing_helpdesk/features/notification/presentation/providers/notification_provider.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() { Get.put(AuthProvider()); }),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() { Get.put(AuthProvider()); }),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.put(DashboardProvider());
        Get.put(TicketProvider());
      }),
    ),
    GetPage(
      name: Routes.ticketList,
      page: () => const TicketListScreen(),
      binding: BindingsBuilder(() { Get.put(TicketProvider()); }),
    ),
    GetPage(
      name: Routes.ticketDetail,
      page: () => const TicketDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TicketProvider(), fenix: true);
      }),
    ),
    GetPage(
      name: Routes.ticketCreate,
      page: () => const CreateTicketScreen(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() { Get.lazyPut(() => ProfileProvider(), fenix: true); }),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationPage(),
      binding: BindingsBuilder(() { Get.lazyPut(() => NotificationProvider(), fenix: true); }),
    ),
  ];
}












