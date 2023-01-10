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

if [[ $lang != 'fr' && $lang != 'ru' && $lang != 'zh' ]]
then
	echo "C'est quoi cette langue ?"
	exit
fi

echo 	"
            <html>
             <html lang=\"$lang\">
			 <head>
							<meta charset=\"utf-8\" />
							<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
							<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
							<title>Concordance</title>
			</head>
			<body class=\"has-navbar-fixed-top\">
							<nav class=\"navbar is-light is-fixed-top\"><div class=\"navbar-menu\"><div class=\"navbar-start\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#introduction\">Introduction</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#analyse\">Analyse</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../scripts.html\">Scripts</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\">Tableaux</a><div class=\"navbar-dropdown\"><a class=\"navbar-item\" href=\"../tableaux/tableau_fr.html\">Français</a><a class=\"navbar-item\" href=\"../tableaux/tableau_ru.html\">Russe</a><a class=\"navbar-item\" href=\"../tableaux/tableau_zh.html\">Chinois</a></div></div></div><div class=\"navbar-end\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#aPropos\">À propos</a></div><div class=\"navbar-item\"><a href=\"https://github.com/cbuontal/M1TAL_immigration\"><img src=\"../images/github_logo.png\" alt=\"Github\"></a></div></div></div></nav>
							<h1 class=\"title\">Concordance</h1>
							<table class=\"table is-bordered is-striped is-narrow is-hoverable is-fullwidth\">
									<thead>
									<tr>
									<th class=\"has-text-right\">Contexte gauche</th>
									<th>Cible</th>
									<th class=\"has-text-left\">Contexte droit</th>
									</tr>
									</thead>
									"

if [[ $lang == 'fr' ]]
then
	grep -E -o -i "(\w+\W+| {0,5})$motif\b(\W+\w+| ){0,5}" $fichier_text | sed -E -r "s/(.*)$motif(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/I"
elif [[ $lang == 'ru' ]]
then
	#pour utiliser cette ligne, il faut installer gnu-sed : brew install gnu-sed. sinon utiliser "sed"
	grep -E -o -i "(\w+\W+){0,5}\b$motif\b(\W+\w+){0,5}" $fichier_text | sed -E "s/(.*)$motif(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/I"
elif [[ $lang == 'zh' ]]
then
	LANG=zh_CN.UTF-8 grep -Po "((\p{Han}|，){1,5} ){0,5}$motif( (\p{Han}|，){1,5}){0,5}" $fichier_text | LANG=C sed -E "s/(.*)($motif)(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/"
fi

echo "
</tbody>
</table>
</body>
</html>
"