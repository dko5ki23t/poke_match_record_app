@echo off

del Items.db

python items_from_csv.py csv\items.csv csv\item_names.csv csv\item_flag_map.csv

pause
