@echo off

del Moves.db

python moves_from_csv.py csv\moves.csv csv\move_names.csv

pause
