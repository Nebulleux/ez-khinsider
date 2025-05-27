#!/bin/bash

echo "Ce script a été créé par le grand Nebulleux - Les OST viennent de [https://downloads.khinsider.com/]"
echo "This script was created by the great Nebulleux - OST are from [https://downloads.khinsider.com/]"

read -p "Please enter the URL of the desired OST | Entrez l'URL de l'OST voulue svp : " site
read -p "Put the desired format (mp3, m4a, flac) | Entrez le format voulu (mp3, m4a, flac) : " format

# On suppose que khinsider.py est soit dans le PATH, soit dans le dossier actuel avec les droits d'exécution
./khinsider.py --format "$format" "$site"
