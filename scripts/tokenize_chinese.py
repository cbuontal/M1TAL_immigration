#!/usr/bin/env python3

import thulac
import errno
import fileinput

# utilisation : python3 tokenize_chinese.py chinois.txt
# possibilité de rediriger la sortie avec >, >>

# autre possibilité, lancer la commande:
# python3 -m thulac chinois.txt chinois_seg_output.txt -seg_only
# Mais ne permet pas les redirections d'entrées/sorties

seg = thulac.thulac(seg_only=True)
try:
    for line in fileinput.input():
        print(seg.cut(line, text=True))
except IOError as e:
    if e.errno != errno.EPIPE:
        raise
