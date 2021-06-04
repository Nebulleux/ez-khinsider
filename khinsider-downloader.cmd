@echo off

echo Ce script a ete cree par le grand Nebulleux - Les OST viennent de [https://downloads.khinsider.com/]
echo This script was created by the great Nebulleux - OST are from [https://downloads.khinsider.com/]

pause

set /p site="Put the website url here | Entrez l'url de l'ost voulue svp : "

set /p format="Put the desired format (mp3,m4a,flac)| Entrez le format voulu (mp3,m4a,flac): "

khinsider.py --format %format% %site%
