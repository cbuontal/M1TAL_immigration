import string
import re
import matplotlib.pyplot as plt
import nltk
from nltk.corpus import stopwords
from nltk import word_tokenize
from wordcloud import WordCloud

## À EXÉCUTER DEPUIS LA RACINE DU DOSSIER

text = str()
with open("./dumps-text/ru_total2.txt", "r") as f:
    text = f.read()

# passage en minuscule et suppression des ponctuations et lignes vides
text = text.lower()
spec_chars = string.punctuation + '\n\xa0«»\t—…'
text = re.sub('\n', '', text)
text = "".join([ch for ch in text if ch not in spec_chars])
# suppression des mots contenant des caractères latins
mots_texte = text.split()
for idx, mot in enumerate(mots_texte):
    if 'a' in mot or 'b' in mot or 'c' in mot or 'd' in mot or 'e' in mot or 'f' in mot or 'g' in mot or 'h' in mot or 'i' in mot or 'j' in mot or 'k' in mot or 'l' in mot or 'm' in mot or 'n' in mot or 'o' in mot or 'p' in mot or 'q' in mot or 'r' in mot or 's' in mot or 't' in mot or 'u' in mot or 'v' in mot or 'w' in mot or 'x' in mot or 'y' in mot or 'z' in mot :
        mots_texte.remove(mot)
text = " ".join(mots_texte)

text_tokens = word_tokenize(text)
text = nltk.Text(text_tokens)

russian_stopwords = stopwords.words("russian")
#liste de mots indésirables
russian_stopwords.extend(['это', 'iframe', 'году', 'нею', 'button', 'twitter', 'telegram', 'livejournal', 'года', 'который', 'изза'])

text_tokens = [token.strip() for token in text_tokens if token not in russian_stopwords]
text = nltk.Text(text_tokens)

## création du nuage de mots
text_raw = " ".join(text)
wordcloud = WordCloud(max_font_size=50, max_words=100, background_color="white").generate(text_raw)
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis("off")
plt.show()