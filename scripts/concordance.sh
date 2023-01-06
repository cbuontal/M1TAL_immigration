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
			<body>
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
	grep -E -o "(\w+\W+){0,5}\b$motif\b(\W+\w+){0,5}" $fichier_text | sed -E "s/(.*)($motif)(.*)/<tr><td class="has-text-right">\1<\/td><td class="has-text-danger">\2<\/td><td class="has-text-left">\3<\/td><\/tr>/"
elif [[ $lang == 'ru' ]]
then
	#pour utiliser cette ligne, il faut installer gnu-sed : brew install gnu-sed
	grep -E -o "(\w+\W+){0,5}\b$motif\b(\W+\w+){0,5}" $fichier_text | gsed -E "s/(.*)$motif(.*)/<tr><td class="has-text-right">\1<\/td><td class="has-text-danger">\2<\/td><td class="has-text-left">\3<\/td><\/tr>/"
elif [[ $lang == 'zh' ]]
then
	grep -Po "(\p{Han}){0,5}$motif(\p{Han}){0,5}" $fichier_text | sed -E "s/(.*)($motif)(.*)/<tr><td class="has-text-right">\1<\/td><td class="has-text-danger">\2<\/td><td class="has-text-left">\3<\/td><\/tr>/"
fi

echo "
</tbody>
</table>
</body>
</html>
"
