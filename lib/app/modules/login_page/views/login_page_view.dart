import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import '../controllers/login_page_controller.dart';
import 'components/remember_me.dart';

class LoginPageView extends GetView<LoginPageController> {
  const LoginPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColorList.AppBackGroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with elevation
                // SizedBox(
                //   width: 200,
                //   height: 200,
                //   child: Material(
                //     elevation: 20.0,
                //     borderRadius: BorderRadius.circular(20),
                //     shadowColor: Colors.black45,
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(20),
                //       child: Image.asset("assets/images/logo.jpeg"),
                //     ),
                //   ),
                // ),

                AnimatedBuilder(
                  animation: controller.animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -controller.animation.value),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Material(
                      elevation: 20.0,
                      shadowColor: AppColorList.MainShadow,
                      borderRadius: BorderRadius.circular(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset('assets/images/logo.jpeg'),
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 10),

                Text(
                  "Welcome to Icon Office Mobile App",
                  style: TextStyle(
                    fontSize: AppFontSize.size1,
                    fontWeight: AppFontWeight.font2,
                    color: AppColorList.AppText
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Username field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Username",
                    style: TextStyle(
                      fontWeight: AppFontWeight.font2,
                      fontSize: AppFontSize.size3,
                      color: AppColorList.AppText
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.UserName,
                  decoration: InputDecoration(
                    labelText: 'Enter your username',
                    labelStyle: TextStyle(
                      color: AppColorList.AppText,
                      fontSize: AppFontSize.size3,
                      fontWeight: AppFontWeight.font1
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    
                    // filled: true,
                    // fillColor: AppColorList.AppTextField,
                  ),
                ),

                const SizedBox(height: 10),

                // Password field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      fontWeight: AppFontWeight.font2,
                      fontSize: AppFontSize.size3,
                      color: AppColorList.AppText
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.Password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                    labelStyle: TextStyle(
                      color: AppColorList.AppText,
                      fontSize: AppFontSize.size3,
                      fontWeight: AppFontWeight.font1
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // filled: true,
                    // fillColor: AppColorList.AppTextField,
                  ),
                ),
                const SizedBox(height: 10,),
                RememberMeCheckbox(controller: controller,),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Row(
                //     children: [
                //       Container(
                //         height: 20,
                //         width: 20,
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           border: Border.all(),
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //       ),
                //       const SizedBox(width: 10,),
                //       const Text('Remember me', style: TextStyle(fontSize: 16),),
                //     ],
                //   ),
                // ),

                const SizedBox(height: 40),

                // Login button
                Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            AppColorList.AppButtonColor,
                          ),
                          shadowColor: MaterialStateProperty.all(
                            AppColorList.MainShadow, // Or any color you want for the shadow
                          ),
                          elevation: MaterialStateProperty.all(12)
                        ),
                        onPressed: () {
                          if (controller.UserName.text.isNotEmpty && controller.Password.text.isNotEmpty) {
                            controller.login(
                              controller.UserName.text.trim(), 
                              controller.Password.text.trim().toString(),
                              controller.rememberMe.value,
                              );
                          } else {
                            Get.snackbar("Error", "Please enter both username and password.");
                          }
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: AppFontSize.size1,
                            fontWeight: AppFontWeight.font2,
                            color: AppColorList.WhiteText,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}