@echo off

del ..\db\Abilities.db

python ..\python\abilities_from_csv.py ..\csv\abilities.csv ..\csv\ability_names.csv -o ..\db\Abilities.db

pause
