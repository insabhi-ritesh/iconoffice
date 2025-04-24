import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';

import '../controllers/update_password_controller.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  const UpdatePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorList.AppColor,
      appBar: AppBar(
        backgroundColor: AppColorList.AppButtonColor,
        title: const Text('Update Password',
        style: TextStyle(
          fontSize: AppFontSize.size1,
          fontWeight: AppFontWeight.font4
        ),
        ),
        // centerTitle: true,
      ),
      body: Stack(
        children:[
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text('Old Password',
                          style: TextStyle(
                            fontSize: AppFontSize.size4,
                            fontWeight: AppFontWeight.font3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: controller.oldPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          ),
                          labelText: 'Old Password',
                          labelStyle: TextStyle(fontSize: AppFontSize.size4),
                          // suffixIcon: IconButton(
                          //   icon: Icon(Icons.visibility),
                          //   onPressed: () {},
                          // ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text('New Password',
                          style: TextStyle(
                            fontSize: AppFontSize.size4,
                            fontWeight: AppFontWeight.font3,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: controller.newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          ),
                          labelText: 'New Password',
                          labelStyle: TextStyle(fontSize: AppFontSize.size4),
                          // suffixIcon: IconButton(
                          //   icon: Icon(Icons.visibility),
                          //   onPressed: () {},
                          // ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Confirm Password',
                      style: TextStyle(
                        fontSize: AppFontSize.size4,
                        fontWeight: AppFontWeight.font3,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: controller.confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          ),
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(fontSize: AppFontSize.size4),
                          // suffixIcon: IconButton(
                          //   icon: Icon(Icons.visibility),
                          //   onPressed: () {},
                          // ),        
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.changePassword();
                        },
                        child: Text('Submit',
                          style: TextStyle(
                            fontSize: AppFontSize.size3,
                            fontWeight: AppFontWeight.font3,
                            color: AppColorList.AppTextColor
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorList.AppButtonColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}
