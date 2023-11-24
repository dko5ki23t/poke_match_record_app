@echo off

del AbilityFlavors.db

python ability_flavors_from_csv.py pokeapi\data\v2\csv\ability_flavor_text.csv

pause
