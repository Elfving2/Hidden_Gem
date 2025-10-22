import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hidden_gem/screens/friends_view.dart';
import 'package:hidden_gem/screens/map_screen.dart';
import 'package:hidden_gem/screens/profile_screen.dart';
import 'package:hidden_gem/screens/social_media_feed_view.dart';

/*
  The bottom navigations bar is the "heart" of the program it is the first thing that loads when
  you login / are logged in here you can navigate to the different views, navigationbar is always
  loaded and by clicking a different icon you destroy and load another.

*/
class BottomNavigationbar extends StatelessWidget {
  const BottomNavigationbar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.map), label: "Map"),
            NavigationDestination(icon: Icon(Icons.share), label: "Feed"),
            NavigationDestination(icon: Icon(Icons.group), label: "Friends"),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 3.obs;
  final screens = [
    MapPage(),
    const SocialMediaFeed(),
    FriendsView(),
    const ProfileScreen(),
  ];
}
