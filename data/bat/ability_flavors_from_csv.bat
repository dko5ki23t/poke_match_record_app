@echo off

del ..\db\AbilityFlavors.db

python ..\python\ability_flavors_from_csv.py ..\csv\ability_flavor_text.csv -o ..\db\AbilityFlavors.db

pause
