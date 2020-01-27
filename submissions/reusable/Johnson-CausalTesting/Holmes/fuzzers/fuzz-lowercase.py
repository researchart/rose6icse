#!/Users/bjohnson/anaconda/bin/python

import sys

import peach as peach

from Peach.Mutators.string import StringCaseMutator

i = sys.argv[1]

mutator = StringCaseMutator(peach,None)
output = StringCaseMutator._mutationLowerCase(mutator, i)

print(output)