#!/usr/bin/env bash

#
#		Script qui établit une table de concordance en HTML autour d'un motif
#		usage : bash concordance.sh <fichier> <motif>
#
#

lang=$1 # fr, ru, zh
fichier_text=$2
motif=$3

if [[ $# -ne 3 ]]
then
	echo "Ce programme demande exactement trois arguments."
	echo "Usage : $0 <langue> <fichier> <motif>"
	exit
fi

if [[ ! -f $fichier_text ]]
then
  echo "le fichier $fichier_text n'existe pas"
  exit
fi

if [[ -z $motif ]]
then
  echo "le motif est vide"
  exit
fi

if [[ $lang != 'fr' || $lang != 'ru' || $lang != 'zh' ]]
then
	exit
fi

echo "
<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"UTF-8\">
  <title>Concordance</title>
</head>
<body>
<table>
<thead>
  <tr>
    <th class=\"has-text-right\">Contexte droit</th>
    <th>Cible</th>
    <th class=\"has-text-left\">Contexte gauche</th>
  </tr>
</thead>
<tbody>
"

if [[ $lang == 'fr' ]]
then
	## traitement du français
elif [[ $lang == 'ru' ]]
then
	### traitement du russe
elif [[ $lang == 'zh' ]]
then

grep -Po "(\p{Han}){0,5}$motif(\p{Han}){0,5}" $fichier_text | sed -E "s/(.*)($motif)(.*)/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr>/"

fi

echo "
</tbody>
</table>
</body>
</html>
"
