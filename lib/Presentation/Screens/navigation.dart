import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'entry_output.dart';
import 'home.dart';
import 'installment_cheque.dart';
import 'log.dart';
import 'profile.dart';

class NavigationScreen extends StatefulWidget {
  static String routeName = '/navigation';

  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(initialIndex: 0, length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeScreen(),
            EntryScreen(),
            InstallmentScreen(),
            LogScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
            tabController.animateTo(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Iconsax.home_2_outline),
              activeIcon: const Icon(Iconsax.home_2_bold),
              title: const Text(
                'خانه',
                style: TextStyle(fontFamily: 'Pinar', fontSize: 12),
              ),
              selectedColor: Colors.red,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Iconsax.arrow_swap_outline),
              activeIcon: const Icon(Iconsax.arrow_swap_bold),
              title: const Text(
                'دخل و خرج',
                style: TextStyle(fontFamily: 'Pinar', fontSize: 11),
              ),
              selectedColor: Colors.teal,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Iconsax.card_pos_outline),
              activeIcon: const Icon(Iconsax.card_pos_bold),
              title: const Text(
                'چک و قسط',
                style: TextStyle(fontFamily: 'Pinar', fontSize: 11),
              ),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Iconsax.note_1_outline),
              activeIcon: const Icon(Iconsax.note_1_bold),
              title: const Text(
                'فعالیت ها',
                style: TextStyle(fontFamily: 'Pinar', fontSize: 11),
              ),
              selectedColor: Colors.orange,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Iconsax.user_outline),
              activeIcon: const Icon(Iconsax.user_bold),
              title: const Text(
                'حساب کاربری',
                style: TextStyle(fontFamily: 'Pinar', fontSize: 11),
              ),
              selectedColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
