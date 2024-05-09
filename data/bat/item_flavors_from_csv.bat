@echo off

del ..\db\ItemFlavors.db

python ..\python\item_flavors_from_csv.py ..\csv\item_flavor_text.csv -o ..\db\ItemFlavors.db

pause
