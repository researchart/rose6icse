import random

from abc import abstractmethod

from Visitor import Visitor
from Jnode import Jnode, DirNode, FileNode, SymlinkNode


class Picker(Visitor):
    def __init__(self):
        super().__init__()

    def pick_dir(self, tree):
        return self._pick(tree, [Jnode.DIR,])

    def pick_file(self, tree):
        return self._pick(tree, [Jnode.FILE,])

    def pick_any(self, tree):
        return self._pick(tree, [Jnode.DIR,
                                 Jnode.FILE, Jnode.SYMLINK, Jnode.SPECIAL])

    def pick_nonlink(self, tree):
        return self._pick(tree, [Jnode.DIR, Jnode.FILE, Jnode.SPECIAL])

    def pick_fd(self, tree):
        if not tree.fd_pool_:
            return []
        return [random.choice(tree.fd_pool_)]

    @abstractmethod
    def _pick(self, tree, node_types):
        pass
