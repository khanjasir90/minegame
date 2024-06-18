import 'package:flutter/material.dart';
import 'package:mininggame/retry_handler.dart';
import 'package:rxdart/subjects.dart';

enum MineResult {
  diamond,
  mine,
  completed,
  win,
  loss,
}

extension MineResultExt on MineResult {
  bool get isDiamond => this == MineResult.diamond;
  bool get isMine => this == MineResult.mine;
  bool get isCompleted => this == MineResult.completed;
  bool get isWin => this == MineResult.win;
  bool get isLoss => this == MineResult.loss;
}

class MineHandler extends ChangeNotifier{

  MineHandler();

  final BehaviorSubject<MineResult> _mineResult = BehaviorSubject<MineResult>();
  int _diamondCount = 0;
  int _mineCount = 0;

  int get diamondCount => _diamondCount;
  int get mineCount => _mineCount;

  Stream<MineResult> get mineResult => _mineResult.stream;

  void add(MineResult result)  {
    if(result.isDiamond) {
      _diamondCount++;
    } else {
      _mineCount++;
    }
    _mineResult.add(result);
    _checkIfCompleted();
    notifyListeners();
  }

  void _checkIfCompleted() async {
    if(_diamondCount >= 20) {
      RetryHandler.instance.incrementCount();
      if(RetryHandler.instance.winCount >= 3) {
        _mineResult.add(MineResult.completed);
        return;
      }
      _mineResult.add(MineResult.win);
    } else if(_mineCount >= 5) {
      _mineResult.add(MineResult.completed);
    }
  }

}