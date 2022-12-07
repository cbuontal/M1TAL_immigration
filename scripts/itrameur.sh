#!/usr/bin/env bash

if [[ $# -ne 2 ]]
then
  echo "Deux arguments attendus : <dossier> <langue>"
  exit
fi

folder=$1     # dumps-text OU contextes
basename=$2   # en, fr, zh, ru

echo "<lang=\"$basename\">"

for filepath in $(ls $folder/$basename-*.txt)
do
  # filepath == dumps-text/fr-1.txt
  # ==> pagename = fr-1
  pagename=$(basename -s .txt $filepath)

  echo "<page=\"$pagename\">"
  echo "<text>"

  # on récupère les dumps et les contextes
  # on écrit à l'interieur de la balise text

  content=$(cat $filepath)
  # on remplace les caractères spéciaux par les entités html
  content=$(echo "$content" | sed 's/&/&amp;/g')
  content=$(echo "$content" | sed 's/</&lt;/g')
  content=$(echo "$content" | sed 's/>/&gt;/g')

  echo "$content"

  echo "</text>"
  echo "</page> §"
done
