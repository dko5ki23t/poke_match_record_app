@echo off

del MoveFlavors.db

python move_flavors_from_csv.py csv\move_flavor_text.csv

pause
