#!/usr/bin/env python
# -*- coding: UTF-8 -*-

"""
Build JS dependency tree
"""

import re
from optparse import OptionParser

class DepTree(object):

    RE_MODULE = re.compile(r'(kopi.module\([\'"]([a-z\.\_]+)[\'"]\)(?:\s*\.require\([\'"][a-z\.\_]+[\'"]\))*\s*\.define)', re.M)
    RE_REQUIRE = re.compile(r'\.require\([\'"]([a-z\.\_]+)[\'"]\)', re.M)

    def __init__(self, file, path):
        self._file = file
        self._path = path

    def build(self):
        print("read content from file: %s" % self._file)
        content = open(self._file, "r").read()
        match = self.RE_MODULE.search(content)
        if match:
            string, name = match.groups()
            self.name = name
            print(self.name)
            self.requires = self.RE_REQUIRE.findall(string)
            print self.requires
            for require in self.requires:
                pass

if __name__ == '__main__':
    p = OptionParser()
    opts, args = p.parse_args()

    for script in args:
        tree = DepTree(script, path="/home/yuntao/Workspace/kopi/src/coffee/")
        tree.build()
        print tree.to_json()
