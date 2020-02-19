import random

from Picker import Picker
from Visitor import Visitor
from Jnode import Jnode, DirNode, FileNode, SymlinkNode


class RandomPicker(Picker):
    def __init__(self):
        super().__init__()
        self.picked_nodes_ = []
        self.num_to_pick_ = 1
        self.curr_no_ = 1
        self.which_to_pick_ = [Jnode.FILE,]

    def _pick(self, tree, node_types):
        self.which_to_pick_ = node_types

        self.picked_nodes_ = []
        self.num_to_pick_ = 1
        self.curr_no = 1

        self._visit(tree.working_root_)

        if self.picked_nodes_:
            return [random.choice(self.picked_nodes_)]
        else:
            return []

    def _sample(self, node):
        self.curr_no_ += 1
        #
        # Keep the first N items in memory
        #
        if len(self.picked_nodes_) < self.num_to_pick_:
            self.picked_nodes_.append(node)
        else:
            #
            # With probability N/i keep the new item
            #
            if random.randint(0, self.curr_no_) < self.num_to_pick_:
                pos = random.randint(0, self.num_to_pick_ - 1)
                self.picked_nodes_[pos] = node
            else:
                pass

    def _visit_dir(self, node):
        if Jnode.DIR in self.which_to_pick_:
            self._sample(node)

        for child in node:
            self._visit(child)

    def _visit_file(self, node):
        if Jnode.FILE in self.which_to_pick_:
            self._sample(node)

    def _visit_symlink(self, node):
        if Jnode.SYMLINK in self.which_to_pick_:
            self._sample(node)
