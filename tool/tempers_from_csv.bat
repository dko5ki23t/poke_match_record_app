@echo off

del Tempers.db

python tempers_from_csv.py pokeapi\data\v2\csv\natures.csv pokeapi\data\v2\csv\nature_names.csv

pause
