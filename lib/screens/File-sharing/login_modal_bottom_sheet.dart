import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';

class LoginModalBottomSheet extends StatelessWidget {
  LoginModalBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 10),
          Text(
            'You have not logged in yet. Please login first.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.isMobileSmall(context)
                  ? 15
                  : Responsive.isMobileLarge(context) ||
                          Responsive.isMobileMedium(context)
                      ? 17
                      : 19,
            ),
            textScaler: TextScaler.linear(1),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          Text(
            'Without loggin in, you cannot share any documents.',
            style: TextStyle(
              fontSize: Responsive.isMobileSmall(context)
                  ? 15
                  : Responsive.isMobileLarge(context) ||
                          Responsive.isMobileMedium(context)
                      ? 17
                      : 19,
            ),
            textScaler: TextScaler.linear(1),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(
              Icons.arrow_circle_right,
              color: Colors.white,
            ),
            label: Text(
              "Go to App",
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.isMobileSmall(context)
                    ? 14.5
                    : Responsive.isMobileLarge(context) ||
                            Responsive.isMobileMedium(context)
                        ? 16
                        : 18,
              ),
              textScaler: TextScaler.linear(1),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LandingScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Color.fromARGB(255, 237, 172, 10),
                textStyle: TextStyle(
                    fontSize: Responsive.isMobileSmall(context)
                        ? 20
                        : Responsive.isMobileLarge(context) ||
                                Responsive.isMobileMedium(context)
                            ? 22
                            : 25,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
