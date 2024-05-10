@echo off

del ..\db\BuffDebuffs.db

python ..\python\buff_debuffs_from_csv.py ..\csv\buff_debuffs.csv -o ..\db\BuffDebuffs.db

pause
