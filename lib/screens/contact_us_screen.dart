import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  ContactUsScreen();
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ccontact@auradot.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Add Subject',
        'body': 'Write something...!',
      }),
    );

    launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context)
              ? 40
              : Responsive.isMobileLarge(context)
                  ? 50
                  : Responsive.isTabletPortrait(context)
                      ? 80
                      : 90,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "Contact Us",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              textStyle: Theme.of(context).textTheme.headlineMedium,
              fontSize: Responsive.isMobileSmall(context)
                  ? 20
                  : Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 23
                      : Responsive.isTabletPortrait(context)
                          ? 35
                          : 40,
              fontWeight: FontWeight.w700,
              color: Colors.amber[600],
            ),
            textScaler: TextScaler.linear(1),
          ),

          // LEADING ICON BACK BUTTON
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: Responsive.isMobileSmall(context)
                    ? 21
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 25
                        : Responsive.isTabletPortrait(context)
                            ? 31
                            : 35,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background_three.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(height: 5),
                Image.asset(
                  "assets/images/auradocs_logo-transparent.png",
                  scale: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 1
                      : 0.7,
                  width: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? size.width * 0.8
                      : size.width * 0.9,
                  height: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? size.width * 0.28
                      : size.width * 0.2,
                ),
                Text(
                  "Version " + "2.7.0",
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.displayMedium,
                    fontSize: Responsive.isMobileSmall(context)
                        ? 18
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 20
                            : 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                  textScaler: TextScaler.linear(1),
                ),
                SizedBox(height: 30),
                Text(
                  "If you have any questions, please contact us on via email, and we'll respond as soon as possible. "
                  "Your feedback matters to us and will allow us to improve our service to you. We would be grateful"
                  " if you could take a few minutes to send your comments.",
                  style: TextStyle(
                    // textStyle: Theme.of(context).textTheme.headlineMedium,
                    fontSize: Responsive.isMobileSmall(context)
                        ? 15
                        : Responsive.isMobileMedium(context)
                            ? 15.5
                            : Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 23
                                    : 25,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textScaler: TextScaler.linear(1),
                  textAlign: TextAlign.justify,
                ),

                SizedBox(
                    height: Responsive.isMobileSmall(context)
                        ? 30
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 30
                            : 50), // GridView(

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Icon(
                        Icons.location_on,
                        size: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 30
                            : 45,
                        color: Colors.amber[600],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: InkWell(
                        onTap: () {
                          // _sendEmail();
                        },
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: "Head Office\n",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: Responsive.isMobileSmall(context)
                                    ? 13
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 15
                                        : Responsive.isTabletPortrait(context)
                                            ? 24
                                            : 27,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Auradot (pvt) Ltd,\n410/118, Bauddhaloka Mawatha, Colombo 00700",
                              style: TextStyle(
                                height: 1.7,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: Responsive.isMobileSmall(context)
                                    ? 13
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 15
                                        : Responsive.isTabletPortrait(context)
                                            ? 24
                                            : 27,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                    height: Responsive.isTabletLandscape(context) ||
                            Responsive.isTabletPortrait(context)
                        ? 50
                        : 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Icon(
                        Icons.email,
                        size: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 30
                            : 45,
                        color: Colors.blue[800],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: InkWell(
                        onTap: () {
                          _sendEmail();
                        },
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: "Email Address\n",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: Responsive.isMobileSmall(context)
                                    ? 13
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 15
                                        : Responsive.isTabletPortrait(context)
                                            ? 24
                                            : 27,
                              ),
                            ),
                            TextSpan(
                              text: "contact@auradot.com",
                              style: TextStyle(
                                height: 1.8,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: Responsive.isMobileSmall(context)
                                    ? 13
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 15
                                        : Responsive.isTabletPortrait(context)
                                            ? 24
                                            : 27,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 5
                      : 50,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
