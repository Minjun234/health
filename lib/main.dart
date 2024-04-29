
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Active Unlock App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLocked = true;  // 초기 잠금 상태
  double _threshold = 1.0;  // 움직임 감지 임계값, 적절히 조정 필요
  int _steps = 0;  // 현재 걸음 수
  int _goalSteps = 10000;  // 목표 걸음 수

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() > _threshold || event.y.abs() > _threshold || event.z.abs() > _threshold) {
        if (_isLocked && _steps < _goalSteps) {
          setState(() {
            _steps++;  // 움직임 감지 시 걸음 수 증가
          });
        }
        if (_steps >= _goalSteps) {  // 목표 걸음 수 달성 시 잠금 해제
          setState(() {
            _isLocked = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Go To The Gym'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('목표치 설정'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('잠금 앱 목록'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.lightBlue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _isLocked ? Icons.directions_walk_rounded : Icons.lock_open,
                size: 100,
                color: _isLocked ? Colors.red : Colors.green,
              ),
              Text(
                _isLocked ? 'Go to the fucking gym' : 'very Good!!',
                style: Theme.of(context).textTheme.headline4?.copyWith(
                  color: _isLocked ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '남은 걸음수: $_steps / $_goalSteps',
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}