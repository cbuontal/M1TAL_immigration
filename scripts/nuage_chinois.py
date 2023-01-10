import jieba, codecs, sys, pandas
import numpy as np
from wordcloud import WordCloud
from imageio import imread
from wordcloud import WordCloud, ImageColorGenerator
from os import listdir
from os.path import isfile, join
import matplotlib.pyplot as plt

#
#   Pour bien fonctionner, ce script a besoin de deux fichiers :
#       - un fichier .txt contenant les stopwords chinois
#       - un fichier .ttf contenant la police à utiliser
#
#   Ces fichiers sont rangés dans un sous-dossier data/
#
#



stopwords_filename = 'data/stopwords_zh.txt'
font_filename = 'data/simkai.ttf'

def contain_latin(txt):
    return ('a' in txt or 'b' in txt or 'c' in txt or 'd' in txt or 'e' in txt or 'f' in txt or 'g' in txt or 'h' in txt or 'i' in txt or 'j' in txt or 'k' in txt or 'l' in txt or 'm' in txt or 'n' in txt or 'o' in txt or 'p' in txt or 'q' in txt or 'r' in txt or 's' in txt or 't' in txt or 'u' in txt or 'v' in txt or 'w' in txt or 'x' in txt or 'y' in txt or 'z' in txt)

def filter_numbers(txt):
    """
        Renvoie vrai si l'argument passé en paramètre est une chaîne de caractères
        constituée uniquement de chiffres et de longueur strictement supérieure à 4
        - renvoie False si la chaîne est une suite de chiffres de longueur > 4
        - True sinon

        But = ne garder que les nombres assimilables à des années, ou éventuellement
        des pourcentages
    """
    if txt.isdigit() and len(txt) > 4:
        return False
    else:
        return True

def main(input_filename):
    content = '\n'.join([line.strip()
                        for line in codecs.open(input_filename, 'r', 'utf-8')
                        if len(line.strip()) > 0])
    stopwords = set([line.strip()
                    for line in codecs.open(stopwords_filename, 'r', 'utf-8')])

    segs = jieba.cut(content)
    words = []
    for seg in segs:
        word = seg.strip().lower()
        # nettoyage des mots indésirables
        if len(word) > 1 and word not in stopwords and not contain_latin(word) and filter_numbers(word) and word != '-%':
            words.append(word)

    words_df = pandas.DataFrame({'word':words})
    words_stat = words_df.groupby(by=['word'])['word'].agg(number=np.size)
    words_stat = words_stat.reset_index().sort_values(by="number",ascending=False)

    print('# of different words =', len(words_stat))

    wordcloud = WordCloud(font_path=font_filename, max_font_size=50, random_state=100, max_words=100, background_color="white")
    wordcloud = wordcloud.fit_words(dict(words_stat.head(4000).itertuples(index=False)))
    print("Sauvegarde du nuage")
    wordcloud.to_file('nuage_chinois.png')

if __name__ == '__main__':
    if len(sys.argv) == 2:
        main(sys.argv[1])
    else:
        print('[usage] <input>')
