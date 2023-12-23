@echo off

del Moves.db

python moves_from_csv.py pokeapi\data\v2\csv\moves.csv pokeapi\data\v2\csv\move_names.csv

pause
