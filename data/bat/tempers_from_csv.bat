@echo off

del ..\db\Tempers.db

python ..\python\tempers_from_csv.py ..\csv\natures.csv ..\csv\nature_names.csv -o ..\db\Tempers.db

pause
