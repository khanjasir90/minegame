
import 'dart:developer' show log;
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mininggame/mine_handler.dart';
import 'package:mininggame/widgets/mining_tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, child) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: child,
      ),
      child: const MiningGame(),
    );
  }
}


class MiningGame extends StatefulWidget {
  const MiningGame({super.key});

  @override
  State<MiningGame> createState() => _MiningGameState();
}

class _MiningGameState extends State<MiningGame> {

  late MineHandler mineHandler;

  @override
  void initState() {
    super.initState();
    mineHandler = MineHandler();
    startListening();
  }

  void startListening() {
     mineHandler.mineResult.listen((MineResult result) {
      if(result.isCompleted) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(diamondCount: mineHandler.diamondCount, mineCount: mineHandler.mineCount,)));
      }
    });
  }

  List<int> generateRandomNumbers() {
    final List<int> randomNumbers = [];
    while (randomNumbers.length < 5) {
      final int randomNumber = Random().nextInt(25);
      if (!randomNumbers.contains(randomNumber)) {
        randomNumbers.add(randomNumber);
      }
    }
    return randomNumbers;
  }

  @override
  Widget build(BuildContext context) {
    final List<int> randomNumbers = generateRandomNumbers();
    return Scaffold(
      backgroundColor: const Color(0XFF0C2634),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100.h,
            ),
            SizedBox(
              child: Image.asset('assets/miner.png'),
            ),
              SizedBox(
              height: 25.h,
            ),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 5,
              crossAxisSpacing: 5.sp,
              mainAxisSpacing: 5.sp,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              children: [
                for (int i = 0; i < 25; i++) MiningTile(isMine: randomNumbers.contains(i), onMined: (MineResult result) {
                  mineHandler.add(result);
                },),
              ],
            ),      
            MineScoreCard(mineHandler: mineHandler)
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  ResultPage({super.key, required this.diamondCount, required this.mineCount,});

  final int diamondCount;
  final int mineCount;

  String kWinner = "Congratulations! You've won the game!";
  String kLoser = "Game over. Better luck next!";
  String kAlmostWinner = "Nearly won! Just one more!";

  String get _getResultMessage {
    if(diamondCount >= 20) {
      return kWinner;
    } else if(mineCount == 5) {
      return kLoser;
    } else {
      return kAlmostWinner;
    }
  }

  Image get _getEmoji {
    if(diamondCount >= 20) {
      return Image.asset('assets/win.png');
    } else if(mineCount == 5) {
      return Image.asset('assets/loss.png');
    } else {
      return Image.asset('assets/loss.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF0C2634),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          SizedBox(child: _getEmoji,),
          SizedBox(height: 10.h,),
          Text(_getResultMessage, style: TextStyle(color: Colors.white, fontSize: 20.sp),),
          SizedBox(height: 10.h,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: Image.asset('assets/diamond.png'),
              ),
              SizedBox(width: 10.w,),
              Text('$diamondCount', style: TextStyle(color: Colors.white, fontSize: 20.sp),),
            ],
          ),
          SizedBox(height: 10.h,),
           Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: Image.asset('assets/mine.png'),
              ),
              SizedBox(width: 10.w,),
              Text('$mineCount', style: TextStyle(color: Colors.white, fontSize: 20.sp),),
            ],
          ),
          SizedBox(height: 10.h,),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MiningGame()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF051828), // background color
          ),
          child: const Text('Play Again', style: TextStyle(color: Colors.white))),
        ],
        ),
      ),
    );
  }
}

class MineScoreCard extends StatefulWidget {
  const MineScoreCard({super.key, required this.mineHandler});

  final MineHandler mineHandler;

  @override
  State<MineScoreCard> createState() => _MineScoreCardState();
}

class _MineScoreCardState extends State<MineScoreCard> {

  int diamondCount = 0;
  int mineCount = 0;

  @override
  void initState() {
    super.initState();
    diamondCount = widget.mineHandler.diamondCount;
    mineCount = widget.mineHandler.mineCount;
    widget.mineHandler.addListener(_updateCounts);
  }

  void _updateCounts() {
    setState(() {
      diamondCount = widget.mineHandler.diamondCount;
      mineCount = widget.mineHandler.mineCount;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.mineHandler.removeListener(_updateCounts);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: Image.asset('assets/diamond.png'),
              ),
              SizedBox(width: 10.w,),
              Text('$diamondCount', style: TextStyle(color: Colors.white, fontSize: 20.sp),),
            ],
          ),
          SizedBox(height: 10.h,),
           Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: Image.asset('assets/mine.png'),
              ),
              SizedBox(width: 10.w,),
              Text('$mineCount', style: TextStyle(color: Colors.white, fontSize: 20.sp),),
            ],
          ),
      ],
    );
  }
}
