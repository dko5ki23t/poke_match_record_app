@echo off

del AbilityFlavors.db

python ability_flavors_from_csv.py csv\ability_flavor_text.csv

pause
