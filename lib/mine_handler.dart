import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

enum MineResult {
  diamond,
  mine,
  completed,
}

extension MineResultExt on MineResult {
  bool get isDiamond => this == MineResult.diamond;
  bool get isMine => this == MineResult.mine;
  bool get isCompleted => this == MineResult.completed;
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

  void _checkIfCompleted() {
    if(_mineCount == 5 ||  _diamondCount >= 20 || (diamondCount + mineCount) == 25) {
      _mineResult.add(MineResult.completed);
    }
  }

}