#!/bin/env bash

#
# 	RÉCUPÉRATION D'URLS
#		
# 	USAGE : bash collecte_url.sh urls.txt
#		- urls.txt est un fichier texte avec une URL par ligne
#

if [[ $# -ne 1 ]]
then
	echo "Nombre invalide d'arguments."
	echo "Usage : bash collecte_url.sh fichier_urls.txt"
  exit
fi

FICHIER_URL=$1

# Test du fichier
if [[ -f $FICHIER_URL ]]
then
  # RAS
  echo "Let's goooo"
else
	echo "L'argument n'est pas un fichier."
	exit
fi

# Maintenant on peut commencer la lecture

URL_OK=0
URL_PAS_OK=0

# Vérification de la validité des URLs
while read -r LINE
do
	if [[ $LINE =~ "^https?://"  ]]
  then
    URL_OK=$(expr $OK + 1)
  else
    URL_PAS_OK=$(expr $URL_PAS_OK + 1)
  fi
done < $FICHIER_URL 

echo "Il y a $URL_OK URLs correctes et $URL_PAS_OK pas correctes."
