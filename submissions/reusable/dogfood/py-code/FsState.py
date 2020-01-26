import copy

from FsTree import FsTree
from CommandBuilder import CommandBuilder
from ParamBuilder import ParamBuilder
from Sequence import Sequence
from NameSpace import NameSpace
from Command import Command

import config


class FsState:
    def __init__(self):
        self.seq_ = Sequence('test_syscall')
        self.tree_ = FsTree()
        self.namespace_ = NameSpace()

    def take_command(self, cmd):
        self.seq_.push(cmd)
        self.tree_.take_command(cmd)

    def rand_gen(self, l=10):
        for _ in range(l):
            # self.tree_.dump_tree()

            builder = CommandBuilder(self)
            cmd = builder.random_command()
            assert cmd is not None
            # print(cmd)

            self.take_command(cmd)

    def kmeans_gen(self, l=10):
        for _ in range(l):
            builder = CommandBuilder(self)
            cmd = builder.kmeans_random_command()
            assert cmd is not None
            # print(cmd)

            self.take_command(cmd)

    def expand_param(self):
        #
        # Expand commands with parameters
        #
        param_builder = ParamBuilder()
        for cmd in self.seq_:
            param_builder.expand_command(cmd)

        #
        # The last sync/fsync is a corner case for B3 workload generation
        #
        for i in range(len(self.seq_) - 1, -1, -1) :
            if self.seq_[i].type_ in (Command.SYNC, Command.FSYNC, Command.XSYNC):
                self.seq_[i].is_last_ = True
                break

    def __deep_copy__(self, memo):
        state = FsState()

        state.seq_ = copy.deepcopy(seq)
        state.tree_ = copy.deepcopy(self.tree_)
        state.namespace_ = copy.deepcopy(self.namespace_)

        return state

    def __hash__(self):
        return hash(self.tree_)
