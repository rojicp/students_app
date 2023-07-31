import 'package:flutter/material.dart';
import 'students.dart';
import 'counter.dart';

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

  Widget homePageButtons() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
