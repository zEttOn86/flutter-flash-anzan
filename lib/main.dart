import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';

// TODO: OKの場合、〇を表示、NGの場合、×を表示
// TODO: 数字だけ入力可能
const int SENTINEL = 0xFFFF;
const int MAX_NUMBERS = 10;
const int SHOW_OK = 0xFFFE;
const int SHOW_NG = 0xFFFD;

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
      debugShowCheckedModeBanner: false,
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
                    return FlushPage(
                      level: index,
                    );
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
  FlushPage({Key? key, required this.level}) : super(key: key);
  final int level;

  @override
  State<FlushPage> createState() => _FlushPageState();
}

class _FlushPageState extends State<FlushPage>  with TickerProviderStateMixin {
  // https://api.flutter.dev/flutter/animation/AnimationController-class.html
  List<int> _numbers = [];        
  final int max_numbers = MAX_NUMBERS; // max length of _numbers.
  int _index = SENTINEL;
  bool _isFirst = true;
  String _ans = "";
  int _res = 0;
  bool isEnabled = false;

  void generate_numbers() {
    setState(() {
      for(int i = 0; i < max_numbers; i++) 
      {
        int num = Random().nextInt(pow(10, widget.level+1).toInt());
        _res += num;
        _numbers.add(num);
      }
      print("_res:${_res}");
    });
    
  }

  @override
  void initState() {
    super.initState();
    generate_numbers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  child: Icon(Icons.play_arrow),
                  onPressed: () => {
                    // TODO: Timer dispose
                    Timer.periodic(
                      Duration(seconds: 1),
                      (Timer timer){
                        setState(() {
                          if (_index==SENTINEL && _isFirst){
                            _isFirst = false;
                            _index = 0;
                          }
                          else if(_index >= 0 && _index < max_numbers - 1) {
                            _index += 1;
                          }
                          else {
                            _index = SENTINEL;
                            isEnabled = true;
                            timer.cancel();
                          }
                          print("_index: ${_index}");
                        });
                      },
                    ),
                  },
                  heroTag: "hero1", 
                ),
                // FloatingActionButton(
                //   child: Icon(Icons.refresh),
                //   onPressed: ()=>{
                //     setState((){
                //       _isFirst = true;
                //     })
                //   },
                //   heroTag: "hero2", 
                // ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              width:400,
              height: 400,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    // color: Theme.of(context).indicatorColor,
                    width: 3,
                  ),
                  top: BorderSide(
                    // color: Theme.of(context).indicatorColor,
                    width: 3,
                  ),
                  right: BorderSide(
                    // color: Theme.of(context).indicatorColor,
                    width: 3,
                  ),
                  bottom: BorderSide(
                    // color: Theme.of(context).indicatorColor,
                    width: 3,
                  ),
                ),
              ),
              child:Center(
                child: IntNumbersRenderer(
                  num_list: _numbers,
                  index: _index,
                ),
              ),
            ),
            SizedBox(height: 20.0,),
            Container(
              padding: EdgeInsets.fromLTRB(400, 0, 400, 0),
              child:TextField(
                enabled: isEnabled,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter result of FLASH ANZAN",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (String text) {
                  setState(() {
                    _ans = text;
                  });
                },
              ),
            ),
            SizedBox(height: 20.0,),
            Container(
              child:FloatingActionButton(  
                child: Text("Ans"),
                onPressed: ()=>{
                  setState((){
                    if(_ans == _res.toString()){
                      _index = SHOW_OK;
                      print("OK");
                    }
                    else {
                      _index = SHOW_NG;
                      print("NG");
                    }
                  })
                },
                heroTag: "hero3",
              ),
            )
          ],
        ),
      ),
    );
  }
}

class IntNumbersRenderer extends StatelessWidget {
  IntNumbersRenderer({Key? key, required this.num_list, required this.index}):super(key:key);
  late List<int> num_list;
  late int index;
  @override
  Widget build(BuildContext context) {
      print(index);
      if (index == SENTINEL)
      {
        return Text("");
      }
      else if(index == SHOW_OK)
      {
        return Icon(Icons.circle_outlined, color: Colors.red, size: 150.0,);
      }
      else if(index == SHOW_NG)
      {
        return Icon(Icons.clear, color: Colors.black, size: 150.0,);
      }
      else
      {
        return Text(
          num_list[index].toString(),
          style: TextStyle(fontSize: 150.0),
        );
      }
    }
}