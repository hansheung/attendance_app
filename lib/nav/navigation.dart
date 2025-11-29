import 'package:attendance_app/ui/admin/addsite_screen.dart';
import 'package:attendance_app/ui/admin/adminhome_screen.dart';
import 'package:attendance_app/ui/admin/editsite_screen.dart';
import 'package:attendance_app/ui/admin/exportattendance_screen.dart';
import 'package:attendance_app/ui/admin/site_screen.dart';
import 'package:attendance_app/ui/auth/login_screen.dart';
import 'package:attendance_app/ui/auth/register_screen.dart';
import 'package:attendance_app/ui/auth/forgot_password_screen.dart';
import 'package:attendance_app/ui/pages/splash_scree.dart';
import 'package:attendance_app/ui/user/userhome_screen.dart';
import 'package:go_router/go_router.dart';

class Navigation {
  static const initial = "/";
  static final routes = [
    GoRoute(
      path: "/",
      name: Screen.splash.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: "/login",
      name: Screen.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: "/register",
      name: Screen.register.name,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: "/forgot",
      name: Screen.forgot.name,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: "/user",
      name: Screen.user.name,
      builder: (context, state) => const UserhomeScreen(),
    ),
    GoRoute(
      path: "/admin",
      name: Screen.admin.name,
      builder: (context, state) => const AdminHomeScreen(),
    ),

    GoRoute(
      path: "/site",
      name: Screen.site.name,
      builder: (context, state) => const SiteScreen(),
    ),

    GoRoute(
      path: "/site/add",
      name: Screen.addSite.name,
      builder:
          (context, state) => const AddSiteScreen(),
    ),


    GoRoute(
      path: "/site/update/:id",
      name: Screen.updateSite.name,
      builder:
          (context, state) => EditSiteScreen(id: state.pathParameters["id"]!),
    ),

    GoRoute(
      path: "/export",
      name: Screen.export.name,
      builder:
          (context, state) => const ExportAttendanceScreen(),
    ),
  ];
}

enum Screen { splash, login, register, forgot, user, admin, site, addSite, updateSite, export }
