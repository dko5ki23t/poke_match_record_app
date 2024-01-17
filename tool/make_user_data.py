import sqlite3
from enum import IntEnum

###### ユーザが登録するデータをSQLテーブルとして保存する ######

# 保存先SQLiteの各種名前
myPokemonDBFile = 'MyPokemons.db'
myPokemonDBTable = 'myPokemonDB'
myPokemonColumnId = 'id'
myPokemonColumnViewOrder = 'viewOrder'
myPokemonColumnNo = 'no'
myPokemonColumnNickName = 'nickname'
myPokemonColumnTeraType = 'teratype'
myPokemonColumnLevel = 'level'
myPokemonColumnSex = 'sex'
myPokemonColumnTemper = 'temper'
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


partyDBFile = 'parties.db'
partyDBTable = 'partyDB'
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

class Temper(IntEnum):
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
            temper:Temper, abilityID:int, itemID:int, hIE:list, aIE:list, bIE:list, cIE:list, dIE:list, sIE:list, moveIDs:list,
            pps:list, owner:Owner):
        self.id = id
        self.viewOrder = viewOrder
        self.no = no
        self.nickname = nickname
        self.teraType = teraType
        self.level = level
        self.sex = sex
        self.temper = temper
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
        return (self.id, self.viewOrder, self.no, self.nickname, int(self.teraType), self.level, int(self.sex), int(self.temper), self.abilityID, self.itemID, self.hIE[0], self.aIE[0], self.bIE[0], self.cIE[0], self.dIE[0], self.sIE[0], self.hIE[1], self.aIE[1], self.bIE[1], self.cIE[1], self.dIE[1], self.sIE[1], self.moveIDs[0], self.pps[0], self.moveIDs[1], self.pps[1], self.moveIDs[2], self.pps[2], self.moveIDs[3], self.pps[3], int(self.owner))

# SQLiteでintの配列をvalueにした場合の変換方法
IntList = list
sqlite3.register_adapter(IntList, lambda l: ';'.join([str(i) for i in l]))
sqlite3.register_converter("IntList", lambda s: [int(i) for i in s.split(';')])

def main():
    # 登録したポケモン
    conn = sqlite3.connect(myPokemonDBFile)
    con = conn.cursor()

    # 読み込み
    try:
        # テーブルがあれば削除
        con.execute(f'DROP TABLE {myPokemonDBTable}')
        print('[myPokemon]delete existing table')
        print('[myPokemon]create new table')
    except sqlite3.OperationalError:
        print('[myPokemon]create new table')

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {myPokemonDBTable} ('
            f'  {myPokemonColumnId} INTEGER PRIMARY KEY, '
            f'  {myPokemonColumnViewOrder} INTEGER, '
            f'  {myPokemonColumnNo} INTEGER, '
            f'  {myPokemonColumnNickName} TEXT, '
            f'  {myPokemonColumnTeraType} INTEGER, '
            f'  {myPokemonColumnLevel} INTEGER, '
            f'  {myPokemonColumnSex} INTEGER, '
            f'  {myPokemonColumnTemper} INTEGER, '
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
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        myPokemons = [
            Pokemon(1, 1, 197, "のろいーブイ", PokeType.ghost, 50, Sex.male, Temper.odayaka, 39, 0, [31, 244], [6, 0], [31, 252], [31, 0], [31, 12], [31, 0], [347, 500, 174, 273], [20, 16, 16, 16], Owner.mine).toSet(),
            Pokemon(2, 2, 136, "げんきーブイ", PokeType.grass, 50, Sex.male, Temper.yoki, 62, 0, [31, 4], [31, 252], [31, 0], [8, 0], [31, 0], [31, 252], [394, 851, 885, 263], [15, 16, 20, 20], Owner.mine).toSet(),
            Pokemon(3, 3, 196, "むすびーブイ", PokeType.fight, 55, Sex.female, Temper.hikaeme, 156, 0, [31, 4], [10, 0], [31, 0], [31, 252], [31, 0], [31, 252], [94, 851, 247, 447], [16, 16, 15, 20], Owner.mine).toSet(),
            Pokemon(4, 4, 700, "うたいーブイ", PokeType.fire, 77, Sex.male, Temper.hikaeme, 182, 0, [31, 100], [31, 0], [31, 156], [31, 252], [31, 0], [31, 0], [98, 281, 851, 304], [36, 16, 16, 16], Owner.mine).toSet(),
            Pokemon(5, 5, 470, "まいーブイ", PokeType.rock, 54, Sex.male, Temper.ijippari, 34, 0, [31, 184], [31, 232], [31, 0], [23, 0], [31, 4], [31, 88], [14, 73, 348, 851], [20, 16, 24, 16], Owner.mine).toSet(),
            Pokemon(6, 6, 134, "かたいーブイ", PokeType.normal, 75, Sex.male, Temper.zubutoi, 11, 0, [31, 212], [28, 0], [31, 236], [31, 12], [31, 20], [31, 28], [57, 151, 347, 156], [24, 20, 20, 5], Owner.mine).toSet(),
            Pokemon(7, 7, 135, "かいひーブイ", PokeType.fly, 100, Sex.female, Temper.okubyou, 10, 0, [31, 244], [31, 0], [31, 12], [31, 0], [31, 0], [31, 252], [189, 86, 164, 226], [16, 16, 15, 20], Owner.mine).toSet(),
            Pokemon(8, 8, 471, "ドライーブイ", PokeType.ice, 100, Sex.male, Temper.hikaeme, 81, 0, [31, 100], [7, 0], [31, 4], [31, 252], [31, 132], [31, 20], [573, 59, 247, 341], [20, 8, 15, 15], Owner.mine).toSet(),
        ]
        try:
            con.executemany(
                f'INSERT INTO {myPokemonDBTable} ('
                f'{myPokemonColumnId}, {myPokemonColumnViewOrder}, {myPokemonColumnNo}, {myPokemonColumnNickName}, '
                f'{myPokemonColumnTeraType}, {myPokemonColumnLevel}, {myPokemonColumnSex}, {myPokemonColumnTemper}, '
                f'{myPokemonColumnAbility}, {myPokemonColumnItem}, {myPokemonColumnIndividual[0]}, {myPokemonColumnIndividual[1]}, '
                f'{myPokemonColumnIndividual[2]}, {myPokemonColumnIndividual[3]}, {myPokemonColumnIndividual[4]}, '
                f'{myPokemonColumnIndividual[5]}, {myPokemonColumnEffort[0]}, {myPokemonColumnEffort[1]}, {myPokemonColumnEffort[2]}, '
                f'{myPokemonColumnEffort[3]}, {myPokemonColumnEffort[4]}, {myPokemonColumnEffort[5]}, {myPokemonColumnMove1}, '
                f'{myPokemonColumnPP1}, {myPokemonColumnMove2}, {myPokemonColumnPP2}, {myPokemonColumnMove3}, {myPokemonColumnPP3}, '
                f'{myPokemonColumnMove4}, {myPokemonColumnPP4}, {myPokemonColumnOwnerID})'
                f'VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
                myPokemons)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
