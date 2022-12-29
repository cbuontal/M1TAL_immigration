#!/usr/bin/env bash

#
#		Script qui établit une table de concordance en HTML autour d'un motif
#		usage : bash concordance.sh <fichier> <motif>
#
#


fichier_text=$1
motif=$2

if [[ $# -ne 2 ]]
then
	echo "Ce programme demande exactement deux arguments."
	echo "Usage : $0 <fichier> <motif>"
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

grep -Po "(\p{Han}){0,5}$motif(\p{Han}){0,5}" $fichier_text | sed -E "s/(.*)($motif)(.*)/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr>/"

echo "
</tbody>
</table>
</body>
</html>
"
