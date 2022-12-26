#!/usr/bin/env bash

#===============================================================================
# VOUS DEVEZ MODIFIER CE BLOC DE COMMENTAIRES.
# Ici, on décrit le comportement du programme.
# Indiquez, entre autres, comment on lance le programme et quels sont
# les paramètres.
# La forme est indicative, sentez-vous libres d'en changer !
# Notamment pour quelque chose de plus léger, il n'y a pas de norme en bash.
#
#
#	Utilisation : bash traitement_url_base.sh nom_fichier_URL nom_fichier_HTML
#
#
#===============================================================================

# !!!!!!
# ici on doit vérifier que nos deux paramètres existent, sinon on ferme!
# !!!!!!


if [ $# -ne 2 ]
then
	echo "Il faut deux paramètres."
	echo "Utilisation : bash traitement_url_base.sh nom_fichier_URL nom_fichier_HTML"
	exit
fi


fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie

basename=$(basename -s .txt $fichier_urls)
mot="移民"

# on utilise la commande :
# curl -I lien.html
# pour obtenir seulement l'entête de la réponse du serveur
# -L pour gérer les réponses 301 "moved permanently"
# -s pour le mode silencieux et ne pas polluer l'affichage du terminal

# la réponse se trouve dans la première ligne du résultat, deuxième élément
# on peut l'obtenir en extrayant la première ligne et en sélectionnant son 2è élément


# curl -I nom_url | grep HTTP | cut -d ' ' -f 2

echo 	"<html>
	<head>
		<meta charset=\"utf-8\" />
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
		<title>Tableau des URLS</title>
	</head>
	<body>
		<h1 class=\"title\">Tableau des URLs $basename</h1>
		<table class=\"table is-bordered\">
			<thead><tr><th>ligne</th><th>code HTTP</th><th>URL</th><th>encodage</th><th>html</th><th>dump</th><th>occurrences</th><th>contextes</th><th>concordances</th></tr></thead>" > "tableaux/$fichier_tableau"


# pour chaque URL du fichier URL :

lineno=1;

while read -r URL;
do
	echo -e "\tURL : $URL";

	# réponse HTTP
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
	# récupération de l'encodage
	charset=$(curl -Ls $URL -D - -o "./aspirations/fich-$lineno.html" | grep -Eo "charset=(\w|-)+" | cut -d= -f2)

	if [[ -z $charset ]]
	then
		echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi
	# pour transformer les 'utf-8' en 'UTF-8' :
	charset=$(echo $charset | tr "[a-z]" "[A-Z]")

	# cette page pose problème...
	if [[ $URL == "https://www.cnr.cn/sx/yw/20221129/t20221129_526078646.shtml" ]]
	then
		charset="gb2312"
	fi

	if [[ $code -eq 200 ]]
	then
		aspiration=$(curl $URL)

		if [[ $charset == 'UTF-8' ]]
		then
			dump=$(curl $URL | lynx -stdin -dump -assume_charset=utf-8 -display_charset=utf-8)
		else
			# charset=$(curl $URL | urchardet)
			dump=$(curl $URL | iconv -f $charset -t UTF-8 | lynx -stdin -dump -assume_charset=utf-8 -display_charset=utf-8)
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi

	echo "$dump" > "./dumps-text/$basename-$lineno.txt"

	echo "$aspiration" > "./aspirations/$basename-$lineno.html"

	# compte du nombre d'occurrences
  NB_OCC=$(grep -E -o $mot ./dumps-text/$basename-$lineno.txt | wc -l)

  # extraction des contextes
  grep -E -A2 -B2 $mot ./dumps-text/$basename-$lineno.txt > ./contextes/$basename-$lineno.txt

  # construction des concordances avec une commande externe
  bash scripts/concordance.sh ./dumps-text/$basename-$lineno.txt $mot > ./concordances/$basename-$lineno.html



	echo "			<tr><td>$lineno</td><td>$code</td><td>$URL</td><td>$charset</td><td><a href="../aspirations/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$basename-$lineno.txt">text</a></td><td>$NB_OCC</td><td><a href="../contextes/$basename-$lineno.txt">contextes</a></td><td><a href="../concordances/$basename-$lineno.html">concordance</a></td></tr>" >> "tableaux/$fichier_tableau"
	lineno=$((lineno+1));
done < $fichier_urls


#on ferme le fichier
echo "		</table>
	</body>
</html>" >> "tableaux/$fichier_tableau"
