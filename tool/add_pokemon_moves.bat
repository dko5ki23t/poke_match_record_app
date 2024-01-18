

if "%1" == "" (
    echo Usage : add_pokemon_moves.bat pokemonID
    exit /b
)

python extract.py わざリスト.txt わざリスト2.txt

python name_to_id.py pokeapi\data\v2\csv\move_names.csv わざリスト2.txt わざリスト3.txt

python add_csv_row2.py pokeapi\data\v2\csv\pokemon_moves.csv %1 わざリスト3.txt pokeapi\data\v2\csv\pokemon_moves.csv

pause
