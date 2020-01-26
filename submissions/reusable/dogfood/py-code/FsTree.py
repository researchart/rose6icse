import copy
import M4

from Jnode import Jnode, DirNode, FileNode, SymlinkNode, SpecialNode
from Visitor import Dumper
from Command import Command
from FileDescriptor import FileDescriptor


class Taker:
    takers = {}

    @staticmethod
    def add(cmd_type):
        def wrap(func):
            Taker.takers[cmd_type] = func
            return func
        return wrap


class Nonexistent(Exception):
    def __init__(self, path):
        super().__init__(self, path)
        self.path_ = path

    def __str__(self):
        return f'`{self.path_}` does not exist.'


class FdException(Exception):
    def __init__(self, fd_key):
        super().__init__(self, fd_key)
        self.fd_key_ = fd_key

    def __str__(self):
        return f'`{self.fd_key_}` does not exist.'


class FsTree:
    """ All `path` should start with /, i.e., /xx/yy/xx """
    def __init__(self):
        self.root_ = DirNode()
        self.fd_pool_ = []
        self.time_count_ = 0
        self.sync_count_ = 0
        self.node_count_ = 1
        #
        # When generating commands, nodes are selected under working_root_
        # chroot command will change the working_root_
        #
        self.working_root_ = self.root_

    def __deep_copy__(self, memo):
        tree = FsTree()

        tree.root_ = copy.deepcopy(self.root_, {})
        tree.fd_pool_ = [copy.deepcopy(fd) for fd in self.fd_pool_]
        tree.time_count_ = self.time_count_
        tree.sync_count_ = self.sync_count_
        tree.node_count_ = self.node_count_

        tree.working_root_ = tree._must_lookup_node(self.working_root_.get_path())

        return tree

    def _add_node(self, path, node):
        parent_path = M4.parent_dir(path)
        name = M4.basename(path)

        parent_node = self._must_lookup_node(parent_path)
        parent_node.add_child(name, node)

        node.update_atime(self.time_count_)
        parent_node.update_atime(self.time_count_)
        self.node_count_ += 1

    def _del_node(self, path):
        ''' Just delete the node, not the subtree. Called by move operation'''
        if path == '/':
            print('*** WARNING: to remove root ***')
            return
        parent_path = M4.parent_dir(path)
        name = M4.basename(path)

        parent_node = self._must_lookup_node(parent_path)

        if name in parent_node.get_children_names():
            parent_node.update_atime(self.time_count_)
            removed_child = parent_node.del_child(name)
            return removed_child
        else:
            return None

    def _del_subtree(self, path):
        ''' Note the difference with `_del_node` '''
        node = self._must_lookup_node(path)

        if node.type_ == Jnode.DIR:
            for name in node.get_children_names():
                self._del_subtree(M4.path_join(path, name))
        elif node.type_ == Jnode.SYMLINK:
            link_target = self._lookup_node(node.target_path_)
            if link_target:
                if link_target.num_symlinked_ > 0:
                    link_target.dec_num_symlinked()

        parent_path = M4.parent_dir(path)
        parent_node = self._must_lookup_node(parent_path)

        parent_node.update_atime(self.time_count_)

        name = M4.basename(path)
        parent_node.del_child(name)

        assert self.node_count_ > 0
        self.node_count_ -= 1

    def _lookup_node(self, path):
        assert path.startswith('/')
        if path == '/':
            return self.root_

        names = path.split('/')[1:]

        node = self.root_
        for name in names:
            assert node.type_ == Jnode.DIR

            node = node.lookup_child(name)
            if node is None:
                return None
        return node

    def _must_lookup_node(self, path):
        node = self._lookup_node(path)
        if not node:
            raise Nonexistent(path)
        return node

    def _move_node(self, new_path, old_path):
        node = self._del_node(old_path)
        if not node:
            raise Nonexistent(old_path)

        new_node = self._lookup_node(new_path)
        if new_node:
            ''' if new_path exists, it must be a empty dir or other file '''
            self._del_subtree(new_path)

        self._add_node(new_path, node)

    def _add_dir(self, path):
        node = DirNode()
        self._add_node(path, node)

    def _add_dir_recursive(self, path):
        path_to_add = [path]

        while True:
            parent_path = M4.parent_dir(path_to_add[-1])
            if not self._lookup_node(parent_path):
                path_to_add.append(parent_path)
            else:
                break

        path_to_add.reverse()

        for path in path_to_add:
            self._add_dir(path)

    def _add_file(self, path):
        node = FileNode()
        self._add_node(path, node)

    def _add_symlink(self, new_path, old_path):
        target_node = self._must_lookup_node(old_path)
        target_node.inc_num_symlinked()

        node = SymlinkNode(old_path)
        self._add_node(new_path, node)

    def _add_hardlink(self, new_path, old_path):
        node = self._must_lookup_node(old_path)
        assert node.type_ == Jnode.FILE
        self._add_node(new_path, node)

    def _add_fd(self, path, fd, is_tmpfile=False):
        if fd in self.fd_pool_:
            raise FdException(str(fd))

        self.fd_pool_.append(fd)

        if not is_tmpfile:
            node = self._must_lookup_node(path)
            assert node.type_ == Jnode.FILE
            node.update_atime(self.time_count_)

    def _del_fd(self, fd):
        if fd not in self.fd_pool_:
            raise FdException(str(fd))

        self.fd_pool_.remove(fd)

    def dump_tree(self):
        print('==== TREE =====')
        dumper = Dumper()
        dumper.process(self)
        print('--- FD POOL ---')
        for fd in self.fd_pool_:
            print(fd)
        print('===============')

    def take_command(self, cmd):
        self.time_count_ += 1

        assert cmd.type_ in Taker.takers
        return Taker.takers[cmd.type_](self, cmd)

    @Taker.add(Command.MKDIR)
    def _take_mkdir(self, cmd):
        self._add_dir(cmd.path_)

    @Taker.add(Command.CREATE)
    def _take_create(self, cmd):
        self._add_file(cmd.path_)

    @Taker.add(Command.SYMLINK)
    def _take_symlink(self, cmd):
        self._add_symlink(cmd.new_path_, cmd.old_path_)

    @Taker.add(Command.HARDLINK)
    def _take_hardlink(self, cmd):
        self._add_hardlink(cmd.new_path_, cmd.old_path_)

    @Taker.add(Command.REMOVE)
    def _take_remove(self, cmd):
        self._del_subtree(cmd.path_)

    @Taker.add(Command.OPEN)
    def _take_open(self, cmd):
        self._add_fd(cmd.path_, cmd.fd_, is_tmpfile=False)

    @Taker.add(Command.OPEN_TMPFILE)
    def _take_open_tmpfile(self, cmd):
        # self._add_fd(cmd.path_, cmd.fd_, is_tmpfile=True)
        pass

    @Taker.add(Command.CLOSE)
    def _take_close(self, cmd):
        self._del_fd(cmd.fd_)

    @Taker.add(Command.READ)
    def _take_read(self, cmd):
        pass

    @Taker.add(Command.WRITE)
    def _take_write(self, cmd):
        pass

    @Taker.add(Command.RENAME)
    def _take_rename(self, cmd):
        self._move_node(cmd.new_path_, cmd.old_path_)

    @Taker.add(Command.SYNC)
    def _take_sync(self, cmd):
        self.sync_count_ += 1

    @Taker.add(Command.FSYNC)
    def _take_fsync(self, cmd):
        self.sync_count_ += 1

    @Taker.add(Command.XSYNC)
    def _take_xsync(self, cmd):
        self.sync_count_ += 1

    @Taker.add(Command.ENLARGE)
    def _take_enlarge(self, cmd):
        node = self._must_lookup_node(cmd.path_)
        node.update_atime(self.time_count_)

    @Taker.add(Command.FALLOCATE)
    def _take_fallocate(self, cmd):
        node = self._must_lookup_node(cmd.path_)
        node.update_atime(self.time_count_)

    @Taker.add(Command.REDUCE)
    def _take_reduce(self, cmd):
        node = self._must_lookup_node(cmd.path_)

        if node.type_ == Jnode.DIR:
            for name in node.get_children_names():
                self._del_subtree(M4.path_join(cmd.path_, name))
            node.clear_children()

        node.update_atime(self.time_count_)

    @Taker.add(Command.WRITE_XATTR)
    def _take_write_xattr(self, cmd):
        node = self._must_lookup_node(cmd.path_)
        node.set_xattr(cmd.key_, cmd.value_)

        node.update_atime(self.time_count_)

    @Taker.add(Command.READ_XATTR)
    def _take_read_xattr(self, cmd):
        node = self._must_lookup_node(cmd.path_)
        #
        # NOTE: we don't read the attribute actually
        #
        node.update_atime(self.time_count_)

    @Taker.add(Command.REMOUNT_ROOT)
    def _take_remount_root(self, cmd):
        pass

    @Taker.add(Command.STATFS)
    def _take_statfs(self, cmd):
        pass

    @Taker.add(Command.DEEPEN)
    def _take_deepen(self, cmd):
        node = self._must_lookup_node(cmd.path_)
        node.update_atime(self.time_count_)

    @Taker.add(Command.MKNOD)
    def _take_mknod(self, cmd):
        node = SpecialNode()
        self._add_node(cmd.path_, node)

    @Taker.add(Command.CHROOT)
    def _take_chroot(self, cmd):
        node = self._must_lookup_node(cmd.path_)
        self.working_root_ = node

    def __hash__(self):
        h = hash(self.root_)
        for fd in self.fd_pool_:
            h = M4.hash_concat(h, hash(fd))
        return M4.hash_concat(h, self.sync_count_)
