
import 'dart:developer' show log;
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mininggame/db_handler.dart';
import 'package:mininggame/retry_handler.dart';
import 'package:mininggame/mine_handler.dart';
import 'package:mininggame/widgets/mining_tile.dart';
import 'package:supabase/supabase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
void initState() {
  super.initState();
}


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
      child: const RulesPage(),
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
    initialize();
  }

  void checkIfUnderMaintainance() async {
    final int winnersCount = await SupabaseHandler.instance.getWinnersCount();
    if(winnersCount > 5) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UnderMaintainance()));
    }
  }

  void initialize() async {
    mineHandler = MineHandler();
    startListening();
    checkIfUnderMaintainance();
    final DateTime now = DateTime.now();
    await SupabaseHandler.instance.addGameSessionsData(sessionData: now.toString());
  }

  void startListening() {
     mineHandler.mineResult.listen((MineResult result) {
      if(result.isWin) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MiningGame()));
      }
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
              height: 50.h,
            ),
            const RetryCount(),
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

class ResultPage extends StatefulWidget {
  ResultPage({super.key, required this.diamondCount, required this.mineCount,});

  final int diamondCount;
  final int mineCount;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String kWinner = "Congrats! You've won the game!";

  String kLoser = "Game over. Better luck next!";

  String kAlmostWinner = "Nearly won! Just one more!";

  String kWarning = 'Confirm the number above. We will use it to reach out to you for the reward. If the number is incorrect, the reward will be nullified.';

  int get _winCount => RetryHandler.instance.winCount;

  final TextEditingController _numberController = TextEditingController();


  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  String get _getResultMessage {
    if(_winCount >= 3) {
      return kWinner;
    } else if(_winCount >= 2) {
      return kAlmostWinner;
    } else {
      return kLoser;
    }
  }

  Image get _getEmoji {
    if(_winCount >= 3) {
      return Image.asset('assets/win.png');
    } else if(_winCount >= 2) {
      return Image.asset('assets/loss.png');
    } else {
      return Image.asset('assets/loss.png');
    }
  }

  Widget _getClaimPrizeOrRetryBtn(BuildContext context) {
    if(_winCount < 3) {
      return ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MiningGame()));
            RetryHandler.instance.resetCount(); 
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF051828), // background color
          ),
          child: const Text('I want Netflix, Play Again', style: TextStyle(color: Colors.white)));
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: TextField(
              controller: _numberController,
              style: TextStyle(color: Colors.white, fontSize: 11.sp),
              decoration: InputDecoration(
                hintText: 'Enter your phone no to claim Netflix',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 11.sp),
                
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: RichText(text: TextSpan(
              children: [
                TextSpan(text: '* ', style: TextStyle(color: Colors.red, fontSize: 10.sp)),
                TextSpan(text: kWarning, style: TextStyle(color: Colors.white, fontSize: 10.sp)),
              ],
            )),
          ),
          SizedBox(height: 10.h,),
          ElevatedButton(
          onPressed: () {
            SupabaseHandler.instance.addNumber(number: _numberController.text);
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReachOutPage()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF051828), // background color
          ),
          child: const Text('Claim Netflix', style: TextStyle(color: Colors.white)))
        ],
      );
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
          Text('Your Score: ${RetryHandler.instance.winCount} / 3', style: TextStyle(color: Colors.white, fontSize: 16.sp),),
          SizedBox(height: 10.h,),
          _getClaimPrizeOrRetryBtn(context),
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


class RetryCount extends StatefulWidget {
  const RetryCount({super.key});

  @override
  State<RetryCount> createState() => _RetryCountState();
}

class _RetryCountState extends State<RetryCount> {

  int winCount = 0;

  @override
  void initState() {
    super.initState();
    winCount = RetryHandler.instance.winCount;
    RetryHandler.instance.addListener(_updateWinCount);
  }

  void _updateWinCount() {
    setState(() {
      winCount = RetryHandler.instance.winCount;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    RetryHandler.instance.removeListener(_updateWinCount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Align(
      alignment: Alignment.centerRight,
      child: Text('Score: $winCount / 3', style: TextStyle(color: Colors.white, fontSize: 12.sp),),
    ),
  );
  }
}

class ReachOutPage extends StatelessWidget {
  const ReachOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF0C2634),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('We will reach out to you soon!', style: TextStyle(color: Colors.white, fontSize: 20.sp),),  
            SizedBox(height: 20.h,),
            ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MiningGame()));
            RetryHandler.instance.resetCount(); 
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF051828), // background color
          ),
          child: const Text('Play Again', style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );
  }
}

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF0C2634),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            Text('Rules', style: TextStyle(color: Colors.white, fontSize: 20.sp),),
            SizedBox(height: 20.h,),
            Text('1. Find 20 diamonds before hitting 5 mines.', style: TextStyle(color: Colors.white, fontSize: 12.sp),),
            Text('2. Do this for 3 consecutive rounds.', style: TextStyle(color: Colors.white, fontSize: 12.sp),),
            Text('3. Win a 1-month Netflix subscription as a reward.', style: TextStyle(color: Colors.white, fontSize: 12.sp),),
            Text("4. Unlimited chances if you don't succeed!", style: TextStyle(color: Colors.white, fontSize: 12.sp),),
            SizedBox(height: 20.h,),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MiningGame()));
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF051828), // background color
          ),
          child: const Text('Play', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );

  }
}


class UnderMaintainance extends StatelessWidget {
  const UnderMaintainance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0XFF0C2634),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('We are under maintainance :(', style: TextStyle(color: Colors.white, fontSize: 20.sp),),
            Text(' Please try again after some time', style: TextStyle(color: Colors.white, fontSize: 20.sp),),
          ],
        ),
      ),
    );
  }
}