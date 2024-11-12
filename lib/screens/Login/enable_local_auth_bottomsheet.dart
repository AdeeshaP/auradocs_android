import 'package:flutter/material.dart';

class EnableLocalAuthModalBottomSheet extends StatelessWidget {
  final void Function() action;

  EnableLocalAuthModalBottomSheet({Key? key, required this.action})
      : super(key: key);

  static Color primaryColor = Color.fromARGB(255, 237, 172, 10);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.key,
                size: 90,
                color: primaryColor,
              ),
              Icon(
                Icons.fingerprint_outlined,
                size: 100,
                color: primaryColor,
              ),
              Icon(
                Icons.lock_person,
                size: 90,
                color: primaryColor,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Do you want to enable biometric login?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textScaler: TextScaler.linear(1),
          ),
          SizedBox(height: 5),
          Text(
              'The next time you log in, you will not be prompted for your login credentials.',
              textScaler: TextScaler.linear(1),
              textAlign: TextAlign.center),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text(
              "Yes",
              style: TextStyle(
                color: Colors.white,
              ),
              textScaler: TextScaler.linear(1),
            ),
            onPressed: () {
              action();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: primaryColor,
              textStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
              child: Text(
                "No, thanks!",
                style: TextStyle(color: Colors.black54),
                textScaler: TextScaler.linear(1),
              ),
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ))
        ],
      ),
    );
  }
}
