"""Support linking a symbol to a line of code defining the symbol.

Run etags over the source tree to produce a TAGS file, parse the TAGS
file, and construct a mapping from a symbol to a line of code defining
the symbol.

Warning: In source with conditional compilation or otherwise one
symbol declared in multiple namespaces (eg type vs function) this
simple trick may fail.  And it does fail a lot.
"""

import os
import re
import subprocess
import json
import logging

import sources

################################################################


class Tags:
    """Link a symbol to a line of code defining the symbol."""

    def __init__(self, srcdir=".", tagscmd="etags", tagsfile="TAGS",
                 fltr=""):
        """Initialize by running tags over source tree."""
        self.define = {}
        self.function = {}
        self.variable = {}

        # Use process id to generate a "unique" name for the tags file
        # to enable concurrent invocations of cbmc-viewer.  The
        # tempfile module does not help here, because it may create a
        # file in another directory, and etags generates paths
        # relative to the source directory and the output file
        # directory.
        tagsfile += '-' + str(os.getpid())

        self.make_tags_file(srcdir, tagscmd, tagsfile, fltr)
        self.parse_tags_file(tagsfile)
        self.cleanup_tags()

    @staticmethod
    def make_tags_file(srcdir=".", tagscmd="etags", tagsfile="TAGS",
                       fltr=""):
        """Make a tags file for a source tree."""

        files = sources.find_sources(srcdir, fltr)
        run_etags(srcdir, files, tagscmd, tagsfile)

        try:
            os.rename(os.path.join(srcdir, tagsfile),
                      os.path.join('.', tagsfile))
        except OSError as e:
            print(("Can't construct symbol table: "
                   "Can't move file {} to {}: {}")
                  .format(srcdir+'/'+tagsfile, './'+tagsfile, e.strerror))
            return

    def parse_tags_file(self, tagsfile="TAGS"):
        """Parse a tags file for a source tree."""
        # pylint: disable=too-many-locals

        try:
            tagsfh = open(tagsfile, "r")
        except IOError as e:
            print(("Can't parse symbol table: "
                   "Can't open file {}: {}")
                  .format(tagsfile, e.strerror))
            return

        section_finished = False
        for line in tagsfh:
            line = re.sub('\b+', ' ', line).strip()

            # Current line is "^L"
            if line == '':
                srcfile = ""
                section_finished = True
                continue

            # Current line is "string,integer"
            if section_finished:
                srcfile = line.split(',')[0]
                section_finished = False
                continue

            # Current line is "string^?integer,integer"
            # or "string^?string^Ainteger,integer"
            exp = "(.*)%c(.*%c)?(.*)" % (chr(127), chr(1))
            match = re.match(exp, line)
            if not match:
                continue

            decl = match.group(1).strip()
            num = int(match.group(3).split(',')[0].strip())

            ispragma = decl.startswith('#')
            isdefine = (decl.startswith('#define') or
                        decl.startswith('#undef'))
            # isarray = decl.endswith('[')
            isfunction = decl.endswith('(')
            name = decl.split(' ')[-1].strip('*[(;,')

            if isdefine:
                if not self.define.get(name):
                    self.define[name] = []
                self.define[name].append((srcfile, num))
                continue
            if ispragma:
                continue
            if isfunction:
                if not self.function.get(name):
                    self.function[name] = []
                self.function[name].append((srcfile, num))
                continue
            if not self.variable.get(name):
                self.variable[name] = []
            self.variable[name].append((srcfile, num))

    def cleanup_tags(self):
        """Organize the result of parsing a tags file."""
        for name in self.define:
            self.define[name].sort()
        for name in self.function:
            self.function[name].sort()
        for name in self.variable:
            self.variable[name].sort()

    def lookup(self, name):
        """Lookup a symbol in the tags file."""
        f = self.function.get(name)
        v = self.variable.get(name)
        d = self.define.get(name)
        result = []
        if f:
            result.extend(f)
        if v:
            result.extend(v)
        if d:
            result.extend(d)
        return result

################################################################

def run(cmd, verbose=False, cwd=None):
    """Run a command in a directory."""

    if isinstance(cmd, str):
        cmd = cmd.split()
    if verbose:
        print('Running: {}'.format(' '.join(cmd)))

    result = subprocess.run(cmd, cwd=cwd,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            universal_newlines=True)
    if result.returncode:
        debug = {'command': result.args,
                 'returncode': result.returncode,
                 'stdout': result.stdout.split('\n'),
                 'stderr': result.stderr.split('\n')}
        logging.info(json.dumps(debug, indent=2))
    result.check_returncode()

    return result.stdout

################################################################

def run_etags(root, files, etags_command, etags_filename):
    """Run etags on a list of files to generate symbol definitions."""

    if not files:
        return ''
    etags_pathname = os.path.join(root, etags_filename)

    try:
        os.remove(etags_pathname)
    except FileNotFoundError:
        pass # file did not exist

    while files:
        prefix, files = files[:100], files[100:]
        run([etags_command, '-o', etags_filename, '--append'] + prefix,
            cwd=root)

    with open(etags_pathname) as etags_data:
        return etags_data.read()
