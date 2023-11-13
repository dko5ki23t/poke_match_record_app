@echo off

del Items.db

python items_from_csv.py pokeapi\data\v2\csv\items.csv pokeapi\data\v2\csv\item_names.csv pokeapi\data\v2\csv\item_flag_map.csv

pause
