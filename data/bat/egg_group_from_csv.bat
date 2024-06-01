@echo off

del ..\db\EggGroup.db

python ..\python\egg_group_from_csv.py ..\csv\egg_group_prose.csv -o ..\db\EggGroup.db

pause
