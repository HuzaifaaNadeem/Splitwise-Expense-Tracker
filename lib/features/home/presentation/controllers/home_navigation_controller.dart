import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_navigation_controller.g.dart';

@riverpod
class HomeNavigationController extends _$HomeNavigationController {
  static const int destinationCount = 4;

  @override
  int build() {
    return 0;
  }

  void selectDestination(int index) {
    if (index < 0 || index >= destinationCount) {
      return;
    }

    state = index;
  }
}
