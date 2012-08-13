#!/usr/bin/env python
# -*- coding: UTF-8 -*-

'''
A script to generate JSDoc in docs/ directory

@author     Wu Yuntao
@version    0.1.0

'''

import sys
from os import path, walk, system, makedirs

ROOT_PATH = path.abspath(path.dirname(__file__))
JS_PATH = path.join(ROOT_PATH, '../lib/js')
DOC_PATH = path.join(ROOT_PATH, '../lib/docs')
EXCLUDES = ("jquery.js", "qunit.js", "sea.js", "zepto.js")

def find_js(directory=JS_PATH):
    ''' Find javascript files in directory '''
    print('Scanning javascripts under %s...\n' % directory)
    js = []
    for root, dirs, files in walk(directory):
        for filename in files:
            if not filename.endswith(".js") or filename in EXCLUDES:
                continue
            js.append(path.join(root, filename))
    return js

def run_dox(js):
    ''' Convert a single javascript file to JSDoc json by dox '''
    dirname = path.dirname(js).replace("lib/js", "docs")
    json = js.replace("lib/js", "docs") + 'on'
    if not path.exists(dirname):
        makedirs(dirname)
    print('Generating doc for %s...\n' % js)
    system('dox < %s > %s' % (js, json))

if __name__ == '__main__':
    if len(sys.argv) > 1:
        for js in sys.argv[1:]:
            if js.endswith(".js"):
                run_dox(js)
    else:
        for js in find_js():
            run_dox(js)
