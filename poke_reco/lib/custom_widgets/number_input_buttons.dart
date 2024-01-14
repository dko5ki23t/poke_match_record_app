import 'package:flutter/material.dart';

class NumberInputButtons extends StatefulWidget {
  const NumberInputButtons({
    Key? key,
    required this.initialNum,
  }) : super(key: key);
  
  final int initialNum;

  @override
  State<NumberInputButtons> createState() => _NumberInputButtonsState();
}

class _NumberInputButtonsState extends State<NumberInputButtons> {
  bool _isFirstBuild = true;
  int _number = 0;

  @override
  Widget build(BuildContext context) {
    if (_isFirstBuild) {
      _number = widget.initialNum;
      _isFirstBuild = false;
    }
    
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              child: Container(
                width: 500,
                height: 70,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3,),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FittedBox(child: Text(_number.toString(), style: TextStyle(fontSize: 50),)),
              ),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NumberInputButton(
                child: Text('1', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 1;
                }),
              ),
              _NumberInputButton(
                child: Text('2', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 2;
                }),
              ),
              _NumberInputButton(
                child: Text('3', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 3;
                }),
              ),
              _NumberInputButton(
                child: Text('4', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 4;
                }),
              ),
            ],
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NumberInputButton(
                child: Text('5', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 5;
                }),
              ),
              _NumberInputButton(
                child: Text('6', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 6;
                }),
              ),
              _NumberInputButton(
                child: Text('7', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 7;
                }),
              ),
              _NumberInputButton(
                child: Text('8', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 8;
                }),
              ),
            ],
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NumberInputButton(
                child: Text('9', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10 + 9;
                }),
              ),
              _NumberInputButton(
                child: Text('0', style: TextStyle(fontSize: 50),),
                onTap: () => setState(() {
                  _number = _number * 10;
                }),
              ),
              _NumberInputButton(
                child: Icon(Icons.backspace, size: 50),
                onTap: () => setState(() {
                  _number = (_number / 10).floor();
                }),
              ),
              _NumberInputButton(
                child: Icon(Icons.subdirectory_arrow_left, size: 50),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberInputButton extends StatelessWidget {
  _NumberInputButton({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  final Widget child;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FittedBox(child: child),
          ),
        ),
      ),
    );
  }
}
