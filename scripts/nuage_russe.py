import string
import re
import matplotlib.pyplot as plt
import nltk
from nltk.corpus import stopwords
from nltk import word_tokenize
from wordcloud import WordCloud

text = str()
with open("../dumps-text/ru_total2.txt", "r") as f:
    text = f.read()

# passage en minuscule et suppression des ponctuations et lignes vides
text = text.lower()
spec_chars = string.punctuation + '\n\xa0«»\t—…'
text = re.sub('\n', '', text)
text = "".join([ch for ch in text if ch not in spec_chars])

text_tokens = word_tokenize(text)
text = nltk.Text(text_tokens)

russian_stopwords = stopwords.words("russian")
#liste de mots indésirables
russian_stopwords.extend(['это', 'iframe', 'году', 'нею', 'button', 'twitter', 'telegram', 'livejournal', 'года', 'который', 'изза'])

text_tokens = [token.strip() for token in text_tokens if token not in russian_stopwords]
text = nltk.Text(text_tokens)

## création du nuage de mots
text_raw = " ".join(text)
wordcloud = WordCloud(max_font_size=50, max_words=40, background_color="white").generate(text_raw)
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis("off")
plt.show()