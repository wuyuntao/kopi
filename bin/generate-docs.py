#!/usr/bin/env python
# -*- coding: UTF-8 -*-

'''
A script to generate documentation in docs/ directory

@author     Wu Yuntao
@version    0.2.0

'''

import re
import sys
from os import path, walk, system, makedirs

ROOT_PATH = path.abspath(path.dirname(__file__))
COFFEE_PATH = path.join(ROOT_PATH, '../src/coffee')
DOC_PATH = path.join(ROOT_PATH, '../docs')
EXCLUDE_PATHS = (
    path.join(ROOT_PATH, '../src/coffee/kopi/demos'),
    path.join(ROOT_PATH, '../src/coffee/kopi/tests'),
)
DOC_FORMAT = 'markdown'
RE_COMMENT_BLOCK = re.compile(r'###(.*?)###', re.M|re.S)
RE_INDENT = re.compile(r'^(\ +)', re.M)

def find_coffee(coffee_path=COFFEE_PATH):
    ''' Find javascript files in directory '''
    print('Scanning javascripts under %s...\n' % coffee_path)
    coffee = []
    for root, dirs, files in walk(coffee_path):
        print '%s: %s' % (root, is_exclude(root))
        for filename in files:
            if not filename.endswith(".coffee") or filename in EXCLUDE_PATHS:
                continue
            coffee.append(path.join(root, filename))
    return coffee

def is_exclude(directory):
    ''' Check if exclude directory '''
    for exclude_path in EXCLUDE_PATHS:
        if directory and directory.startswith(exclude_path):
            return True
    return False

def generate_doc(coffee_path):
    ''' Generate doc from coffee '''
    doc_dirname = path.dirname(coffee_path).replace("src/coffee", "docs")
    if not path.exists(doc_dirname):
        makedirs(doc_dirname)
    doc_path = coffee_path \
        .replace("src/coffee", "docs") \
        .replace(".coffee", ".md")
    coffee = open(coffee_path, 'r')
    coffee_text = coffee.read()
    doc_text = parse_doc(coffee_text)
    doc = open(doc_path, 'w')
    doc.write(doc_text)
    doc.close()
    coffee.close()
    print('Doc generated at %s.\n' % coffee_path)

def parse_doc(coffee=""):
    ''' Generate markdown from CoffeeScript code. '''
    # Strip all comment block
    blocks = RE_COMMENT_BLOCK.findall(coffee)
    doc = ''
    for block in blocks:
        if block.startswith("!") or not block.strip():
            continue
        # Remove indent
        indents = [len(ws) for ws in RE_INDENT.findall(block)]
        if len(indents) == 0:
            doc += block.lstrip() + '\n'
        else:
            doc += re.sub(r'^\ {%s}' % min(indents), '', block.lstrip(), flags=re.M) + '\n'
    return doc

if __name__ == '__main__':
    if len(sys.argv) > 1:
        for coffee in sys.argv[1:]:
            if coffee.endswith(".coffee"):
                generate_doc(coffee)
    else:
        for coffee in find_coffee():
            generate_doc(coffee)
    print 'All done.\n'
