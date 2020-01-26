from Jnode import Jnode, DirNode, FileNode, SymlinkNode

from abc import abstractmethod


class Visitor:
    def __init__(self):
        pass

    def process(self, tree):
        self._visit(tree.root_)

    def _visit(self, node):
        if node.type_ == Jnode.DIR:
            self._visit_dir(node)
        elif node.type_ == Jnode.FILE:
            self._visit_file(node)
        elif node.type_ == Jnode.SYMLINK:
            self._visit_symlink(node)

    @abstractmethod
    def _visit_dir(self, node):
        pass

    @abstractmethod
    def _visit_file(self, node):
        pass

    @abstractmethod
    def _visit_symlink(self, node):
        pass


class Dumper(Visitor):
    def __init__(self):
        super().__init__()
        self.indent_flags_ = []

    def str_indent(self):
        str_builder = []
        if len(self.indent_flags_) != 0:
            for f in self.indent_flags_[0:-1]:
                if f:
                    str_builder.append('|   ')
                else:
                    str_builder.append('    ')
            str_builder.append('|-- ')

        return ''.join(str_builder)

    def _visit_dir(self, node):
        print(self.str_indent(), str(node))

        node_children = node.get_children()
        self.indent_flags_.append(True)

        if not node_children:
            pass
        elif len(node_children) == 1:
            self.indent_flags_[-1] = False
            self._visit(node.get_children()[0])
        else:
            for child in node.get_children()[0:-1]:
                self._visit(child)

            self.indent_flags_[-1] = False
            self._visit(node.get_children()[-1])

        self.indent_flags_.pop()

    def _visit_file(self, node):
        print(self.str_indent(), str(node))

    def _visit_symlink(self, node):
        print(self.str_indent(), str(node))

