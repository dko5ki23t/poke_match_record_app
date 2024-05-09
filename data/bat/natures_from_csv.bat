@echo off

del ..\db\Natures.db

python ..\python\natures_from_csv.py ..\csv\natures.csv ..\csv\nature_names.csv -o ..\db\Natures.db

pause
