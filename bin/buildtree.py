#!/usr/bin/env python
# -*- coding: UTF-8 -*-

"""
A Script to build JavaScript dependency tree

@author     Brandon Wu
@version    0.2

"""

# TODO Discover recursive dependencies
# TODO Support non-AMD modules

import re
import os
from optparse import OptionParser

modules = {}

class DepTree(object):

    # Old style definition
    # RE_MODULE = re.compile(r'(kopi.module\([\'"]([a-zA-Z0-9\.\_]+)[\'"]\)(?:\s*\.require\([\'"][a-zA-Z0-9\.\_]+[\'"]\))*\s*\.define)', re.M)
    # RE_REQUIRE = re.compile(r'\.require\([\'"]([a-zA-Z0-9\.\_]+)[\'"]\)', re.M)

    RE_MODULE = re.compile(r'^define[\(\ ][\'"]([a-zA-Z0-9\.\_\/\-]+)[\'"]', re.M)
    RE_REQUIRE = re.compile(r'[\s=]require[\(\ ][\'"]([a-zA-Z0-9\.\_\/\-]+)[\'"]', re.M)

    SPROCKETS_HEADER = """// Generated by buildtree.py\n"""
    SPROCKETS_REQUIRE = "//= require %s\n"

    HTML_SCRIPT_TAG = '<script type="text/javascript" src="%s.js"></script>\n'

    def __init__(self, file, path, uri, extensions):
        self._file = file
        self._path = path
        self._uri = uri
        self._extensions = extensions
        self.name = None
        self.require_names = []
        self.requires = []

    def build(self):
        print("read content from file: %s" % self._file)
        content = open(self._file, "r").read()
        match = self.RE_MODULE.search(content)
        if match:
            name = match.groups()[0]
            self.name = name
            print("module name: %s" % self.name)
            requires = self.RE_REQUIRE.findall(content)
            print("found %s required modules: %s" % (len(requires), ", ".join(requires)))
            for module in requires:
                if module in modules:
                    tree = modules[module]
                else:
                    path = self.find_module_path(module)
                    if path:
                        tree = DepTree(path, self._path, self._uri, self._extensions)
                        tree.build()
                    else:
                        tree = DepTree(module, self._path, self._uri, self._extensions)
                        tree.name = module
                    modules[module] = tree
                self.require_names.append(module)
                self.requires.append(tree)
        else:
            print("no matching module in %s" % self._file)

    def find_module_path(self, module):
        modules = module.split("/")
        path = os.path.join(self._path, *modules[:-1])
        files = ["%s.%s" % (modules[-1], ext) for ext in self._extensions]
        for dir_name in os.listdir(path):
            for file_name in files:
                if dir_name == file_name:
                    modules[-1] = file_name
                    return os.path.join(self._path, *modules)

    def output(self, file, format, extra_scripts=""):
        extra_scripts = extra_scripts.split(",")
        if format == 'sprockets':
            self.output_sprockets_manifest(file, extra_scripts)
        elif format == "html":
            self.output_html_scripts(file, extra_scripts)
        else:
            raise ValueError("Unknown output format: %s" % format)

    def uri(self):
        return os.path.join(self._uri, *self.name.split("/"))

    def module_list(self, mod_list):
        for module in self.requires:
            module.module_list(mod_list)
            uri = module.uri()
            try:
                mod_list.index(uri)
            except ValueError:
                mod_list.append(uri)
        if self.name:
            uri = self.uri()
            try:
                mod_list.index(uri)
            except ValueError:
                mod_list.append(uri)

    def output_sprockets_manifest(self, output_file, extra_scripts):
        mod_list = extra_scripts
        self.module_list(mod_list)
        lines = [self.SPROCKETS_REQUIRE % line for line in mod_list]
        output_file = open(output_file, "w")
        output_file.writelines(self.SPROCKETS_HEADER)
        output_file.writelines(lines)
        output_file.close()
        print("manifest:\n%s" % ("\n".join(mod_list),))

    def output_html_scripts(self, output_file, extra_scripts):
        mod_list = extra_scripts
        self.module_list(mod_list)
        lines = [self.HTML_SCRIPT_TAG % line for line in mod_list]
        output_file = open(output_file, "w")
        output_file.writelines(lines)
        output_file.close()
        print("manifest:\n%s" % ("\n".join(mod_list),))

if __name__ == '__main__':
    p = OptionParser()
    p.add_option('--base-path', '-p', default='.')
    p.add_option('--base-uri', '-u', default='')
    p.add_option('--output-format', '-o', default='sprockets',
            help="Default: sprockets")
    p.add_option('--output-file', '-O')
    p.add_option('--ext-names', '-e', default='js,coffee,js.erb,coffee.erb',
            help="Default: js,coffee")
    p.add_option('--extra-scripts', '-E', default='kopi',
            help="Default: kopi")
    opts, args = p.parse_args()

    kwargs = {
        'path': opts.base_path,
        'uri': opts.base_uri,
        'extensions': opts.ext_names.split(','),
    }
    root = DepTree(None, **kwargs)
    for script in args:
        tree = DepTree(script, **kwargs)
        tree.build()
        root.requires.append(tree)
    root.output(opts.output_file, opts.output_format, opts.extra_scripts)
