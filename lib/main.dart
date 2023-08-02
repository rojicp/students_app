import 'package:flutter/material.dart';
import 'package:students_app/services/global.dart';
import 'screens/students.dart';
import 'screens/counter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String pageCaption = "Home Page";
  String pageName = "home";
  bool counterSwitch = false;

  Widget homePageButtons() {
    return Container(
      decoration: const BoxDecoration(
          //color: Color.fromARGB(255, 144, 144, 223),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/background_image.jpg"))),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Show Counter Example",
                style: TextStyle(color: Colors.white),
              ),
              Switch(
                value: counterSwitch,
                onChanged: (value) async {
                  counterSwitch = value;
                  showCounterExample = value;

                  // Obtain shared preferences.
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('counterSwitch', value);

                  setState(() {});
                },
                inactiveTrackColor: Colors.amber,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (showCounterExample)
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const CounterWidget();
                  },
                ));
              },
              child: const Text("Counter Example"),
            ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const StudentsPage();
                },
              ));
            },
            child: const Text("Students Entry Page"),
          ),
        ]),
      ),
    );
  }

  Future<void> loadSettings() async {
    //counterSwitch =
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    counterSwitch = prefs.getBool('counterSwitch') ?? false;
    showCounterExample = counterSwitch;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    loadSettings();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(pageCaption),
          ],
        ),
      ),
      body: homePageButtons(),
    );
  }
}
