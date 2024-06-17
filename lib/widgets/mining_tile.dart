import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mininggame/mine_handler.dart';

class MiningTile extends StatefulWidget {
  const MiningTile({super.key, required this.isMine, required this.onMined});

  final bool isMine;
  final void Function(MineResult) onMined;

  @override
  State<MiningTile> createState() => _MiningTileState();
}

class _MiningTileState extends State<MiningTile> {

  bool isMined = false;

  Color get _tileBgColor => isMined ? const Color(0xFF051828) : const Color(0xFF364F5C);

  Image? get _tileImage => isMined ? _getImage : null;

  Image get _getImage => widget.isMine ? Image(image: const AssetImage('assets/mine.png',), width: 25.r, height: 25.r,) : Image(image: const AssetImage('assets/diamond.png',), width: 25.r, height: 25.r,);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(isMined) {
          return;
        }
        widget.onMined(widget.isMine ? MineResult.mine : MineResult.diamond);
        setState(() {
          isMined = true;
        });
      },
      child: Container(
        width: 50.r,
        height: 50.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          color: _tileBgColor,
        ),
        child: _tileImage,
      ),
    );
  }
}