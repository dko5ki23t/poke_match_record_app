import sqlite3
from enum import IntEnum
import argparse
from pathlib import Path

###### ユーザが登録するデータをSQLテーブルとして保存する ######

# 保存先SQLiteの各種名前
preparedDBFile = 'Prepared.db'

myPokemonDBTable = 'PreparedMyPokemonDB'
myPokemonColumnId = 'id'
myPokemonColumnViewOrder = 'viewOrder'
myPokemonColumnNo = 'no'
myPokemonColumnNickName = 'nickname'
myPokemonColumnTeraType = 'teratype'
myPokemonColumnLevel = 'level'
myPokemonColumnSex = 'sex'
myPokemonColumnNature = 'nature'
myPokemonColumnAbility = 'ability'
myPokemonColumnItem = 'item'
myPokemonColumnIndividual = [
  'indiH',
  'indiA',
  'indiB',
  'indiC',
  'indiD',
  'indiS',
]
myPokemonColumnEffort = [
  'effH',
  'effA',
  'effB',
  'effC',
  'effD',
  'effS',
]
myPokemonColumnMove1 = 'move1'
myPokemonColumnPP1 = 'pp1'
myPokemonColumnMove2 = 'move2'
myPokemonColumnPP2 = 'pp2'
myPokemonColumnMove3 = 'move3'
myPokemonColumnPP3 = 'pp3'
myPokemonColumnMove4 = 'move4'
myPokemonColumnPP4 = 'pp4'
myPokemonColumnOwnerID = 'owner'


partyDBTable = 'preparedPartyDB'
partyColumnId = 'id'
partyColumnViewOrder = 'viewOrder'
partyColumnName = 'name'
partyColumnPokemonId1 = 'pokemonID1'
partyColumnPokemonItem1 = 'pokemonItem1'
partyColumnPokemonId2 = 'pokemonID2'
partyColumnPokemonItem2 = 'pokemonItem2'
partyColumnPokemonId3 = 'pokemonID3'
partyColumnPokemonItem3 = 'pokemonItem3'
partyColumnPokemonId4 = 'pokemonID4'
partyColumnPokemonItem4 = 'pokemonItem4'
partyColumnPokemonId5 = 'pokemonID5'
partyColumnPokemonItem5 = 'pokemonItem5'
partyColumnPokemonId6 = 'pokemonID6'
partyColumnPokemonItem6 = 'pokemonItem6'
partyColumnOwnerID = 'owner'


battleDBFile = 'battles.db'
battleDBTable = 'battleDB'
battleColumnId = 'id'
battleColumnViewOrder = 'viewOrder'
battleColumnName = 'name'
battleColumnTypeId = 'battleType'
battleColumnDate = 'date'
battleColumnOwnPartyId = 'ownParty'
battleColumnOpponentName = 'opponentName'
battleColumnOpponentPartyId = 'opponentParty'
battleColumnTurns = 'turns'
battleColumnIsMyWin = 'isMyWin'
battleColumnIsYourWin = 'isYourWin'

class PokeType(IntEnum):
    normal = 1
    fight = 2
    fly = 3
    poison = 4
    ground = 5
    rock = 6
    bug = 7
    ghost = 8
    steel = 9
    fire = 10
    water = 11
    grass = 12
    electric = 13
    psychic = 14
    ice = 15
    dragon = 16
    evil = 17
    fairy = 18
    stellar = 19

class Sex(IntEnum):
    none = 0
    male = 1
    female = 2

class Nature(IntEnum):
    ganbariya = 1
    zubutoi = 2
    hikaeme = 3
    odayaka = 4
    okubyou = 5
    samishigari = 6
    sunao = 7
    ottori = 8
    otonashi = 9
    sekkachi = 10
    ijippari = 11
    wanpaku = 12
    tereya = 13
    shincho = 14
    ukariya = 15
    yoki = 16
    yancha = 17
    notenki = 18
    kimagure = 19
    mujaki = 20
    yukan = 21
    nonki = 22
    reisei = 23
    namaiki = 24
    majime = 25

class Owner(IntEnum):
    mine = 0
    fromBattle = 1
    hidden = 2

class Pokemon:
    def __init__(
            self, id:int, viewOrder:int, no:int, nickname:str, teraType:PokeType, level:int, sex:Sex,
            nature:Nature, abilityID:int, itemID:int, hIE:list, aIE:list, bIE:list, cIE:list, dIE:list, sIE:list, moveIDs:list,
            pps:list, owner:Owner):
        self.id = id
        self.viewOrder = viewOrder
        self.no = no
        self.nickname = nickname
        self.teraType = teraType
        self.level = level
        self.sex = sex
        self.nature = nature
        self.abilityID = abilityID
        self.itemID = itemID
        self.hIE = hIE
        self.aIE = aIE
        self.bIE = bIE
        self.cIE = cIE
        self.dIE = dIE
        self.sIE = sIE
        self.moveIDs = moveIDs
        self.pps = pps
        self.owner = owner

    def toSet(self):
        return (self.id, self.viewOrder, self.no, self.nickname, int(self.teraType), self.level, int(self.sex), int(self.nature), self.abilityID, self.itemID, self.hIE[0], self.aIE[0], self.bIE[0], self.cIE[0], self.dIE[0], self.sIE[0], self.hIE[1], self.aIE[1], self.bIE[1], self.cIE[1], self.dIE[1], self.sIE[1], self.moveIDs[0], self.pps[0], self.moveIDs[1], self.pps[1], self.moveIDs[2], self.pps[2], self.moveIDs[3], self.pps[3], int(self.owner))

class Party:
    def __init__(
            self, id:int, viewOrder:int, name:str, pokemonID1:int, itemID1:int, pokemonID2:int, itemID2:int,
            pokemonID3:int, itemID3:int, pokemonID4:int, itemID4:int, pokemonID5:int, itemID5:int, pokemonID6:int, itemID6:int, owner:Owner):
        self.id = id
        self.viewOrder = viewOrder
        self.name = name
        self.pokemonID1 = pokemonID1
        self.itemID1 = itemID1
        self.pokemonID2 = pokemonID2
        self.itemID2 = itemID2
        self.pokemonID3 = pokemonID3
        self.itemID3 = itemID3
        self.pokemonID4 = pokemonID4
        self.itemID4 = itemID4
        self.pokemonID5 = pokemonID5
        self.itemID5 = itemID5
        self.pokemonID6 = pokemonID6
        self.itemID6 = itemID6
        self.owner = owner

    def toSet(self):
        return (self.id, self.viewOrder, self.name, self.pokemonID1, self.itemID1, self.pokemonID2, self.itemID2, self.pokemonID3, self.itemID3, self.pokemonID4, self.itemID4, self.pokemonID5, self.itemID5, self.pokemonID6, self.itemID6, int(self.owner))


