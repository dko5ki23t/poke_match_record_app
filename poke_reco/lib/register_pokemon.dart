import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:poke_reco/main.dart';

class RegisterPokemonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ポケモン登録'),
        actions: [
          Text('完了'),
        ]
      ),
      body: ListView(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Row(  // ポケモン名, 図鑑No
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child:TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'ポケモン名'
                  ),
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child:TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '図鑑No.'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 5,
                ),
              ),            
            ],
          ),
          SizedBox(height: 10),
          Row(  // ニックネーム
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child:TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'ニックネーム'
                  ),
                  maxLength: 6,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // タイプ1, タイプ2, テラスタイプ
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'タイプ1'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in PokeType.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Icon(type.displayIcon),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'タイプ2'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in PokeType.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Icon(type.displayIcon),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'テラスタイプ'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in PokeType.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Icon(type.displayIcon),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // レベル, せいべつ, せいかく
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'レベル'
                  ),
                  min: 1,
                  max: 100,
                  value: 50,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'せいべつ'
                  ),
                  items: const[
                    DropdownMenuItem(
                      value: 'なし',
                      child: Icon(Icons.minimize),
                    ),
                    DropdownMenuItem(
                      value: 'オス',
                      child: Icon(Icons.male),
                    ),
                    DropdownMenuItem(
                      value: 'メス',
                      child: Icon(Icons.female),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'せいかく'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in Temper.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Text(type.displayName),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // とくせい, もちもの
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'とくせい'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in Ability.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Text(type.displayName),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'もちもの'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in Item.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Text(type.displayName),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // HP
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  initialValue: 'H -',
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'HP'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // こうげき
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  initialValue: 'A -',
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'こうげき'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // とくこう
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  initialValue: 'B -',
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'ぼうぎょ'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // ぼうぎょ
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  initialValue: 'C -',
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'とくこう'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // とくぼう
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  initialValue: 'D -',
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'とくぼう'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // すばやさ
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  initialValue: 'S -',
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'すばやさ'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // わざ1, PP1
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'わざ1'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in Move.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Text(type.displayName),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'PP'
                  ),
                  value: 5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // わざ2, PP2
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'わざ2'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in Move.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Text(type.displayName),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'PP'
                  ),
                  value: 5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // わざ3, PP3
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'わざ3'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in Move.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Text(type.displayName),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'PP'
                  ),
                  value: 5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // わざ4, PP4
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'わざ4'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in Move.values)
                      DropdownMenuItem(
                        value: type.displayName,
                        child: Text(type.displayName),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'PP'
                  ),
                  value: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}