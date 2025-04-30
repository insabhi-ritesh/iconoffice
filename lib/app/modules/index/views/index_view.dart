import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/profile_page/views/profile_page_view.dart';

import '../../home/views/home_view.dart';
import '../controllers/index_controller.dart';


class IndexView extends StatefulWidget {
  const IndexView({Key? key}) : super(key: key);

  @override
  State<IndexView> createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  IndexController controller = Get.find<IndexController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: redirectToPages(),
        bottomNavigationBar: Obx(
          () => NavigationBarTheme(
            data:
                const NavigationBarThemeData(indicatorColor: Colors.transparent),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NavigationBar(
                  backgroundColor: Colors.white,
                  animationDuration: const Duration(seconds: 2),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  height: 50,
                  destinations: [
                    NavigationDestination(
                      icon: MenuItem(
                        svgUrl: "assets/icons/home.svg",
                        label: "Home",
                        isSelected: controller.currentIndex.value == 0,
                      ),
                      label: "",
                    ),
                    NavigationDestination(
                      icon: MenuItem(
                        svgUrl: "assets/icons/profile.svg",
                        label: "Profile",
                        isSelected: controller.currentIndex.value == 1,
                      ),
                      label: "",
                    ),
                    // NavigationDestination(
                    //   icon: MenuItem(
                    //     svgUrl: "assets/icons/profile.svg",
                    //     label: "Profile",
                    //     isSelected: controller.currentIndex.value == 2,
                    //   ),
                    //   label: "",
                    // ),
                  ],
                  selectedIndex: controller.currentIndex.value,
                  onDestinationSelected: (index) {
                    controller.currentIndex.value = index;
                    controller.pageController.jumpToPage(index);
                  },
                ),
              ],
            ),
          ),
        ),
      
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key,
    required this.svgUrl,
    required this.label,
    required this.isSelected,
    this.background = false,
  }) : super(key: key);

  final String svgUrl, label;
  final bool isSelected, background;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        background
            ? Container(
                padding: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                    color: Colors.grey, shape: BoxShape.circle),
                child: SvgPicture.asset(
                  svgUrl,
                  color: Colors.white,
                  height: 20,
                ),
              )
            : SvgPicture.asset(
                svgUrl,
                color: isSelected ? Colors.red : Colors.black54,
                height: 20,
              ),
        const SizedBox(
          height: 5,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.black54,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        )
      ],
    );
  }
}

class redirectToPages extends StatelessWidget {
  const redirectToPages({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GetBuilder<IndexController>(
        builder: (con) {
          return PageView(
            physics: const ScrollPhysics(
              parent: NeverScrollableScrollPhysics(),
            ),
            controller: con.pageController,
            children: [
              HomeView(),
              const ProfilePageView(),
            ],
          );
        },
      ),
    );
  }
}
