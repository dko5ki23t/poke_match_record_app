@echo off

del ..\db\Prepared.db

python ..\python\make_user_data.py -o ..\db\Prepared.db

pause
