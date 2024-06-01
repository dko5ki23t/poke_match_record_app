@echo off

del ..\db\MoveFlavors.db

python ..\python\move_flavors_from_csv.py ..\csv\move_flavor_text.csv -o ..\db\MoveFlavors.db

pause
