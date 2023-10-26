import 'dart:async';

import 'package:flutter/material.dart';

class InviteCoOrderScreen extends StatefulWidget {
  final int durationInSeconds;

  InviteCoOrderScreen({required this.durationInSeconds});

  @override
  _InviteCoOrderScreenState createState() => _InviteCoOrderScreenState();
}

class _InviteCoOrderScreenState extends State<InviteCoOrderScreen> {
  late int _secondsRemaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationInSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    setState(() {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(
            value: (_secondsRemaining / widget.durationInSeconds),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 10,
          ),
          SizedBox(height: 10),
          // Text(
          //   '$_secondsRemaining seconds remaining',
          //   style: TextStyle(fontSize: 16),
          // ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Countdown Process Icon')),
      body: InviteCoOrderScreen(durationInSeconds: 10),
    ),
  ));
}
