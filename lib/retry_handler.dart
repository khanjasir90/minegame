import 'package:flutter/material.dart';

int kInitWinCount = 0;
int kMaxWinCount = 3;
String kWinCountKey = 'winCount';

class RetryHandler extends ChangeNotifier {

  RetryHandler._();

  static final RetryHandler _instance = RetryHandler._();

  static RetryHandler get instance => _instance;

  int _winCount = 0;

  int get winCount => _winCount;


  void incrementCount() {
    if(winCount <= kMaxWinCount) {
      _winCount++;
    }
    notifyListeners();
  }
  
  void resetCount() {
    _winCount = kInitWinCount;
    notifyListeners();
  }

}