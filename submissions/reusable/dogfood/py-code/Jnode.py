import copy
import random
import M4


class Jnode:
    id_count_ = 0

    DIR      = 0x1
    FILE     = 0x2
    SYMLINK  = 0x3
    HARDLINK = 0x4
    SPECIAL  = 0x5

    def __init__(self, type):
        self.jnode_id_ = Jnode.id_count_
        Jnode.id_count_ += 1

        self.type_ = type
        #
        # To support hardlink, there may be multiple parent pointing to a node
        # NOTE that /a and /b may be harklinked to the same Jnode.
        # Fu*king tricky case. We use the name(edge) -> parent mapping to
        # maintain the parent linking correctly because name are uids.
        #
        self.parents_ = {}
        self.atime_ = 0
        self.num_symlinked_ = 0
        self.xattr_ = {}
        self.size_ = 0;

    def add_parent(self, name, parent):
        assert name not in self.parents_
        self.parents_[name] = parent

    def del_parent(self, name):
        assert name in self.parents_
        self.parents_.pop(name)

    def get_all_path(self):
        #
        # Only file can be hardlinked
        #
        assert self.type_ == Jnode.FILE
        all_paths = []

        for parent in self.parents_.values():
            parent_path = parent.get_path()
            name = parent.child_name(self)
            all_paths.append(M4.path_join(parent_path, name))

        return all_paths

    def update_atime(self, t):
        self.atime_ = t

    def inc_num_symlinked(self):
        self.num_symlinked_ += 1

    def dec_num_symlinked(self):
        assert self.num_symlinked_ > 0
        self.num_symlinked_ -= 1

    def set_xattr(self, key, value):
        self.xattr_[key] = value

    def get_xattr_keys(self):
        return list(self.xattr_.keys())

    def get_path(self):
        if not self.parents_:
            return '/'
        #
        # Randomly generate a valid path to the node
        #
        parent = random.choice(list(self.parents_.values()))
        return M4.path_join(parent.get_path(), parent.child_name(self))

    def get_depth(self):
        depth = 1
        node = self

        while node.parents_:
            #
            # Randomly generate a valid path to the node
            #
            parent = random.choice(list(node.parents_.values()))

            depth += 1
            node = parent

        return depth


class DirNode(Jnode):
    def __init__(self):
        super().__init__(Jnode.DIR)
        #
        # children is a mapping: name(edge) -> node
        #
        self.children_ = {}

    def add_child(self, name, node):
        assert name not in self.children_
        self.children_[name] = node

        node.add_parent(name, self)

    def del_child(self, name):
        assert name in self.children_
        child = self.children_.pop(name)

        child.del_parent(name)
        return child

    def clear_children(self):
        for name in list(self.children_.keys()):
            self.del_child(name)

    def lookup_child(self, name):
        return self.children_.get(name, None)

    def child_name(self, node):
        for (name, child) in self.children_.items():
            if node == child:
                return name
        return None

    def new_child_path(self, ns):
        return M4.path_join(self.get_path(), ns.unique_name())

    def get_children(self):
        return list(self.children_.values())

    def get_children_names(self):
        return list(self.children_.keys())

    def get_vec(self):
        # [$type, #num_symlinked, $atime, #depth, #hardlink, #children, #num_open]
        return [Jnode.DIR,
                self.num_symlinked_,
                self.atime_,
                self.get_depth(),
                len(self.parents_),
                len(self.children_),
                0]

    def __iter__(self):
        return iter(self.children_.values())

    def __str__(self):
        return f'D {self.get_path()}'

    def __repr__(self):
        return str(self)

    def __hash__(self):
        h = M4.hash_int(Jnode.DIR)
        for (name, child) in self.children_.items():
            h_child = M4.hash_concat(M4.hash_str(name), hash(child))
            h = M4.hash_concat(h, h_child)
        return h

    def __deep_copy__(self, memo):
        if self.jnode_id_ in memo:
            return memo[self.jnode_id_]

        node = DirNode()
        node.atime_ = self.atime_
        node.num_symlinked_ = self.num_symlinked_
        node.xattr_ = copy.deepcopy(self.xattr_)
        node.size_ = copy.deepcopy(self.size_)

        for (name, child) in self.children_.items():
            child_copy = copy.deepcopy(child, memo)
            node.add_child(name, child_copy)
            child_copy.add_parent(name, node)

        memo[self.jnode_id_] = node
        return node


class FileNode(Jnode):
    def __init__(self):
        super().__init__(Jnode.FILE)
        self.num_open_ = 0

    def get_vec(self):
        # [$type, #num_symlinked, $atime, #depth, #hardlink, #children, #num_open]
        return [Jnode.FILE,
                self.num_symlinked_,
                self.atime_,
                self.get_depth(),
                len(self.parents_),
                0,
                self.num_open_]

    def __str__(self):
        s = []
        for path in self.get_all_path():
            s.append(path)
        return f"F {' | '.join(s)}"

    def __repr__(self):
        return str(self)

    def __hash__(self):
        return M4.hash_int(Jnode.FILE)

    def __deep_copy__(self, memo):
        if self.jnode_id_ in memo:
            return memo[self.jnode_id_]

        node = FileNode()
        node.atime_ = self.atime_
        node.num_symlinked_ = self.num_symlinked_
        node.num_open_ = self.num_open
        node.xattr_ = copy.deepcopy(self.xattr_)
        node.size_ = copy.deepcopy(self.size_)

        memo[self.jnode_id_] = node
        return node


class SymlinkNode(Jnode):
    def __init__(self, target_path):
        super().__init__(Jnode.SYMLINK)
        self.target_path_ = target_path

    def get_vec(self):
        # [$type, #num_symlinked, $atime, #depth, #hardlink, #children, #num_open]
        return [Jnode.SYMLINK,
                self.num_symlinked_,
                self.atime_,
                self.get_depth(),
                len(self.parents_),
                0,
                0]

    def __str__(self):
        return f'SL {self.get_path()} -> {self.target_path_}'

    def __repr__(self):
        return str(self)

    def __hash__(self):
        h1 = M4.hash_int(Jnode.SYMLINK)
        h2 = M4.hash_str(self.target_path_)
        return M4.hash_concat(h1, h2)

    def __deep_copy__(self, memo):
        if self.jnode_id_ in memo:
            return memo[self.jnode_id_]

        node = SymlinkNode(self.target_path)
        node.atime_ = self.atime_
        node.num_symlinked_ = self.num_symlinked_
        node.xattr_ = copy.deepcopy(self.xattr_)
        node.size_ = copy.deepcopy(self.size_)

        memo[self.jnode_id_] = node
        return node


class SpecialNode(Jnode):
    def __init__(self):
        super().__init__(Jnode.SPECIAL)

    def get_vec(self):
        # [$type, #num_symlinked, $atime, #depth, #hardlink, #children, #num_open]
        return [Jnode.SPECIAL,
                self.num_symlinked_,
                self.atime_,
                self.get_depth(),
                len(self.parents_),
                0,
                0]

    def __str__(self):
        return f'X {self.get_path()}'

    def __repr__(self):
        return str(self)

    def __hash__(self):
        return M4.hash_int(Jnode.SPECIAL)

    def __deep_copy__(self, memo):
        if self.jnode_id_ in memo:
            return memo[self.jnode_id_]

        node = SpecialNode()
        node.atime_ = self.atime_
        node.num_symlinked_ = self.num_symlinked_
        node.xattr_ = copy.deepcopy(self.xattr_)
        node.size_ = copy.deepcopy(self.size_)

        memo[self.jnode_id_] = node
        return node