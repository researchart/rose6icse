import M4
import random

from Command import Command


class Builder:
    builders = {}
    @staticmethod
    def add(*cmd_types):
        def wrap(func):
            for ty in cmd_types:
                Builder.builders[ty] = func
            return func
        return wrap


class ParamBuilder:
    _mode_params = (
        'S_IRWXU',
        'S_IWUSR',
        'S_IRGRP',
        'S_IROTH',
    )

    _open_params = (
        'O_RDWR',
        'O_APPEND',
        'O_DIRECT',
        'O_DSYNC',
        'O_LARGEFILE',
        'O_NOATIME',
        'O_NONBLOCK',
        'O_SYNC',
    )

    _mount_params = (
        'MS_DIRSYNC',
        'MS_LAZYTIME',
        'MS_NODEV',
        'MS_RELATIME',
        'MS_NODIRATIME',
        'MS_NOATIME',
        'MS_SYNCHRONOUS',
    )

    _unmount_params = (
        'MNT_FORCE',
        'MNT_DETACH',
    )

    @Builder.add(Command.MKDIR, Command.CREATE)
    def _build_mode_param(self):
        return f'S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH'

    @Builder.add(Command.OPEN, Command.OPEN_TMPFILE)
    def _build_open_param(self):
        params = ['O_RDWR']

        for p in ParamBuilder._open_params:
            if M4.true_with_prob(10):
                params.append(p)

        return ' | '.join(params)

    @Builder.add(Command.READ, Command.WRITE)
    def _build_read_write_param(self):
        buf_id = random.randint(0, 15)
        size = random.randint(1, 20) * 4096

        return buf_id, size

    @Builder.add(Command.MKNOD)
    def _build_mknod_param(self):
        modes = ('S_IRWXU', 'S_IRWXG', 'S_IROTH', 'S_IXOTH')
        devs = ('S_IFREG', 'S_IFCHR', 'S_IFBLK', 'S_IFIFO', 'S_IFSOCK')

        m = M4.rand_sample(modes)
        d = M4.rand_sample(devs)
        return '|'.join(m + d), random.randint(0, 10000000) # mode, dev

    @Builder.add(Command.DEEPEN)
    def _build_deepen_param(self):
        return random.randint(1, 1 << 10)

    @Builder.add(Command.ENLARGE)
    def _build_enlarge_param(self):
        return random.randint(1, 1 << 13)

    @Builder.add(Command.FALLOCATE)
    def _build_fallocate_param(self):
        mode = random.choice([0, 'FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE'])
        offset = random.randint(1, 1024)
        size = random.randint(1, 1024)
        return mode, offset, size

    def build_for(self, cmd_type):
        if cmd_type not in Builder.builders:
            return ''
        else:
            return Builder.builders[cmd_type](self)

    def expand_command(self, cmd):
        if cmd.type_ in (Command.CREATE, Command.MKDIR):
            cmd.param_ = self._build_mode_param()
        elif cmd.type_ in (Command.OPEN, Command.OPEN_TMPFILE):
            cmd.param_ = self._build_open_param()
        elif cmd.type_ in (Command.READ, Command.WRITE):
            cmd.buf_id_, cmd.size_ = self._build_read_write_param()
        elif cmd.type_ == Command.MKNOD:
            cmd.mode_, cmd.dev_ = self._build_mknod_param()
        elif cmd.type_ == Command.DEEPEN:
            cmd.depth_ = self._build_deepen_param()
        elif cmd.type_ == Command.ENLARGE:
            cmd.size_ = self._build_enlarge_param()
        elif cmd.type_ == Command.FALLOCATE:
            cmd.mode_, cmd.offset_, cmd.size_ = self._build_fallocate_param()
        else:
            pass