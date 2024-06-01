@echo off

del ..\db\Items.db

python ..\python\items_from_csv.py ..\csv\items.csv ..\csv\item_names.csv ..\csv\item_flag_map.csv -o ..\db\Items.db

pause
