import 'package:app/main.dart';
import 'package:app/model/appUser.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onTap;
  final Icon showIcon;

  const CustomAppBar({Key? key, required this.onTap, required this.showIcon})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 139, 175, 202),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.popUntil(context, ModalRoute.withName('/home'));
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => MainScreen()),
              // );
            },
            child: const Text(
              'CapSnap',
              textScaleFactor: 1.2,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  onTap();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    showIcon,
                    Flexible(
                      child: Obx(
                        () => Text(
                          AppUser.first_name.value,
                          textScaleFactor: 0.7,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (AppUser.credit.value > 0)
                      Flexible(
                        child: Obx(
                          () => Text(
                            AppUser.credit.value.toString(),
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
