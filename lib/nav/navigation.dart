import 'package:attendance_app/ui/auth/login_screen.dart';
import 'package:go_router/go_router.dart';


class Navigation {
  static const initial = "/";
  static final routes = [
    GoRoute(
      path: "/",
      name: Screen.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    // GoRoute(
    //   path: "/add",
    //   name: Screen.addTodo.name,
    //   builder: (context, state) => const AddTodoScreen(),
    // ),
    // GoRoute(
    //   path: "/update/:id",
    //   name: Screen.updateTodo.name,
    //   builder:
    //       (context, state) => EditTodoScreen(id: state.pathParameters["id"]!),
    // ),
  ];
}

enum Screen { login}
