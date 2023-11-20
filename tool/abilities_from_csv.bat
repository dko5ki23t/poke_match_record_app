@echo off

del Abilities.db

python abilities_from_csv.py pokeapi\data\v2\csv\abilities.csv pokeapi\data\v2\csv\ability_names.csv

pause
