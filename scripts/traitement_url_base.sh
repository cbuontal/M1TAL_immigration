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
			<thead><tr><th>ligne</th><th>code HTTP</th><th>URL</th><th>encodage</th><th>dump</th><th>html</th><th>occurrences</th><th>contextes</th><th>concordances</th></tr></thead>" > "tableaux/$fichier_tableau"


# pour chaque URL du fichier URL :

lineno=1;

while read -r URL;
do
	echo -e "\tURL : $URL";

	# réponse HTTP
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
	# récupération de l'encodage
	charset=$(curl -ILs $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)
	
	if [[ -z $charset ]]
	then
		echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi
	# pour transformer les 'utf-8' en 'UTF-8' :
	charset=$(echo $charset | tr "[a-z]" "[A-Z]")
	
	if [[ $code -eq 200 ]]
	then
		dump=$(lynx -dump -nolist -assume_charset=$charset -display_charset=$charset $URL)
		if [[ $charset -ne "UTF-8" && -n "$dump" ]]
		then
			dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE)
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi
	
	echo "$dump" > "./dumps-text/$basename-$lineno.txt"
	
	aspiration=$(curl $URL)
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

#URL="https://new.qq.com/rain/a/20221025A05OLS00"
#CODE_HTTP=$(curl -I $URL | grep HTTP | cut -d ' ' -f 2)

#echo "<tr><td>1</td><td>$CODE_HTTP</td><td>$URL</td></tr>\n" >> tableau.html

#on ferme le fichier
echo "		</table>
	</body> 
</html>" >> "tableaux/$fichier_tableau"



# modifier la ligne suivante pour créer effectivement du HTML
#echo "<html>\n<head>\n  <meta charset=\"utf-8\" />\n</header>\n<body>\n  <table>" > $fichier_tableau
#echo "Je dois devenir du code HTML à partir de la question 3" > $fichier_tableau
