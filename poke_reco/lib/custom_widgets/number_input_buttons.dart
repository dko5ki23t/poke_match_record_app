import 'dart:math';

import 'package:flutter/material.dart';

class NumberInputButtons extends StatefulWidget {
  const NumberInputButtons({
    Key? key,
    required this.initialNum,
    required this.onConfirm,
    this.maxDigits = 4,
    this.prefixText,
    this.suffixText,
    this.enabled = true,
  }) : super(key: key);

  final int initialNum;
  final void Function(int) onConfirm;
  final int maxDigits;
  final String? prefixText;
  final String? suffixText;
  final bool enabled;

  @override
  State<NumberInputButtons> createState() => _NumberInputButtonsState();
}

class _NumberInputButtonsState extends State<NumberInputButtons> {
  int _number = 0;
  bool confirmed = false;
  bool firstInput = true;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _number = widget.initialNum;
    controller.text = _number.toString();
  }

  @override
  Widget build(BuildContext context) {
//    final theme = Theme.of(context);
//    ButtonStyle pressedStyle = ButtonStyle(
//      backgroundColor: MaterialStateProperty.all<Color>(theme.secondaryHeaderColor),
//    );
    const Size buttonSize = Size(100, 100);

    void changeNum(void Function() func) {
      setState(() {
        func();
        controller.text = _number.toString();
      });
    }

    void inputNum(int n) {
      if (confirmed || firstInput) {
        confirmed = false;
        firstInput = false;
        changeNum(() {
          _number = n;
        });
      } else if ((_number / pow(10, widget.maxDigits - 1)).floor() == 0) {
        changeNum(() {
          _number = _number * 10 + n;
        });
      }
    }

    return FittedBox(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: SizedBox(
                width: 440,
                height: 75,
                child: TextField(
                  readOnly: true,
                  controller: controller,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixText: widget.prefixText,
                    prefixStyle: TextStyle(fontSize: 25),
                    suffixText: widget.suffixText,
                    suffixStyle: TextStyle(fontSize: 25),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                  ),
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(1) : null,
                  child: Text(
                    '1',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(2) : null,
                  child: Text(
                    '2',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(3) : null,
                  child: Text(
                    '3',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(4) : null,
                  child: Text(
                    '4',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(5) : null,
                  child: Text(
                    '5',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(6) : null,
                  child: Text(
                    '6',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(7) : null,
                  child: Text(
                    '7',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(8) : null,
                  child: Text(
                    '8',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(9) : null,
                  child: Text(
                    '9',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled ? () => inputNum(0) : null,
                  child: Text(
                    '0',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                _NumberInputButton(
                  size: buttonSize,
                  onPressed: widget.enabled
                      ? () => changeNum(() {
                            _number = (_number / 10).floor();
                          })
                      : null,
                  child: Icon(Icons.backspace, size: 50),
                ),
                _NumberInputButton(
                  key: Key('EnterButton'),
                  size: buttonSize,
                  pressed: confirmed,
                  child: Icon(Icons.subdirectory_arrow_left, size: 50),
                  onPressed: () => setState(() {
                    confirmed = true;
                    widget.onConfirm(_number);
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
  final void Function()? onPressed;
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
