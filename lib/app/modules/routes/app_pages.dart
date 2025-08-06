import 'package:get/get.dart';
import '../auth/views/login_view.dart';
import '../home/views/home_view.dart';
// import other views as needed

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
    ),
    // Add other routes here
    GetPage(
      name: Routes.home,
      page: () => HomeView(),
    ),
  ];
}
