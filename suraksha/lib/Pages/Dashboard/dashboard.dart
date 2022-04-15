import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:suraksha/Pages/Contacts/mycontacts.dart';
import 'package:suraksha/Pages/Contacts/addContact.dart';
import 'package:suraksha/Pages/Dashboard/home.dart';

class Dashboard extends StatefulWidget {
  final int pageIndex;
  const Dashboard({Key? key, this.pageIndex = 0}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _DashboardState createState() => _DashboardState(currentPage: pageIndex);
}

class _DashboardState extends State<Dashboard> {
  _DashboardState({this.currentPage = 0});

  List<Widget> screens = [const Home(), const MyContactsScreen()];
  bool alerted = false;
  int currentPage = 0;
  bool pinChanged = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFAFCFE),
        floatingActionButton: currentPage == 1
            ? FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddContactPage()));
                },
                child: Image.asset("assets/add-contact.png", height: 60),
              )
            : FloatingActionButton(
                onPressed: () {},
                child: alerted
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        Image.asset("assets/alarm.png", height: 24),
                        const Text("STOP")
                      ])
                    : Image.asset("assets/icons/alert.png", height: 36)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 12,
            child: SizedBox(
                height: 60,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                          onTap: () {
                            if (currentPage != 0) {
                              setState(() {
                                currentPage = 0;
                              });
                            }
                          },
                          child: Image.asset("assets/home.png", height: 28)),
                      InkWell(
                          onTap: () {
                            if (currentPage != 1) {
                              setState(() {
                                currentPage = 1;
                              });
                            }
                          },
                          child:
                              Image.asset("assets/phone_red.png", height: 28))
                    ]))),
        body: SafeArea(
            child: ShowCaseWidget(
          builder: Builder(builder: (context) => screens[currentPage]),
        )));
  }
}
