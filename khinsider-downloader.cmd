@echo off

echo Ce script a ete cree par le grand Nebulleux - Les OST viennent de [https://downloads.khinsider.com/]

pause

set /p site="Entrez l'url de l'ost voulue svp : "

set /p format="Entrez le format voulu (mp3,m4a,flac): "

khinsider.py --format %format% %site%
