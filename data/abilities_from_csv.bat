@echo off

del Abilities.db

python abilities_from_csv.py csv\abilities.csv csv\ability_names.csv

pause
