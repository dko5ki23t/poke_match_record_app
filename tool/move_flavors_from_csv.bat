@echo off

del MoveFlavors.db

python move_flavors_from_csv.py pokeapi\data\v2\csv\move_flavor_text.csv

pause
