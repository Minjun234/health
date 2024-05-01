import 'dart:math';
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
  bool _isLocked = false;
  int _steps = 0;
  int _goalSteps = 1000;
  final LowPassFilter _filter = LowPassFilter();
  int _lastMotionTime = 0;
  int _lastStepTime = 0;
  static const int stepDelay = 500;  // 최소 걸음 간 시간 간격을 500ms로 설정

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      double filteredMagnitude = _filter.apply(event);
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (filteredMagnitude > 8.5 && (currentTime - _lastStepTime > stepDelay)) {  // 걸음 간격 확인
        _lastMotionTime = currentTime; // 움직임 감지 시간 업데이트
        _lastStepTime = currentTime; // 걸음 감지 시간 업데이트
        _incrementSteps();  // 걸음 수 증가
        if (_isLocked) {
          _unlockDevice();  // 잠금 해제 함수 호출
        }
      }

      if (currentTime - _lastMotionTime > 30000 && !_isLocked) {  // 30초 동안 움직임이 없는 경우
        _lockDevice();  // 장치 잠금 함수 호출
      }
    });
  }

  void _incrementSteps() {
    setState(() {
      _steps++;  // 걸음 수 증가
    });
  }

  void _unlockDevice() {
    setState(() {
      _isLocked = false;  // 잠금 해제
    });
  }

  void _lockDevice() {
    setState(() {
      _isLocked = true;  // 장치 잠금
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Unlock App'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: Text('목표치 설정'), onTap: () {}),
            ListTile(title: Text('잠금 앱 목록'), onTap: () {}),
          ],
        ),
      ),
      body: Container(
        color: Colors.lightBlue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(_isLocked ? Icons.lock : Icons.lock_open, size: 100, color: _isLocked ? Colors.red : Colors.green),
              Text(_isLocked ? 'Device is Locked' : 'Device is Unlocked', style: Theme.of(context).textTheme.headline4?.copyWith(color: _isLocked ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Steps: $_steps / $_goalSteps', style: Theme.of(context).textTheme.headline5),
            ],
          ),
        ),
      ),
    );
  }
}

class LowPassFilter {
  static const double alpha = 0.5;  // Low-pass filter constant
  double lastX = 0, lastY = 0, lastZ = 0;

  double apply(AccelerometerEvent event) {
    lastX = alpha * (lastX + event.x - lastX);
    lastY = alpha * (lastY + event.y - lastY);
    lastZ = alpha * (lastZ + event.z - lastZ);
    return sqrt(lastX * lastX + lastY * lastY + lastZ * lastZ);
  }
}
