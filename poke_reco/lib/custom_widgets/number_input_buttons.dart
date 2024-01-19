import 'package:flutter/material.dart';

class NumberInputButtons extends StatefulWidget {
  const NumberInputButtons({
    Key? key,
    required this.initialNum,
    required this.onFixed,
  }) : super(key: key);
  
  final int initialNum;
  final void Function(int) onFixed;

  @override
  State<NumberInputButtons> createState() => _NumberInputButtonsState();
}

class _NumberInputButtonsState extends State<NumberInputButtons> {
  bool _isFirstBuild = true;
  int _number = 0;
  bool fixed = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
//    final theme = Theme.of(context);
//    ButtonStyle pressedStyle = ButtonStyle(
//      backgroundColor: MaterialStateProperty.all<Color>(theme.secondaryHeaderColor),
//    );
    const Size buttonSize = Size(100, 100);

    if (_isFirstBuild) {
      _number = widget.initialNum;
      _isFirstBuild = false;
      controller.text = _number.toString();
    }

    void changeNum(void Function() func) {
      setState(() {
        func();
        controller.text = _number.toString();
      });
    }

    return FittedBox(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.1),
              child: SizedBox(
                width: 450,
                height: 100,
                child: TextField(
                  readOnly: true,
                  controller: controller,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('1', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 1;
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('2', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 2;
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('3', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 3;
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('4', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 4;
                  }),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('5', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 5;
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('6', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 6;
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('7', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 7;
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('8', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 8;
                  }),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('9', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10 + 9;
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  child: Text('0', style: TextStyle(fontSize: 50),),
                  onPressed: () => changeNum(() {
                    _number = _number * 10;
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  child: Icon(Icons.backspace, size: 50),
                  onPressed: () => changeNum(() {
                    _number = (_number / 10).floor();
                  }),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  pressed: fixed,
                  child: Icon(Icons.subdirectory_arrow_left, size: 50),
                  onPressed: () => setState(() {
                    fixed = true;
                    widget.onFixed(_number);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberInputButton extends StatelessWidget {
  _NumberInputButton({
    Key? key,
    required this.child,
    required this.size,
    required this.onPressed,
    this.pressed = false,
  }) : super(key: key);

  final Widget child;
  final Size size;
  final void Function() onPressed;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(7),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: pressed ? Colors.blue : null,
          fixedSize: size,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
