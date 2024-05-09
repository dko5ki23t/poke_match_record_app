@echo off

del ..\db\Moves.db

python ..\python\moves_from_csv.py ..\csv\moves.csv ..\csv\move_names.csv -o ..\db\Moves.db

pause
