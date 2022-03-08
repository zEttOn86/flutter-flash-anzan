import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'フラッシュ暗算',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'FLASH ANZAN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title}) : super();

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> levelList = [
    "Level 1",
    "Level 2",
    "Level 3",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("レベル選択"),
      ),
      body: ListView.builder(
        itemCount: levelList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(levelList[index]),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return FlushPage();
                  }),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class FlushPage extends StatefulWidget {
  @override
  State<FlushPage> createState() => _FlushPageState();
}

class _FlushPageState extends State<FlushPage>  with TickerProviderStateMixin {
  late AnimationController _controller;
  static const int kStartValue = 4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: kStartValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Game'),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.play_arrow),
        onPressed: () => _controller.forward(from: 0.0),
      ),
      body: Container(
        child: Center(
          child: Countdown(
            animation: StepTween(
              begin: kStartValue,
              end: 0,
            ).animate(_controller),
          ),
        ),
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({ Key? key, required Animation<int> animation}) : super(key:key, listenable: animation);
  // late Animation<int> _animation;

  @override
  Widget build(BuildContext context){
    final animation = listenable as Animation<int>;
    return Text(
      animation.value.toString(),
      style: TextStyle(fontSize: 150.0),
    );
  }
}