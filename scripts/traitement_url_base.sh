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


if [ $# -ne 3 ]
then
	echo "Il faut trois paramètres."
	echo "Utilisation : bash traitement_url_base.sh <langue> <nom_fichier_URL> <nom_fichier_HTML>"
	exit
fi

lang=$1
fichier_urls=$2 # le fichier d'URL en entrée
fichier_tableau=$3 # le fichier HTML en sortie

basename=$(basename -s .txt $fichier_urls)

if [[ $lang == 'zh' ]]
then
	mot="移民"
elif [[ $lang == 'ru' ]]
then
 	mot="(иммигр\w+|эмигр\w+)"
elif [[ $lang == 'fr' ]]
then
	mot="([Éé]migr\w+|[Ii]mmigr\w+)"
fi


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
	<body class=\"has-navbar-fixed-top\">
		<nav class=\"navbar is-light is-fixed-top\"><div class=\"navbar-menu\"><div class=\"navbar-start\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#introduction\">Introduction</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#analyse\">Analyse</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../scripts.html\">Scripts</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\">Tableaux</a><div class=\"navbar-dropdown\"><a class=\"navbar-item\" href=\"tableau_fr.html\">Français</a><a class=\"navbar-item\" href=\"tableau_ru.html\">Russe</a><a class=\"navbar-item\" href=\"tableau_zh.html\">Chinois</a></div></div></div><div class=\"navbar-end\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#aPropos\">À propos</a></div><div class=\"navbar-item\"><a href=\"https://github.com/cbuontal/M1TAL_immigration\"><img src=\"../images/github_logo.png\" alt=\"Github\"></a></div></div></div></nav>
		<h1 class=\"title\">Tableau des URLs $basename</h1>
		<table class=\"table is-bordered\">
			<thead><tr><th>ligne</th><th>code HTTP</th><th>URL</th><th>encodage</th><th>html</th><th>dump</th><th>occurrences</th><th>contextes</th><th>concordances</th></tr></thead>" > "tableaux/$fichier_tableau"


# pour chaque URL du fichier URL :

lineno=1;

if [[ $lang == 'zh' ]]
then

# nécessaire pour le bon fonctionnement de `sed`
lang_base=$LANG
export LANG=C

while read -r URL;
do
	echo -e "\tURL : $URL";

	# réponse HTTP
	code=$(curl -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
	# récupération de l'encodage
	charset=$(curl -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" -Ls $URL -D - -o "./aspirations/fich-$lineno.html" | grep -Eo "charset=(\w|-)+" | cut -d= -f2)

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
		aspiration=$(curl -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" $URL)

		if [[ $charset == 'UTF-8' ]]
		then
			dump=$(curl $URL | iconv -f UTF-8 -t UTF-8//IGNORE | lynx -stdin -dump -assume_charset=utf-8 -display_charset=utf-8 | sed -E "/(BUTTON)/d" | sed -E "/   [*+#_©×]/d" | sed -E "/   \[/d" | sed -E "/^IFRAME/d")
		else
			# charset=$(curl $URL | urchardet)
			dump=$(curl $URL | iconv -f $charset -t UTF-8//IGNORE | lynx -stdin -dump -assume_charset=utf-8 -display_charset=utf-8 | sed -E "/(BUTTON)/d" | sed -E "/   [*+#_©×]/d" | sed -E "/   \[/d" | sed -E "/^IFRAME/d")
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi

	echo "$aspiration" > "./aspirations/$basename-$lineno.html"

	echo "$dump" > "./dumps-text/$basename-$lineno.txt"
	# segmentation du dump avec thulac, on supprime aussi les indications du scripts qui polluent le dump :
	dumpseg=$(python3 scripts/tokenize_chinese.py "./dumps-text/$basename-$lineno.txt" | sed -E "/Model loaded succeed/d" | sed -E '/References/,$d')
	# on écrase le dump non segmenté
	echo "$dumpseg" > "./dumps-text/$basename-$lineno.txt"

	# compte du nombre d'occurrences
  NB_OCC=$(grep -a -E -o $mot ./dumps-text/$basename-$lineno.txt | wc -l)

  # extraction des contextes
  grep -E -A1 -B1 $mot ./dumps-text/$basename-$lineno.txt > ./contextes/$basename-$lineno.txt

  # construction des concordances avec une commande externe
  bash scripts/concordance.sh zh ./dumps-text/$basename-$lineno.txt $mot > ./concordances/$basename-$lineno.html


	echo "			<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$basename-$lineno.txt">text</a></td><td>$NB_OCC</td><td><a href="../contextes/$basename-$lineno.txt">contextes</a></td><td><a href="../concordances/$basename-$lineno.html">concordance</a></td></tr>" >> "tableaux/$fichier_tableau"
	lineno=$((lineno+1));
done < $fichier_urls

# on revient à la variable globale de base une fois le traitement terminé
export LANG=lang_base

elif [[ $lang == 'ru' ]]
then
while read -r URL;
do
			echo -e "\tURL : $URL";
			code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1) # de la manière attendue, sans l'option -w de cURL
			charset=$(curl -ILs $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)
			charset=$(echo $charset | tr "[a-z]" "[A-Z]") #ici nous définissons pour la valeur sharset la commande "convertir toutes les petites lettres en majuscules, afin que toutes les lettres UTF-8 soient du même type
			echo -e "\tcode : $code";

			if [[ -z $charset ]]
			then
						echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
						charset="UTF-8";
			else
						echo -e "\tencodage : $charset";
			fi

			if [[  $code -eq 200 || $code -eq 403 ]]
						then
						aspiration=$(curl $URL)
						dump=$(lynx -dump -nolist -accept_all_cookies -assume_charset=$charset -display_charset=$charset $URL)
						if [[  $charset -ne 'UTF-8' ]]
						then
							dump=$(iconv -f $charset -t UTF-8)
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
grep -E -A2 -B2 $mot ./dumps-text/$basename-$lineno.txt > "./contextes/$basename-$lineno.txt" 
  # construction des concordance avec une commande externe
bash scripts/concordance.sh ru ./dumps-text/$basename-$lineno.txt $mot > "./concordances/$basename-$lineno.html"

echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$basename-$lineno.txt">text</a></td><td>$NB_OCC</td><td><a href="../contextes/$basename-$lineno.txt">contextes</a></td><td><a href="../concordances/$basename-$lineno.html">concordance</a></td></tr>" >> "tableaux/$fichier_tableau" #Nous spécifions ici où placer toutes les informations et notons qu'il n'est pas nécessaire de les supprimer à chaque itération
echo -e "\t--------------------------------"

lineno=$((lineno+1));

done  < $fichier_urls

elif [[ $lang == 'fr' ]]
then
while read -r URL;
do
			echo -e "\tURL : $URL";
			code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1) # de la manière attendue, sans l'option -w de cURL
			charset=$(curl -ILs $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)
			charset=$(echo $charset | tr "[a-z]" "[A-Z]") #ici nous définissons pour la valeur sharset la commande "convertir toutes les petites lettres en majuscules, afin que toutes les lettres UTF-8 soient du même type
			echo -e "\tcode : $code";

			if [[ -z $charset ]]
			then
						echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
						charset="UTF-8";
			else
						echo -e "\tencodage : $charset";
			fi

			if [[  $code -eq 200 || $code -eq 403 ]]
				then
						aspiration=$(curl $URL)
						dump=$(lynx -dump -nolist -accept_all_cookies -assume_charset=$charset -display_charset=$charset $URL)
						if [[  $charset -ne 'UTF-8' ]]
						then
							dump=$(iconv -f $charset -t UTF-8)
						fi
			else
						echo -e "\tcode différent de 200 utilisation d'un dump vide"
						dump=""
						charset=""
			fi

			echo "$dump" > "./dumps-text/$basename-$lineno.txt"
			# une fois le fichier créé, on peut utiliser la commande suivante pour supprimer les espaces en début de ligne :
			LANG=C sed -i.bak 's/^[[:space:]]*//' "./dumps-text/$basename-$lineno.txt"
			# une fois les espaces de début de ligne supprimés, on peut nettoyer
			dump_propre=$(cat "./dumps-text/$basename-$lineno.txt" | LANG=C sed '/Également sur RFI/,$d' | LANG=C sed '/(BUTTON)/d' | LANG=C sed '/^[+*©►]/d' | LANG=C sed '/^Price:/,$d' | LANG=C sed '/^http/d' | LANG=C sed '/^IFRAME/d' )
			# et on remplace le dump initial par le dump nettoyé
			echo "$dump_propre" > "./dumps-text/$basename-$lineno.txt"

			echo "$aspiration" > "./aspirations/$basename-$lineno.html"

# compte du nombre d'occurrences
NB_OCC=$(grep -E -o $mot ./dumps-text/$basename-$lineno.txt | wc -l)
  # extraction des contextes
grep -E -A2 -B2 $mot ./dumps-text/$basename-$lineno.txt > "./contextes/$basename-$lineno.txt"
  # construction des concordance avec une commande externe
bash scripts/concordance.sh fr ./dumps-text/$basename-$lineno.txt $mot > "./concordances/$basename-$lineno.html"

echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$basename-$lineno.txt">text</a></td><td>$NB_OCC</td><td><a href="../contextes/$basename-$lineno.txt">contextes</a></td><td><a href="../concordances/$basename-$lineno.html">concordance</a></td></tr>" >> "tableaux/$fichier_tableau" #Nous spécifions ici où placer toutes les informations et notons qu'il n'est pas nécessaire de les supprimer à chaque itération
echo -e "\t--------------------------------"

lineno=$((lineno+1));

done  < $fichier_urls

fi


#on ferme le fichier
echo "		</table>
	</body>
</html>" >> "tableaux/$fichier_tableau"