# SQLiteでintの配列をvalueにした場合の変換方法
IntList = list
sqlite3.register_adapter(IntList, lambda l: ';'.join([str(i) for i in l]))
sqlite3.register_converter("IntList", lambda s: [int(i) for i in s.split(';')])

myPokemons = [
    Pokemon(1, 1, 197, "のろいーブイ", PokeType.ghost, 50,  Sex.male,   Nature.odayaka,  39,  0, [31, 244], [6, 0], [31, 252], [31, 0], [31, 12], [31, 0], [347, 500, 174, 273], [20, 16, 16, 16],  Owner.mine).toSet(),
    Pokemon(2, 2, 136, "げんきーブイ", PokeType.grass, 50,  Sex.male,   Nature.yoki,     62,  0, [31, 4], [31, 252], [31, 0], [8, 0], [31, 0], [31, 252], [394, 851, 885, 263], [15, 16, 20, 20],   Owner.mine).toSet(),
    Pokemon(3, 3, 196, "むすびーブイ", PokeType.fight, 55,  Sex.female, Nature.hikaeme,  156, 0, [31, 4], [10, 0], [31, 0], [31, 252], [31, 0], [31, 252], [94, 851, 247, 447], [16, 16, 15, 20],   Owner.mine).toSet(),
    Pokemon(4, 4, 700, "うたいーブイ", PokeType.fire,  77,  Sex.male,   Nature.hikaeme,  182, 0, [31, 100], [31, 0], [31, 156], [31, 252], [31, 0], [31, 0], [98, 281, 851, 304], [36, 16, 16, 16], Owner.mine).toSet(),
    Pokemon(5, 5, 470, "まいーブイ",   PokeType.rock,  54,  Sex.male,   Nature.ijippari, 34,  0, [31, 184], [31, 232], [31, 0], [23, 0], [31, 4], [31, 88], [14, 73, 348, 851], [20, 16, 24, 16],   Owner.mine).toSet(),
    Pokemon(6, 6, 134, "かたいーブイ", PokeType.normal,75,  Sex.male,   Nature.zubutoi,  11,  0, [31, 212], [28, 0], [31, 236], [31, 12], [31, 20], [31, 28], [57, 151, 347, 156], [24, 20, 20, 5], Owner.mine).toSet(),
    Pokemon(7, 7, 135, "かいひーブイ", PokeType.fly,   100, Sex.female, Nature.okubyou,  10,  0, [31, 244], [31, 0], [31, 12], [31, 0], [31, 0], [31, 252], [189, 86, 164, 226], [16, 16, 15, 20],  Owner.mine).toSet(),
    Pokemon(8, 8, 471, "ドライーブイ", PokeType.ice,   100, Sex.male,   Nature.hikaeme,  81,  0, [31, 100], [7, 0], [31, 4], [31, 252], [31, 132], [31, 20], [573, 59, 247, 341], [20, 8, 15, 15],  Owner.mine).toSet(),
    Pokemon(9, 9, 923, "もこパモ", PokeType.electric,  73, Sex.female,   Nature.yoki,  10,  0, [31, 40], [31, 168], [31, 36], [21, 0], [24, 0], [31, 172], [370, 609, 863, 892], [5, 20, 1, 5],  Owner.mine).toSet(),
    Pokemon(10, 10, 981, "もこキリン", PokeType.fight, 50, Sex.female, Nature.ganbariya, 291, 0, [31, 252], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [888, 304, 97, 851], [10, 10, 30, 10], Owner.mine).toSet(),
    Pokemon(11, 11, 470, "もこフィア", PokeType.fire, 50, Sex.male, Nature.ganbariya, 34, 0, [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [851, 348, 98, 14], [10, 15, 30, 20], Owner.mine).toSet(),
    Pokemon(12, 12, 966, "もこロローム", PokeType.fly, 50, Sex.male, Nature.ganbariya, 111, 0, [31, 4], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [442, 851, 441, 508], [15, 10, 5, 10], Owner.mine).toSet(),
    Pokemon(13, 13, 373, "もこいかくマンダ", PokeType.dragon, 50, Sex.male, Nature.yoki, 22, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [814, 89, 349, 200], [10, 10, 20, 10], Owner.mine).toSet(),
    Pokemon(14, 14, 184, "もこルリ", PokeType.steel, 50, Sex.female, Nature.ganbariya, 37, 0, [31, 204], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [453, 583, 710, 276], [20, 10, 10, 5], Owner.mine).toSet(),
    Pokemon(15, 15, 964, "もこイルカ", PokeType.fly, 75, Sex.female, Nature.ijippari, 278, 0, [31, 252], [31, 252], [31, 0], [31, 0], [31, 0], [31, 4], [812, 512, 857, 834], [20, 15, 15, 10], Owner.mine).toSet(),
    Pokemon(16, 16, 700, "もこニンフィア", PokeType.fairy, 50, Sex.male, Nature.zubutoi, 182, 0, [31, 252], [31, 0], [31, 252], [31, 0], [31, 0], [31, 4], [98, 304, 204, 281], [30, 10, 20, 10], Owner.mine).toSet(),
    Pokemon(17, 17, 229, "もこヘル", PokeType.fairy, 50, Sex.male, Nature.ganbariya, 127, 0, [31, 4], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [53, 885, 894, 851], [15, 20, 10, 10], Owner.mine).toSet(),
    Pokemon(18, 18, 925, "もこネズミ", PokeType.normal, 54, Sex.none, Nature.yoki, 101, 0, [31, 4], [31, 252], [31, 0], [17, 0], [31, 0], [31, 252], [882, 860, 331, 44], [10, 10, 30, 25], Owner.mine).toSet(),
    Pokemon(19, 19, 968, "もこミミズ", PokeType.steel, 52, Sex.female, Nature.namaiki, 297, 0, [31, 252], [31, 0], [31, 4], [17, 0], [31, 252], [0, 0], [446, 880, 317, 89], [20, 10, 15, 10], Owner.mine).toSet(),
    Pokemon(20, 20, 834, "もこリガメ", PokeType.water, 50, Sex.male, Nature.ijippari, 75, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [861, 710, 350, 504], [15, 10, 10, 15], Owner.mine).toSet(),
    Pokemon(21, 21, 184, "もこルリ2", PokeType.steel, 50, Sex.female, Nature.ganbariya, 37, 0, [31, 204], [31, 252], [31, 0], [31, 0], [31, 0], [31, 0], [453, 583, 710, 187], [20, 10, 10, 10], Owner.mine).toSet(),
    Pokemon(22, 22, 936, "もこアルマ", PokeType.fire, 62, Sex.female, Nature.hikaeme, 133, 0, [31, 0], [4, 0], [31, 4], [31, 252], [31, 0], [31, 252], [412, 890, 473, 194], [10, 5, 10, 5], Owner.mine).toSet(),
    Pokemon(23, 23, 982, "もこコッチ", PokeType.normal, 62, Sex.male, Nature.hikaeme, 32, 0, [31, 4], [5, 0], [31, 0], [31, 252], [31, 0], [31, 252], [137, 355, 586, 403], [30, 10, 10, 15], Owner.mine).toSet(),
    Pokemon(24, 24, 961, "もこウミトリオ", PokeType.water, 50, Sex.female, Nature.otonashi, 183, 0, [31, 4], [31, 252], [31, 0], [8, 0], [31, 0], [31, 252], [865, 453, 389, 262], [10, 20, 5, 10], Owner.mine).toSet(),
    Pokemon(25, 25, 10008, "もこヒートロトム", PokeType.evil, 50, Sex.none, Nature.hikaeme, 26, 0, [31, 252], [14, 0], [31, 0], [31, 252], [31, 0], [31, 4], [521, 315, 435, 271], [20, 5, 15, 10], Owner.mine).toSet(),
    Pokemon(26, 26, 934, "もこオーン", PokeType.ghost, 50, Sex.male, Nature.wanpaku, 272, 0, [31, 252], [31, 4], [31, 252], [10, 0], [31, 0], [31, 0], [174, 864, 335, 105], [10, 15, 5, 10], Owner.mine).toSet(),
    Pokemon(27, 27, 976, "もこルーサ", PokeType.evil, 50, Sex.female, Nature.yoki, 292, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [895, 427, 400, 868], [20, 20, 15, 10], Owner.mine).toSet(),
    Pokemon(28, 28, 949, "もこリククラゲ", PokeType.water, 75, Sex.female, Nature.okubyou, 298, 0, [31, 252], [31, 0], [31, 0], [31, 4], [31, 0], [31, 252], [147, 414, 202, 73], [15, 10, 10, 10], Owner.mine).toSet(),
    Pokemon(29, 29, 998, "もこレイブ", PokeType.steel, 75, Sex.female, Nature.yoki, 270, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [333, 862, 442, 349], [30, 5, 15, 20], Owner.mine).toSet(),
    Pokemon(30, 30, 918, "もこイダー", PokeType.ghost, 50, Sex.female, Nature.wanpaku, 15, 0, [31, 252], [31, 0], [31, 252], [14, 0], [31, 4], [31, 0], [564, 852, 389, 262], [20, 10, 5, 10], Owner.mine).toSet(),
    Pokemon(31, 31, 964, "もこイルカ2", PokeType.fly, 75, Sex.female, Nature.ijippari, 278, 0, [31, 252], [31, 252], [31, 0], [31, 0], [31, 0], [31, 4], [370, 512, 857, 834], [5, 15, 15, 10], Owner.mine).toSet(),
    Pokemon(32, 32, 1005, "もこロクツキ", PokeType.evil, 77, Sex.none, Nature.ijippari, 281, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [512, 675, 200, 349], [15, 15, 10, 20], Owner.mine).toSet(),
    Pokemon(33, 33, 978, "もこシャリ", PokeType.fairy, 75, Sex.male, Nature.okubyou, 114, 0, [31, 4], [31, 0], [31, 0], [31, 252], [31, 0], [31, 252], [417, 406, 56, 851], [20, 10, 5, 10], Owner.mine).toSet(),
    Pokemon(34, 34, 475, "もこレイド", PokeType.fight, 50, Sex.male, Nature.yoki, 292, 0, [31, 4], [31, 252], [31, 0], [0, 0], [31, 0], [31, 252], [533, 348, 400, 427], [15, 15, 15, 20], Owner.mine).toSet(),
    Pokemon(35, 35, 229, "もこヘル2", PokeType.fairy, 50, Sex.male, Nature.ganbariya, 127, 0, [31, 4], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [53, 885, 399, 851], [15, 20, 15, 10], Owner.mine).toSet(),
    Pokemon(36, 36, 956, "もこパトラ", PokeType.normal, 50, Sex.male, Nature.okubyou, 3, 0, [31, 56], [31, 0], [31, 100], [31, 0], [31, 100], [31, 252], [855, 226, 347, 297], [10, 40, 20, 15], Owner.mine).toSet(),
    Pokemon(37, 37, 373, "もこ特殊マンダ", PokeType.steel, 50, Sex.female, Nature.ganbariya, 22, 0, [31, 60], [31, 0], [31, 0], [31, 0], [31, 0], [31, 252], [851, 403, 126, 434], [10, 15, 5, 8], Owner.mine).toSet(),
    Pokemon(38, 38, 930, "もこーヴァ", PokeType.fire, 75, Sex.female, Nature.hikaeme, 139, 0, [31, 252], [25, 0], [31, 4], [31, 252], [31, 0], [31, 0], [412, 605, 851, 668], [10, 10, 10, 10], Owner.mine).toSet(),
    Pokemon(39, 39, 324, "もコータス", PokeType.fire, 50, Sex.male, Nature.ganbariya, 70, 0, [31, 252], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [446, 281, 499, 315], [20, 10, 15, 5], Owner.mine).toSet(),
    Pokemon(40, 40, 908, "もこカーニャ", PokeType.grass, 52, Sex.female, Nature.yoki, 168, 0, [31, 4], [31, 252], [31, 0], [13, 0], [31, 0], [31, 252], [369, 870, 583, 282], [20, 10, 10, 20], Owner.mine).toSet(),
    Pokemon(41, 41, 918, "もこイダー2", PokeType.ghost, 50, Sex.female, Nature.wanpaku, 15, 0, [31, 252], [31, 0], [31, 252], [14, 0], [31, 4], [31, 0], [564, 806, 509, 262], [20, 10, 10, 10], Owner.mine).toSet(),
    Pokemon(42, 42, 229, "ねつじょう", PokeType.evil, 50, Sex.male, Nature.hikaeme, 18, 0, [31, 4], [31, 0], [31, 0], [31, 252], [31, 0], [31, 252], [53, 399, 389, 194], [15, 15, 5, 5], Owner.mine).toSet(),
    Pokemon(43, 43, 914, "もこニバル", PokeType.dragon, 50, Sex.female, Nature.yoki, 153, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [339, 370, 861, 872], [20, 5, 15, 10], Owner.mine).toSet(),
    Pokemon(44, 44, 973, "もこミンゴ", PokeType.fight, 54, Sex.male, Nature.yoki, 113, 0, [31, 0], [31, 252], [31, 4], [15, 0], [31, 0], [31, 252], [370, 413, 14, 269], [5, 15, 20, 20], Owner.mine).toSet(),
    Pokemon(45, 45, 199, "もこヤドキング", PokeType.electric, 75, Sex.male, Nature.zubutoi, 144, 0, [31, 244], [4, 0], [31, 252], [31, 12], [31, 0], [31, 0], [881, 57, 281, 851], [10, 15, 10, 10], Owner.mine).toSet(),
    Pokemon(46, 46, 975, "もこハルクジラ", PokeType.water, 50, Sex.female, Nature.yoki, 202, 0, [31, 4], [31, 4], [31, 124], [18, 0], [31, 124], [31, 252], [187, 556, 710, 89], [10, 10, 10, 10], Owner.mine).toSet(),
    Pokemon(47, 47, 967, "もこうトカゲ", PokeType.normal, 51, Sex.male, Nature.ijippari, 144, 0, [31, 4], [31, 252], [31, 0], [17, 0], [29, 0], [31, 252], [508, 880, 282, 38], [10, 10, 20, 15], Owner.mine).toSet(),
    Pokemon(48, 48, 920, "もこレッグ", PokeType.bug, 50, Sex.male, Nature.ijippari, 110, 0, [31, 228], [31, 252], [31, 0], [0, 0], [31, 0], [31, 28], [660, 369, 389, 269], [10, 20, 5, 20], Owner.mine).toSet(),
    Pokemon(49, 49, 398, "もこホーク", PokeType.fight, 75, Sex.male, Nature.ijippari, 120, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [370, 413, 38, 98], [5, 15, 15, 30], Owner.mine).toSet(),
    Pokemon(50, 50, 947, "もこホラグサ", PokeType.grass, 55, Sex.male, Nature.ijippari, 274, 0, [31, 4], [31, 252], [31, 0], [17, 0], [31, 0], [31, 252], [438, 174, 668, 425], [10, 10, 10, 30], Owner.mine).toSet(),
    Pokemon(51, 51, 663, "もこアロー", PokeType.ghost, 75, Sex.male, Nature.zubutoi, 177, 0, [31, 252], [31, 0], [31, 252], [31, 0], [31, 0], [31, 4], [366, 261, 542, 355], [15, 15, 10, 10], Owner.mine).toSet(),
    Pokemon(52, 52, 939, "もこバリー", PokeType.grass, 50, Sex.male, Nature.hikaeme, 280, 0, [31, 252], [2, 0], [31, 0], [31, 236], [31, 0], [31, 20], [570, 487, 851, 491], [20, 20, 10, 20], Owner.mine).toSet(),
    Pokemon(53, 53, 975, "もこハルクジラ2", PokeType.water, 50, Sex.female, Nature.yoki, 202, 0, [31, 4], [31, 4], [31, 124], [18, 0], [31, 124], [31, 252], [187, 861, 710, 89], [10, 15, 10, 10], Owner.mine).toSet(),
    Pokemon(54, 54, 217, "もこリングマ", PokeType.ghost, 50, Sex.female, Nature.ijippari, 62, 0, [31, 204], [31, 252], [31, 0], [31, 0], [31, 0], [31, 52], [34, 583, 421, 89], [15, 10, 15, 10], Owner.mine).toSet(),
    Pokemon(55, 55, 217, "もこリングマ2", PokeType.ghost, 50, Sex.female, Nature.ijippari, 62, 0, [31, 204], [31, 252], [31, 0], [31, 0], [31, 0], [31, 52], [34, 583, 421, 14], [15, 10, 15, 20], Owner.mine).toSet(),
    Pokemon(56, 56, 972, "もこドッグ", PokeType.ghost, 63, Sex.male, Nature.ijippari, 218, 0, [31, 252], [31, 252], [31, 4], [18, 0], [31, 0], [31, 0], [707, 854, 425, 583], [10, 10, 30, 10], Owner.mine).toSet(),
    Pokemon(57, 57, 931, "もこリンコ", PokeType.fly, 50, Sex.male, Nature.yoki, 55, 0, [31, 0], [31, 252], [31, 4], [8, 0], [31, 0], [31, 252], [383, 413, 38, 575], [20, 15, 15, 20], Owner.mine).toSet(),
    Pokemon(58, 58, 373, "もこ両刀マンダ", PokeType.steel, 50, Sex.female, Nature.ganbariya, 22, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [349, 126, 89, 814], [20, 5, 10, 10], Owner.mine).toSet(),
    Pokemon(59, 59, 931, "もこリンコ2", PokeType.fly, 50, Sex.male, Nature.yoki, 55, 0, [31, 0], [31, 252], [31, 4], [8, 0], [31, 0], [31, 252], [383, 413, 38, 575], [10, 15, 15, 20], Owner.mine).toSet(),
    Pokemon(60, 60, 10123, "もこリドリ", PokeType.fairy, 50, Sex.male, Nature.okubyou, 216, 0, [31, 4], [14, 0], [31, 0], [31, 252], [31, 0], [31, 252], [686, 403, 355, 483], [15, 15, 8, 20], Owner.mine).toSet(),
    Pokemon(61, 61, 612, "もこノクス", PokeType.bug, 75, Sex.female, Nature.yoki, 104, 0, [31, 60], [31, 196], [31, 0], [31, 0], [31, 0], [31, 252], [349, 200, 89, 660], [20, 10, 10, 10], Owner.mine).toSet(),
    Pokemon(62, 62, 952, "もこヴィラン", PokeType.ghost, 50, Sex.female, Nature.ukariya, 34, 0, [31, 0], [31, 4], [31, 0], [31, 252], [31, 0], [31, 252], [315, 76, 851, 707], [8, 10, 10, 10], Owner.mine).toSet(),
    Pokemon(63, 63, 962, "もこシドリ", PokeType.rock, 76, Sex.male, Nature.yoki, 276, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [444, 814, 282, 575], [8, 10, 20, 20], Owner.mine).toSet(),
    Pokemon(64, 64, 196, "もこエーフィ", PokeType.psychic, 76, Sex.male, Nature.okubyou, 156, 0, [31, 4], [3, 0], [31, 0], [31, 252], [31, 0], [31, 252], [94, 605, 447, 271], [10, 10, 20, 10], Owner.mine).toSet(),
    Pokemon(65, 65, 419, "もこーゼル", PokeType.water, 62, Sex.male, Nature.yancha, 33, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [834, 56, 214, None], [10, 5, 10, 0], Owner.mine).toSet(),
    Pokemon(66, 66, 205, "もこレトス", PokeType.water, 50, Sex.male, Nature.ganbariya, 5, 0, [31, 252], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [446, 240, 153, 521], [20, 5, 5, 20], Owner.mine).toSet(),
    Pokemon(67, 67, 950, "もこガニ", PokeType.grass, 56, Sex.female, Nature.yoki, 271, 0, [31, 4], [31, 252], [31, 0], [22, 0], [31, 0], [31, 252], [14, 350, 667, 12], [20, 10, 10, 8], Owner.mine).toSet(),
    Pokemon(68, 68, 10186, "もこッサン", PokeType.poison, 50, Sex.female, Nature.ganbariya, 227, 0, [31, 252], [31, 0], [31, 0], [31, 0], [31, 0], [31, 0], [94, 113, 115, 433], [10, 30, 20, 5], Owner.mine).toSet(),
    Pokemon(69, 69, 184, "もこ炎マリルリ", PokeType.fire, 50, Sex.male, Nature.ganbariya, 37, 0, [31, 204], [31, 252], [31, 0], [31, 0], [31, 0], [31, 0], [710, 453, 583, 851], [10, 20, 10, 10], Owner.mine).toSet(),
    Pokemon(70, 70, 937, "もこブレイズ", PokeType.grass, 50, Sex.male, Nature.ijippari, 18, 0, [31, 252], [31, 236], [31, 0], [31, 0], [31, 0], [31, 20], [339, 891, 851, 425], [20, 10, 10, 30], Owner.mine).toSet(),
    Pokemon(71, 71, 700, "もこニンフィア2", PokeType.fairy, 50, Sex.male, Nature.zubutoi, 182, 0, [31, 252], [31, 0], [31, 252], [31, 0], [31, 0], [31, 4], [98, 304, 113, 281], [30, 10, 30, 10], Owner.mine).toSet(),
    Pokemon(72, 72, 970, "オモダカさん", PokeType.fly, 75, Sex.female, Nature.okubyou, 295, 0, [31, 4], [31, 0], [31, 0], [31, 252], [31, 0], [31, 252], [408, 482, 605, 414], [20, 10, 10, 10], Owner.mine).toSet(),
    Pokemon(73, 73, 855, "もこトデス", PokeType.fight, 75, Sex.none, Nature.hikaeme, 133, 0, [31, 100], [31, 0], [31, 0], [31, 220], [31, 0], [31, 188], [247, 500, 851, 504], [15, 10, 10, 15], Owner.mine).toSet(),
    Pokemon(74, 74, 673, "もこーゴート", PokeType.water, 60, Sex.male, Nature.ijippari, 157, 0, [31, 104], [31, 252], [31, 148], [31, 0], [31, 4], [31, 0], [339, 532, 89, 528], [20, 16, 10, 15], Owner.mine).toSet(),
    Pokemon(75, 75, 941, "もこカイデン", PokeType.ice, 55, Sex.male, Nature.okubyou, 10, 0, [31, 0], [0, 0], [31, 4], [31, 252], [31, 0], [31, 252], [521, 85, 851, 542], [20, 15, 10, 10], Owner.mine).toSet(),
    Pokemon(76, 76, 130, "もこギャラドス", PokeType.ground, 50, Sex.male, Nature.ijippari, 22, 0, [31, 164], [31, 252], [31, 0], [31, 0], [31, 0], [31, 92], [269, 349, 127, 89], [20, 20, 15, 10], Owner.mine).toSet(),
    Pokemon(77, 77, 214, "もこクロス", PokeType.bug, 53, Sex.male, Nature.yoki, 153, 0, [31, 4], [31, 252], [31, 0], [9, 0], [31, 0], [31, 252], [42, 331, 350, 280], [20, 30, 10, 15], Owner.mine).toSet(),
    Pokemon(78, 78, 956, "もこパトラ2", PokeType.normal, 50, Sex.male, Nature.okubyou, 3, 0, [31, 56], [31, 0], [31, 100], [31, 0], [31, 100], [31, 252], [855, 226, 297, 95], [10, 40, 15, 20], Owner.mine).toSet(),
    Pokemon(79, 79, 936, "もこアルマ2", PokeType.fire, 62, Sex.female, Nature.hikaeme, 133, 0, [31, 0], [4, 0], [31, 4], [31, 252], [31, 0], [31, 252], [678, 890, 797, 194], [10, 5, 10, 5], Owner.mine).toSet(),
    Pokemon(80, 80, 214, "もこクロス2", PokeType.bug, 53, Sex.male, Nature.yoki, 62, 0, [31, 4], [31, 252], [31, 0], [9, 0], [31, 0], [31, 252], [42, 331, 350, 280], [20, 30, 10, 15], Owner.mine).toSet(),
    Pokemon(87, 87, 149, "もこカイリュー", PokeType.fly, 61, Sex.female, Nature.ijippari, 136, 0, [31, 228], [31, 204], [31, 0], [9, 0], [31, 0], [31, 76], [227, 349, 851, 89], [5, 20, 10, 10], Owner.mine).toSet(),
    Pokemon(88, 88, 943, "もこティフ", PokeType.fairy, 75, Sex.female, Nature.ijippari, 198, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [746, 583, 269, 194], [10, 10, 20, 5], Owner.mine).toSet(),
    Pokemon(89, 89, 212, "もこハッサム", PokeType.fire, 75, Sex.male, Nature.ijippari, 101, 0, [31, 204], [31, 68], [31, 4], [31, 0], [31, 4], [31, 228], [418, 168, 885, 14], [30, 25, 20, 20], Owner.mine).toSet(),
    Pokemon(90, 90, 849, "おとこ", PokeType.normal, 75, Sex.male, Nature.hikaeme, 244, 0, [31, 156], [31, 0], [31, 4], [31, 244], [31, 4], [31, 100], [786, 409, 508, 586], [10, 10, 10, 16], Owner.mine).toSet(),
    Pokemon(91, 91, 740, "もこンカニ", PokeType.water, 50, Sex.female, Nature.ijippari, 89, 0, [31, 232], [31, 60], [31, 100], [2, 0], [31, 116], [31, 0], [665, 409, 710, 339], [10, 16, 10, 20], Owner.mine).toSet(),
    Pokemon(92, 92, 700, "もこニンフィア3", PokeType.fire, 50, Sex.male, Nature.zubutoi, 182, 0, [31, 252], [31, 0], [31, 252], [31, 0], [31, 0], [31, 4], [98, 304, 113, 281], [30, 10, 30, 10], Owner.mine).toSet(),
    Pokemon(93, 93, 954, "もこカス", PokeType.normal, 50, Sex.male, Nature.reisei, 28, 0, [31, 252], [31, 0], [31, 4], [31, 252], [31, 0], [31, 0], [405, 473, 863, 433], [10, 10, 1, 5], Owner.mine).toSet(),
    Pokemon(94, 94, 740, "もこンカニ2", PokeType.electric, 50, Sex.female, Nature.ijippari, 89, 0, [31, 232], [31, 60], [31, 100], [2, 0], [31, 116], [31, 0], [665, 409, 710, 9], [10, 16, 10, 15], Owner.mine).toSet(),
    Pokemon(95, 95, 910, "もこゲータ", PokeType.water, 50, Sex.male, Nature.zubutoi, 109, 0, [31, 252], [31, 0], [31, 252], [31, 0], [31, 4], [31, 0], [281, 83, 303, 227], [10, 18, 8, 8], Owner.mine).toSet(),
    Pokemon(96, 96, 136, "もこブースター", PokeType.normal, 50, Sex.male, Nature.yoki, 62, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [885, 263, 394, 98], [20, 20, 15, 30], Owner.mine).toSet(),
    Pokemon(97, 97, 959, "カヌぎゃく", PokeType.ground, 75, Sex.female, Nature.yoki, 104, 0, [31, 4], [31, 252], [31, 0], [31, 0], [31, 0], [31, 252], [893, 583, 851, 227], [8, 10, 10, 5], Owner.mine).toSet(),
    Pokemon(98, 98, 297, "もこテヤマ", PokeType.steel, 60, Sex.male, Nature.ijippari, 62, 0, [31, 12], [31, 236], [31, 172], [0, 0], [31, 84], [31, 4], [252, 838, 409, 418], [10, 7, 16, 30], Owner.mine).toSet()
]

parties = [
    Party(1, 1, "ブイズ", 1, 211, 2, 250, 3, 245, 4, 135, 5, 247, 6, 127, Owner.mine).toSet(),
    Party(2, 2, "1もこパーモット", 9, 252, 10, 135, 11, 247, 12, 134, 13, 1698, 14, 683, Owner.mine).toSet(),
    Party(3, 3, "2もこイルカマン", 11, 247, 12, 134, 13, 1698, 15, 135, 16, 190, 17, 252, Owner.mine).toSet(),
    Party(4, 4, "3もこネズミ", 13, 1698, 14, 683, 9, 252, 16, 190, 10, 135, 18, 242, Owner.mine).toSet(),
    Party(5, 5, "4もこミミズ", 13, 1698, 14, 683, 16, 190, 19, 135, 20, 247, 17, 252, Owner.mine).toSet(),
    Party(6, 6, "4もこミミズ2", 13, 1698, 16, 190, 19, 135, 20, 247, 17, 252, 21, 243, Owner.mine).toSet(),
    Party(7, 7, "5もこアルマ", 13, 1698, 16, 190, 11, 247, 22, 252, 15, 135, 18, 242, Owner.mine).toSet(),
    Party(8, 8, "6もこコッチ", 23, 1699, 15, 135, 11, 247, 9, 252, 13, 1698, 16, 190, Owner.mine).toSet(),
    Party(9, 9, "7もこウミトリオ", 12, 134, 13, 1698, 16, 190, 25, 274, 24, 252, 18, 242, Owner.mine).toSet(),
    Party(10, 10, "7もこウミトリオ2", 13, 1698, 16, 190, 25, 274, 24, 252, 18, 242, 20, 134, Owner.mine).toSet(),
    Party(11, 11, "8もこオーン", 13, 1698, 16, 190, 22, 252, 26, 211, 21, 220, 18, 242, Owner.mine).toSet(),
    Party(12, 12, "9もこルーサ", 16, 190, 18, 242, 27, 135, 19, 196, 13, 1698, 12, 134, Owner.mine).toSet(),
    Party(13, 13, "9もこルーサ2", 16, 190, 18, 242, 27, 209, 19, 135, 13, 1698, 12, 134, Owner.mine).toSet(),
    Party(14, 14, "9もこルーサ3", 16, 190, 18, 242, 27, 135, 19, 196, 13, 1698, 17, 252, Owner.mine).toSet(),
    Party(15, 15, "10もこリククラゲ", 21, 220, 25, 274, 28, 135, 12, 134, 11, 247, 26, 211, Owner.mine).toSet(),
    Party(16, 16, "11もこレイブ", 21, 220, 25, 274, 29, 134, 9, 252, 19, 135, 11, 247, Owner.mine).toSet(),
    Party(17, 17, "12もこイダー", 29, 134, 18, 242, 31, 1177, 30, 196, 11, 247, 35, 252, Owner.mine).toSet(),
    Party(18, 18, "13もこロクツキ", 32, 1696, 13, 134, 25, 274, 30, 196, 19, 135, 28, 273, Owner.mine).toSet(),
    Party(19, 19, "14もこシャリ", 25, 274, 28, 273, 30, 196, 33, 247, 13, 134, 26, 211, Owner.mine).toSet(),
    Party(20, 20, "14もこシャリ2", 28, 273, 33, 247, 13, 134, 26, 211, 30, 196, 18, 242, Owner.mine).toSet(),
    Party(21, 21, "15もこレイド", 13, 134, 34, 264, 28, 273, 35, 252, 14, 683, 26, 211, Owner.mine).toSet(),
    Party(22, 22, "16もこパトラ", 37, 191, 33, 247, 14, 683, 26, 211, 36, 196, 28, 273, Owner.mine).toSet(),
    Party(23, 23, "17もこーヴァ", 39, 1177, 11, 247, 29, 1698, 14, 683, 38, 135, 34, 264, Owner.mine).toSet(),
    Party(24, 24, "17もこーヴァ2", 39, 1177, 11, 247, 29, 1698, 14, 683, 38, 135, 35, 252, Owner.mine).toSet(),
    Party(25, 25, "18もこカーニャ", 37, 191, 42, 252, 41, 196, 26, 211, 14, 683, 40, 197, Owner.mine).toSet(),
    Party(26, 26, "19もこニバル", 42, 252, 43, 134, 26, 211, 38, 135, 13, 1698, 16, 190, Owner.mine).toSet(),
    Party(27, 27, "19もこニバル2", 26, 211, 13, 1698, 42, 252, 43, 134, 19, 135, 16, 190, Owner.mine).toSet(),
    Party(28, 28, "20もこミンゴ", 37, 264, 14, 683, 26, 211, 44, 247, 16, 190, 38, 135, Owner.mine).toSet(),
    Party(29, 29, "20もこミンゴ2", 29, 134, 44, 247, 18, 242, 26, 211, 37, 264, 16, 190, Owner.mine).toSet(),
    Party(30, 30, "21もこクジラ", 37, 264, 26, 211, 46, 135, 25, 274, 28, 273, 45, 196, Owner.mine).toSet(),
    Party(31, 31, "22もこトカゲ", 16, 190, 47, 135, 42, 252, 20, 247, 12, 134, 21, 683, Owner.mine).toSet(),
    Party(32, 32, "22もこトカゲ2", 16, 190, 47, 135, 42, 252, 20, 247, 12, 134, 34, 264, Owner.mine).toSet(),
    Party(33, 33, "23もこレッグ", 13, 1698, 14, 683, 48, 247, 38, 135, 34, 264, 42, 252, Owner.mine).toSet(),
    Party(34, 34, "24もこホーク", 13, 1698, 42, 252, 14, 683, 19, 196, 38, 135, 49, 247, Owner.mine).toSet(),
    Party(36, 36, "25もこホラグサ", 37, 264, 14, 683, 42, 252, 50, 247, 51, 590, 29, 134, Owner.mine).toSet(),
    Party(37, 37, "25もこホラグサ2", 37, 264, 16, 190, 50, 247, 51, 590, 29, 134, 26, 211, Owner.mine).toSet(),
    Party(38, 38, "25もこホラグサ3", 37, 264, 46, 135, 45, 196, 51, 590, 16, 190, 50, 247, Owner.mine).toSet(),
    Party(39, 39, "26もこバリー", 34, 264, 45, 196, 42, 252, 28, 273, 52, 584, 46, 135, Owner.mine).toSet(),
    Party(40, 40, "26もこバリー2", 34, 264, 45, 196, 42, 252, 53, 135, 52, 247, 26, 211, Owner.mine).toSet(),
    Party(41, 41, "27もこリングマ", 37, 264, 19, 135, 36, 190, 33, 690, 14, 683, 54, 581, Owner.mine).toSet(),
    Party(42, 42, "27もこリングマ2", 37, 264, 19, 135, 36, 190, 33, 690, 55, 581, 14, 683, Owner.mine).toSet(),
    Party(43, 43, "28もこドッグ", 42, 252, 38, 135, 14, 683, 56, 682, 37, 264, 48, 247, Owner.mine).toSet(),
    Party(44, 44, "29もこリンコ", 42, 252, 14, 683, 58, 247, 43, 134, 57, 264, 12, 135, Owner.mine).toSet(),
    Party(45, 45, "29もこリンコ2", 42, 252, 14, 683, 58, 247, 59, 264, 43, 134, 27, 135, Owner.mine).toSet(),
    Party(46, 46, "30もこリドリ", 14, 683, 54, 581, 58, 247, 40, 197, 60, 134, 22, 252, Owner.mine).toSet(),
    Party(47, 47, "28もこドッグ2", 42, 252, 14, 683, 56, 682, 37, 264, 48, 247, 40, 197, Owner.mine).toSet(),
    Party(48, 48, "31もこノクス", 14, 683, 54, 581, 61, 134, 22, 252, 58, 247, 47, 135, Owner.mine).toSet(),
    Party(49, 49, "31もこノクス2", 14, 683, 54, 581, 61, 247, 22, 252, 47, 135, 25, 274, Owner.mine).toSet(),
    Party(50, 50, "32もこヴィラン", 34, 264, 39, 1177, 45, 196, 53, 135, 13, 134, 62, 247, Owner.mine).toSet(),
    Party(51, 51, "33もこシドリ", 58, 247, 40, 197, 43, 134, 60, 1699, 63, 264, 22, 252, Owner.mine).toSet(),
    Party(52, 52, "34もこエーフィ", 14, 683, 42, 252, 64, 274, 58, 247, 48, 197, 26, 211, Owner.mine).toSet(),
    Party(53, 53, "35もこーゼル", 37, 264, 66, 262, 38, 135, 65, 197, 22, 252, 16, 583, Owner.mine).toSet(),
    Party(54, 54, "35もこーゼル2", 37, 264, 66, 262, 65, 197, 22, 252, 16, 583, 12, 135, Owner.mine).toSet(),
    Party(55, 55, "36もこガニ", 55, 581, 68, 896, 14, 683, 52, 219, 58, 247, 67, 1702, Owner.mine).toSet(),
    Party(56, 56, "37もこブレイズ", 52, 219, 58, 247, 70, 134, 71, 583, 40, 197, 63, 264, Owner.mine).toSet(),
    Party(57, 57, "38もこフロル", 42, 252, 72, 264, 58, 247, 65, 197, 66, 262, 69, 683, Owner.mine).toSet(),
    Party(58, 58, "39もこトデス", 43, 134, 68, 896, 58, 247, 25, 274, 73, 252, 71, 583, Owner.mine).toSet(),
    Party(59, 59, "39もこトデス2", 43, 134, 68, 896, 58, 247, 25, 274, 73, 252, 19, 135, Owner.mine).toSet(),
    Party(60, 60, "40もこーゴート", 52, 219, 58, 247, 25, 274, 74, 134, 72, 264, 71, 583, Owner.mine).toSet(),
    Party(61, 61, "40もこーゴート2", 58, 247, 74, 134, 72, 264, 71, 583, 31, 1177, 69, 683, Owner.mine).toSet(),
    Party(62, 62, "24もこホーク2", 42, 252, 14, 683, 38, 135, 37, 264, 26, 211, 49, 247, Owner.mine).toSet(),
    Party(63, 63, "41もこカイデン", 53, 135, 75, 274, 73, 252, 14, 683, 58, 247, 45, 196, Owner.mine).toSet(),
    Party(64, 64, "41もこカイデン2", 53, 135, 75, 274, 58, 247, 14, 683, 45, 196, 48, 197, Owner.mine).toSet(),
    Party(65, 65, "41もこカイデン3", 53, 135, 75, 274, 58, 247, 45, 196, 48, 197, 72, 264, Owner.mine).toSet(),
    Party(66, 66, "42もこギャラドス", 72, 264, 76, 135, 62, 247, 39, 1177, 71, 583, 9, 252, Owner.mine).toSet(),
    Party(68, 68, "43もこクロス2", 58, 247, 77, 1702, 78, 1699, 40, 197, 69, 683, 79, 252, Owner.mine).toSet(),
    Party(69, 69, "44もこカイリュー", 40, 197, 69, 683, 79, 252, 58, 247, 72, 264, 87, 211, Owner.mine).toSet(),
    Party(70, 70, "45もこティフ", 29, 1702, 71, 583, 70, 134, 64, 274, 72, 264, 88, 723, Owner.mine).toSet(),
    Party(71, 71, "46もこハッサム", 71, 583, 89, 135, 42, 252, 60, 134, 69, 683, 87, 211, Owner.mine).toSet(),
    Party(72, 72, "47もこリンダー", 58, 247, 88, 723, 79, 252, 71, 583, 90, 1176, 28, 273, Owner.mine).toSet(),
    Party(73, 73, "48もこンカニ", 58, 247, 91, 135, 92, 583, 64, 274, 9, 252, 59, 264, Owner.mine).toSet(),
    Party(74, 74, "48もこンカニ2", 58, 247, 91, 134, 92, 583, 64, 274, 9, 252, 59, 264, Owner.mine).toSet(),
    Party(75, 75, "49もこカス", 42, 252, 69, 683, 93, 135, 94, 247, 25, 274, 40, 197, Owner.mine).toSet(),
    Party(76, 76, "50もこゲータ", 58, 247, 92, 583, 64, 274, 9, 252, 59, 264, 95, 581, Owner.mine).toSet(),
    Party(77, 77, "50もこゲータ2", 58, 247, 92, 583, 64, 274, 9, 252, 95, 581, 40, 197, Owner.mine).toSet(),
    Party(78, 78, "51もこブースター", 96, 250, 42, 252, 69, 683, 87, 211, 52, 219, 47, 135, Owner.mine).toSet(),
    Party(79, 79, "52もこヌチャン", 92, 583, 9, 252, 10, 250, 76, 135, 97, 247, 74, 134, Owner.mine).toSet(),
    Party(80, 80, "52もこヌチャン2", 92, 583, 97, 247, 9, 252, 40, 197, 25, 274, 76, 135, Owner.mine).toSet(),
    Party(81, 81, "53もこテヤマ", 58, 264, 79, 252, 98, 250, 69, 683, 93, 135, 40, 197, Owner.mine).toSet()
]

def set_argparse():
    parser = argparse.ArgumentParser(description='ユーザ作成データをsqliteファイルに保存する')
    parser.add_argument('-o', '--output', required=False, default=preparedDBFile, help='出力先ファイル名')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    db_path = Path.cwd().joinpath(args.output)
    conn = sqlite3.connect(db_path)
    con = conn.cursor()

    # 登録したポケモン
    # 読み込み
    try:
        # テーブルがあれば削除
        con.execute(f'DROP TABLE {myPokemonDBTable}')
        print('[myPokemon]deleted existing table')
    except sqlite3.OperationalError:
        print('[myPokemon]could not find exisiting table')

    # 作成
    try:
        con.execute(
        f'CREATE TABLE {myPokemonDBTable} ('
        f'  {myPokemonColumnId} INTEGER PRIMARY KEY, '
        f'  {myPokemonColumnViewOrder} INTEGER, '
        f'  {myPokemonColumnNo} INTEGER, '
        f'  {myPokemonColumnNickName} TEXT, '
        f'  {myPokemonColumnTeraType} INTEGER, '
        f'  {myPokemonColumnLevel} INTEGER, '
        f'  {myPokemonColumnSex} INTEGER, '
        f'  {myPokemonColumnNature} INTEGER, '
        f'  {myPokemonColumnAbility} INTEGER, '
        f'  {myPokemonColumnItem} INTEGER, '
        f'  {myPokemonColumnIndividual[0]} INTEGER, '
        f'  {myPokemonColumnIndividual[1]} INTEGER, '
        f'  {myPokemonColumnIndividual[2]} INTEGER, '
        f'  {myPokemonColumnIndividual[3]} INTEGER, '
        f'  {myPokemonColumnIndividual[4]} INTEGER, '
        f'  {myPokemonColumnIndividual[5]} INTEGER, '
        f'  {myPokemonColumnEffort[0]} INTEGER, '
        f'  {myPokemonColumnEffort[1]} INTEGER, '
        f'  {myPokemonColumnEffort[2]} INTEGER, '
        f'  {myPokemonColumnEffort[3]} INTEGER, '
        f'  {myPokemonColumnEffort[4]} INTEGER, '
        f'  {myPokemonColumnEffort[5]} INTEGER, '
        f'  {myPokemonColumnMove1} INTEGER, '
        f'  {myPokemonColumnPP1} INTEGER, '
        f'  {myPokemonColumnMove2} INTEGER, '
        f'  {myPokemonColumnPP2} INTEGER, '
        f'  {myPokemonColumnMove3} INTEGER, '
        f'  {myPokemonColumnPP3} INTEGER, '
        f'  {myPokemonColumnMove4} INTEGER, '
        f'  {myPokemonColumnPP4} INTEGER, '
        f'  {myPokemonColumnOwnerID} INTEGER)'
        )
        print('[myPokemon]created table')
    except sqlite3.OperationalError:
        print('[myPokemon]failed to create table')

    # 挿入
    try:
        con.executemany(
            f'INSERT INTO {myPokemonDBTable} ('
            f'{myPokemonColumnId}, {myPokemonColumnViewOrder}, {myPokemonColumnNo}, {myPokemonColumnNickName}, '
            f'{myPokemonColumnTeraType}, {myPokemonColumnLevel}, {myPokemonColumnSex}, {myPokemonColumnNature}, '
            f'{myPokemonColumnAbility}, {myPokemonColumnItem}, {myPokemonColumnIndividual[0]}, {myPokemonColumnIndividual[1]}, '
            f'{myPokemonColumnIndividual[2]}, {myPokemonColumnIndividual[3]}, {myPokemonColumnIndividual[4]}, '
            f'{myPokemonColumnIndividual[5]}, {myPokemonColumnEffort[0]}, {myPokemonColumnEffort[1]}, {myPokemonColumnEffort[2]}, '
            f'{myPokemonColumnEffort[3]}, {myPokemonColumnEffort[4]}, {myPokemonColumnEffort[5]}, {myPokemonColumnMove1}, '
            f'{myPokemonColumnPP1}, {myPokemonColumnMove2}, {myPokemonColumnPP2}, {myPokemonColumnMove3}, {myPokemonColumnPP3}, '
            f'{myPokemonColumnMove4}, {myPokemonColumnPP4}, {myPokemonColumnOwnerID})'
            f'VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
            myPokemons)
        print('[myPokemon]inserted data')
    except sqlite3.OperationalError:
        print('[myPokemon]failed to insert table')

    #################################

    # 登録したパーティ
    # 読み込み
    try:
        # テーブルがあれば削除
        con.execute(f'DROP TABLE {partyDBTable}')
        print('[party]deleted existing table')
    except sqlite3.OperationalError:
        print('[party]could not find exisiting table')

    # 作成
    try:
        con.execute(
        f'CREATE TABLE {partyDBTable} ('
        f'  {partyColumnId} INTEGER PRIMARY KEY, '
        f'  {partyColumnViewOrder} INTEGER, '
        f'  {partyColumnName} TEXT, '
        f'  {partyColumnPokemonId1} INTEGER, '
        f'  {partyColumnPokemonItem1} INTEGER, '
        f'  {partyColumnPokemonId2} INTEGER, '
        f'  {partyColumnPokemonItem2} INTEGER, '
        f'  {partyColumnPokemonId3} INTEGER, '
        f'  {partyColumnPokemonItem3} INTEGER, '
        f'  {partyColumnPokemonId4} INTEGER, '
        f'  {partyColumnPokemonItem4} INTEGER, '
        f'  {partyColumnPokemonId5} INTEGER, '
        f'  {partyColumnPokemonItem5} INTEGER, '
        f'  {partyColumnPokemonId6} INTEGER, '
        f'  {partyColumnPokemonItem6} INTEGER, '
        f'  {partyColumnOwnerID} INTEGER)'
        )
        print('[party]created table')
    except sqlite3.OperationalError:
        print('[party]failed to create table')

    # 挿入
    try:
        con.executemany(
            f'INSERT INTO {partyDBTable} ('
            f'{partyColumnId}, {partyColumnViewOrder}, {partyColumnName}, '
            f'{partyColumnPokemonId1}, {partyColumnPokemonItem1}, {partyColumnPokemonId2}, {partyColumnPokemonItem2}, '
            f'{partyColumnPokemonId3}, {partyColumnPokemonItem3}, {partyColumnPokemonId4}, {partyColumnPokemonItem4}, '
            f'{partyColumnPokemonId5}, {partyColumnPokemonItem5}, {partyColumnPokemonId6}, {partyColumnPokemonItem6}, {partyColumnOwnerID})'
            f'VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
            parties)
        print('[party]inserted data')
    except sqlite3.OperationalError:
        print('[party]failed to insert table')

    conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
