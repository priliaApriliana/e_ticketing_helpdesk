import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/features/splash/presentation/pages/splash_page.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/pages/login_page.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/pages/register_page.dart';
import 'package:e_ticketing_helpdesk/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/pages/ticket_list_page.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/pages/ticket_detail_page.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:e_ticketing_helpdesk/features/profile/presentation/pages/profile_page.dart';
import 'package:e_ticketing_helpdesk/features/notification/presentation/pages/notification_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.login, page: () => const LoginScreen()),
    GetPage(name: Routes.register, page: () => const RegisterScreen()),
    GetPage(name: Routes.dashboard, page: () => const DashboardScreen()),
    GetPage(name: Routes.ticketList, page: () => const TicketListScreen()),
    GetPage(name: Routes.ticketDetail, page: () => const TicketDetailScreen()),
    GetPage(name: Routes.ticketCreate, page: () => const CreateTicketScreen()),
    GetPage(name: Routes.profile, page: () => const ProfileScreen()),
    GetPage(name: Routes.notifications, page: () => const NotificationPage()),
  ];
}
