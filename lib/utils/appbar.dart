import 'package:app/main.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: Colors.black,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (Route<dynamic> route) => false);
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
                    const Flexible(
                      child: Text(
                        'User',
                        textScaleFactor: 0.7,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
