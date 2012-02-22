#!/usr/bin/env python

'''
A script to convert old style module definition to AMD pattern.

Old style module definition:

  kopi.module("path.to.a")
    .require("path.to.b")
    .require("path.to.c")
    .define (exports, b, c) ->

      exports.d = SomeClass

will be converted to AMD pattern:

  define "path/to/a", (require, exports, module) ->

    b = require "path/to/b"
    c = require "path/to/c"

    d: SomeClass

'''

import re
from optparse import OptionParser

RE_MODULE = re.compile(r'(kopi\.module\([\'"](?P<name>[a-zA-Z0-9\.\_]+)[\'"]\)(?:\s*\.require\([\'"][a-zA-Z0-9\.\_]+[\'"]\))*\s*\.define\ \([^\)]+\)\ ->)', re.M)
RE_REQUIRE = re.compile(r'\s*\.require\([\'"]([a-zA-Z0-9\.\_]+)[\'"]\)')
RE_INTENT = re.compile(r'^\ \ ', re.M)
RE_EXPORTS = re.compile(r'exports\.(\w+)\ =\ ', re.M)

AMD_DEFINE = 'define "%s", (require, exports, module) ->\n'
AMD_REQUIRE = '\n  %s = require "%s"'
AMD_EXPORT = r'\1: '

def convert(path):
    print("Converting %s" % path)
    code = open(path).read()
    print("Remove extra intents")
    code = RE_INTENT.sub('', code)
    match = RE_MODULE.search(code)
    if not match:
        print("No module matches!\n")
        return
    module = match.groups()[0]
    name = match.groups()[1].replace('.', '/')
    print("Got module %s" % name)
    requires = RE_REQUIRE.findall(module)
    if not requires:
        print("No module is required!")
    amd = AMD_DEFINE % name
    for require in requires:
        require = require.replace('.', '/')
        name = require.split('/')[-1]
        amd += AMD_REQUIRE % (name, require)
    code = code.replace(module, amd)
    code = RE_EXPORTS.sub(AMD_EXPORT, code)
    file = open(path, 'w')
    file.write(code)
    file.close()
    print("Done.\n")

if __name__ == '__main__':
    p = OptionParser()
    opts, args = p.parse_args()

    for path in args:
        convert(path)
