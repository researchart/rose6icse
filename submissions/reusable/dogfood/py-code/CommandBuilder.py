import random
from Command import *

from RandomPicker import RandomPicker
from KmeansPicker import KmeansPicker
from Jnode import Jnode

import config
import M4


class Builder:
    builders = {}

    @staticmethod
    def add(cmd_type):
        def wrap(func):
            Builder.builders[cmd_type] = func
            return func

        return wrap


class CommandBuilder:
    def __init__(self, fs_state):
        self.fs_state_ = fs_state

    def _random_available_types(self):
        all_types = [
            ty for ty in Command.all_types()
            if M4.true_with_prob(config.get_command_prob(ty))
        ]
        random.shuffle(all_types)

        if self.fs_state_.tree_.node_count_ >= config.get('TREE_MAX_SIZE'):
            for ty in (Command.MKDIR, Command.CREATE,
                       Command.SYMLINK, Command.HARDLINK):
                if ty in all_types:
                    all_types.remove(ty)

        return all_types

    def random_command(self):
        for ty in self._random_available_types():
            cmd_list = self._random_command(ty)
            if cmd_list:
                return random.choice(cmd_list)
        return None

    def kmeans_random_command(self):
        for ty in self._random_available_types():
            cmd_list = self.kmeans_command(ty)
            if cmd_list:
                return random.choice(cmd_list)
        return None

    def _random_command(self, cmd_type):
        assert cmd_type in Builder.builders
        self.picker_ = RandomPicker()
        return Builder.builders[cmd_type](self)

    def kmeans_command(self, cmd_type):
        assert cmd_type in Builder.builders
        self.picker_ = KmeansPicker()
        return Builder.builders[cmd_type](self)

    @Builder.add(Command.MKDIR)
    def _build_mkdir(self):
        nodes = self.picker_.pick_dir(self.fs_state_.tree_)
        return [
            Mkdir(nd.new_child_path(self.fs_state_.namespace_)) for nd in nodes
        ]

    @Builder.add(Command.CREATE)
    def _build_create(self):
        nodes = self.picker_.pick_dir(self.fs_state_.tree_)
        return [
            Create(nd.new_child_path(self.fs_state_.namespace_)) for nd in nodes
        ]

    @Builder.add(Command.SYMLINK)
    def _build_symlink(self):
        nodes = self.picker_.pick_dir(self.fs_state_.tree_)
        targets = self.picker_.pick_any(self.fs_state_.tree_)

        cmd_list = []
        for nd in nodes:
            for tgt in targets:
                cmd_list.append(
                    Symlink(
                        nd.new_child_path(self.fs_state_.namespace_),
                        tgt.get_path()))
        return cmd_list

    @Builder.add(Command.HARDLINK)
    def _build_hardlink(self):
        nodes = self.picker_.pick_dir(self.fs_state_.tree_)
        targets = self.picker_.pick_file(self.fs_state_.tree_)

        cmd_list = []
        for nd in nodes:
            for tgt in targets:
                assert nd != tgt
                cmd_list.append(
                    Hardlink(
                        nd.new_child_path(self.fs_state_.namespace_),
                        tgt.get_path()))
        return cmd_list

    @Builder.add(Command.REMOVE)
    def _build_remove(self):
        nodes = self.picker_.pick_any(self.fs_state_.tree_)
        nodes = [nd for nd in nodes if nd.get_path() != '/']
        return [Remove(nd.get_path()) for nd in nodes]

    @Builder.add(Command.OPEN)
    def _build_open(self):
        nodes = self.picker_.pick_file(self.fs_state_.tree_)
        return [Open(nd.get_path()) for nd in nodes]

    @Builder.add(Command.OPEN_TMPFILE)
    def _build_open_tmpfile(self):
        nodes = self.picker_.pick_dir(self.fs_state_.tree_)
        return [OpenTmpfile(nd.get_path()) for nd in nodes ]

    @Builder.add(Command.CLOSE)
    def _build_close(self):
        fds = self.picker_.pick_fd(self.fs_state_.tree_)
        return [Close(fd) for fd in fds]

    @Builder.add(Command.READ)
    def _build_read(self):
        fds = self.picker_.pick_fd(self.fs_state_.tree_)
        return [Read(fd) for fd in fds]

    @Builder.add(Command.WRITE)
    def _build_write(self):
        fds = self.picker_.pick_fd(self.fs_state_.tree_)
        return [Write(fd) for fd in fds]

    @Builder.add(Command.RENAME)
    def _build_rename(self):
        old_nodes = self.picker_.pick_any(self.fs_state_.tree_)

        cmd_list = []
        for old_nd in old_nodes:
            if old_nd == self.fs_state_.tree_.root_:
                continue

            nodes = self.picker_.pick_dir(self.fs_state_.tree_)
            for nd in nodes:
                if not nd.get_children() and old_nd.type_ == Jnode.DIR:
                    if M4.true_with_prob(50):
                        new_path = nd.new_child_path(self.fs_state_.namespace_)
                    else:
                        #
                        # Replace the empty dir
                        #
                        new_path = nd.get_path()
                else:
                    new_path = nd.new_child_path(self.fs_state_.namespace_)

                old_path = old_nd.get_path()
                #
                # Rename '/a/b/c' with '/a' or '/a/b/c/d' is forbidden.
                #
                if (new_path.startswith(old_path) or
                    old_path.startswith(new_path)):
                    continue

                cmd_list.append(Rename(new_path, old_path))

        return cmd_list

    @Builder.add(Command.SYNC)
    def _build_sync(self):
        return [Sync()]

    @Builder.add(Command.FSYNC)
    def _build_fsync(self):
        fds = self.picker_.pick_fd(self.fs_state_.tree_)
        return [Fsync(fd) for fd in fds]

    @Builder.add(Command.XSYNC)
    def _build_xsync(self):
        nodes = self.picker_.pick_nonlink(self.fs_state_.tree_)
        return [Xsync(nd.get_path()) for nd in nodes]

    @Builder.add(Command.ENLARGE)
    def _build_enlarge(self):
        nodes = self.picker_.pick_nonlink(self.fs_state_.tree_)
        return [Enlarge(nd.get_path()) for nd in nodes]

    @Builder.add(Command.FALLOCATE)
    def _build_fallocate(self):
        nodes = self.picker_.pick_file(self.fs_state_.tree_)
        return [Fallocate(nd.get_path()) for nd in nodes]

    @Builder.add(Command.REDUCE)
    def _build_reduce(self):
        nodes = self.picker_.pick_nonlink(self.fs_state_.tree_)
        return [Reduce(nd.get_path()) for nd in nodes]

    @Builder.add(Command.WRITE_XATTR)
    def _build_write_xattr(self):
        nodes = self.picker_.pick_any(self.fs_state_.tree_)

        namespace_prefix = random.choice(('security',
                                          'system',
                                          'trusted',
                                          'user'))
        key = M4.rand_str(10)
        value = M4.rand_str(10)
        return [
            WriteXattr(nd.get_path(), f'{namespace_prefix}.{key}', value)
            for nd in nodes
        ]

    @Builder.add(Command.READ_XATTR)
    def _build_read_xattr(self):
        nodes = self.picker_.pick_any(self.fs_state_.tree_)

        return [
            ReadXattr(nd.get_path(), f'{random.choice(nd.get_xattr_keys())}')
            for nd in nodes if nd.get_xattr_keys()
        ]

    @Builder.add(Command.REMOUNT_ROOT)
    def _build_remount_root(self):
        return [RemountRoot()]

    @Builder.add(Command.STATFS)
    def _build_statfs(self):
        nodes = self.picker_.pick_any(self.fs_state_.tree_)
        if not nodes:
            return []
        nd = random.choice(nodes)
        return [StatFs(nd.get_path())]

    @Builder.add(Command.DEEPEN)
    def _build_deepen(self):
        nodes = self.picker_.pick_dir(self.fs_state_.tree_)
        if not nodes:
            return []

        return [Deepen(nd.get_path()) for nd in nodes]

    @Builder.add(Command.CHROOT)
    def _build_chroot(self):
        nodes = self.picker_.pick_dir(self.fs_state_.tree_)
        if not nodes:
            return []

        deep_node = max(nodes, key=lambda nd: nd.get_depth())
        return [Chroot(deep_node.get_path())]

    @Builder.add(Command.MKNOD)
    def _build_mknod(self):
        nodes = self.picker_.pick_dir(self.fs_state_.tree_)
        return [
            Mknod(nd.new_child_path(self.fs_state_.namespace_)) for nd in nodes
        ]

