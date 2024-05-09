@echo off

del ItemFlavors.db

python item_flavors_from_csv.py csv\item_flavor_text.csv

pause
