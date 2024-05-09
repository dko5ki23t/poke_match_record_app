@echo off

del Tempers.db

python tempers_from_csv.py csv\natures.csv csv\nature_names.csv

pause
