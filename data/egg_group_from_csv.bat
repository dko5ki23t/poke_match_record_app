@echo off

del EggGroup.db

python egg_group_from_csv.py csv\egg_group_prose.csv

pause
