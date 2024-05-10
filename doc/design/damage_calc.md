## わざのダメージ計算式(補正前)

$$
D=(((L*2/5+2).floor()*P*(Atk/Def)).floor()/50+2).floor()
$$

- D : ダメージ
- L : こうげきするポケモンのレベル
- P : わざの威力
- Atk : こうげき値(TODO:詳細な計算方法)
- Def : ぼうぎょ値(TODO:詳細な計算方法)

※こうげき値やぼうぎょ値はわざの種類やポケモン・場の状態等により変化する。

## わざのダメージ(補正前)->こうげき値

$$
Atk=\frac{(50*(D-2|D-1)|50*(D-2|D-1)+1)*Def}{(L*2/5+2).floor()*P}
$$

- D : ダメージ
- L : こうげきするポケモンのレベル
- P : わざの威力
- Atk : こうげき値(TODO:詳細な計算方法)
- Def : ぼうぎょ値(TODO:詳細な計算方法)

参考：https://wiki.xn--rckteqa2e.com/wiki/%E3%83%80%E3%83%A1%E3%83%BC%E3%82%B8#%E7%AC%AC%E4%BA%94%E4%B8%96%E4%BB%A3%E4%BB%A5%E9%99%8D