import copy

from FileDescriptor import FileDescriptor


class Command:
    MKDIR        = 0x1
    CREATE       = 0x2
    SYMLINK      = 0x3
    HARDLINK     = 0x4

    REMOVE       = 0x5

    OPEN         = 0x6
    CLOSE        = 0x7
    READ         = 0x8
    WRITE        = 0x9

    RENAME       = 0x10

    SYNC         = 0x11
    FSYNC        = 0x12
    XSYNC        = 0x27

    ENLARGE      = 0x13
    REDUCE       = 0x14

    REMOUNT_ROOT = 0x15
    FALLOCATE    = 0x16

    WRITE_XATTR  = 0x20
    READ_XATTR   = 0x21

    STATFS       = 0x22

    OPEN_TMPFILE = 0x23

    DEEPEN       = 0x24
    MKNOD        = 0x25

    CHROOT       = 0x26

    #
    # Control the probability where each command is built
    #

    @staticmethod
    def all_types():
        return (
            Command.MKDIR,      Command.CREATE, Command.MKNOD,
            Command.HARDLINK,   Command.RENAME, Command.SYMLINK,
            Command.OPEN,       Command.CLOSE,  Command.OPEN_TMPFILE,
            Command.READ,       Command.WRITE,
            Command.READ_XATTR, Command.WRITE_XATTR,
            Command.SYNC,       Command.FSYNC,  Command.REMOVE,
            Command.ENLARGE,    Command.REDUCE, Command.DEEPEN,
            Command.CHROOT,     Command.STATFS, Command.REMOUNT_ROOT,
            Command.XSYNC,      Command.FALLOCATE
        )

    def __init__(self, ty):
        self.type_ = ty

#
# NOTE: Some commands may contain parameter fields,
# and these fields are used only when dumping the command to files.
# When clone commands, all these field are omitted.
#

class Mkdir(Command):
    def __init__(self, path):
        super().__init__(Command.MKDIR)
        self.path_ = path

    def __str__(self):
        return f'MKDIR {self.path_}'

    def __deep_copy__(self, memo):
        return Mkdir(self.path_)


class Create(Command):
    def __init__(self, path):
        super().__init__(Command.CREATE)
        self.path_ = path

        self.param_ = None # Parameter field

    def __str__(self):
        return f'CREATE {self.path_}'

    def __deep_copy__(self, memo):
        return Create(self.path_)


class Symlink(Command):
    def __init__(self, new_path, old_path):
        super().__init__(Command.SYMLINK)
        self.old_path_ = old_path
        self.new_path_ = new_path

    def __str__(self):
        return f'SYMLINK {self.old_path_} {self.new_path_}'

    def __deep_copy__(self, memo):
        return Symlink(self.new_path_, self.old_path_)


class Hardlink(Command):
    def __init__(self, new_path, old_path):
        super().__init__(Command.HARDLINK)
        self.old_path_ = old_path
        self.new_path_ = new_path

    def __str__(self):
        return f'HARDLINK {self.old_path_} {self.new_path_}'

    def __deep_copy__(self, memo):
        return Hardlink(self.new_path_, self.old_path_)


class Remove(Command):
    def __init__(self, path):
        super().__init__(Command.REMOVE)
        self.path_ = path

    def __str__(self):
        return f'REMOVE {self.path_}'

    def __deep_copy__(self, memo):
        return Remove(self.path_)


class Open(Command):
    def __init__(self, path):
        super().__init__(Command.OPEN)
        self.path_ = path
        self.fd_ = FileDescriptor(path)

        self.param_ = None # Parameter field

    def __str__(self):
        return f'OPEN {self.path_}'

    def __deep_copy__(self, memo):
        return Open(self.path_)


class OpenTmpfile(Command):
    def __init__(self, path):
        super().__init__(Command.OPEN_TMPFILE)
        self.path_ = path
        self.fd_ = FileDescriptor(path)

        self.param_ = None # Parameter field

    def __str__(self):
        return f'OPEN_TMPFILE {self.path_}'

    def __deep_copy__(self, memo):
        return OpenTmpfile(self.path_)


class Close(Command):
    def __init__(self, fd):
        super().__init__(Command.CLOSE)
        self.fd_ = fd

    def __str__(self):
        return f'CLOSE {str(self.fd_)}'

    def __deep_copy__(self, memo):
        return Close(copy.deepcopy(self.fd_))


class Read(Command):
    def __init__(self, fd):
        super().__init__(Command.READ)
        self.fd_ = fd

        self.buf_id_ = None # Parameter field
        self.size_ = None # Parameter field

    def __str__(self):
        return f'READ {str(self.fd_)}'

    def __deep_copy__(self, memo):
        return Read(copy.deepcopy(self.fd_))


class Write(Command):
    def __init__(self, fd):
        super().__init__(Command.WRITE)
        self.fd_ = fd

        self.buf_id_ = None # Parameter field
        self.size_ = None # Parameter field

    def __str__(self):
        return f'WRITE {str(self.fd_)}'

    def __deep_copy__(self, memo):
        return Write(copy.deepcopy(self.fd_))


class Rename(Command):
    def __init__(self, new_path, old_path):
        super().__init__(Command.RENAME)
        self.old_path_ = old_path
        self.new_path_ = new_path

    def __str__(self):
        return f'RENAME {self.old_path_} {self.new_path_}'

    def __deep_copy__(self, memo):
        return Rename(self.new_path_, self.old_path_)


class Sync(Command):
    def __init__(self):
        super().__init__(Command.SYNC)

        self.is_last_ = None # Parameter field

    def __str__(self):
        return 'SYNC'

    def __deep_copy__(self, memo):
        return Sync()


class Fsync(Command):
    def __init__(self, fd):
        super().__init__(Command.FSYNC)
        self.fd_ = fd

        self.is_last_ = None # Parameter field

    def __str__(self):
        return f'FSYNC {str(self.fd_)}'

    def __deep_copy__(self, memo):
        return Fsync(copy.deepcopy(self.fd_))


class Xsync(Command):
    def __init__(self, path):
        super().__init__(Command.XSYNC)
        self.path_ = path

        self.is_last_ = None # Parameter field

    def __str__(self):
        return f'XSYNC {self.path_}'

    def __deep_copy__(self, memo):
        return Xsync(copy.deepcopy(self.path_))


class Enlarge(Command):
    def __init__(self, path):
        super().__init__(Command.ENLARGE)
        self.path_ = path

        self.size_ = None # Parameter field

    def __str__(self):
        return f'ENLARGE {self.path_}'

    def __deep_copy__(self, memo):
        return Enlarge(self.path_)


class Fallocate(Command):
    def __init__(self, path):
        super().__init__(Command.FALLOCATE)
        self.path_ = path

        self.mode_ = None # Parameter field
        self.offset_ = None # Parameter field
        self.size_ = None # Parameter field

    def __str__(self):
        return f'FALLOCATE{self.path_}'

    def __deep_copy__(self, memo):
        return Fallocate(self.path_)


class Reduce(Command):
    def __init__(self, path):
        super().__init__(Command.REDUCE)
        self.path_ = path

    def __str__(self):
        return f'REDUCE {self.path_}'

    def __deep_copy__(self, memo):
        return Reduce(self.path_)


class WriteXattr(Command):
    def __init__(self, path, key, value):
        super().__init__(Command.WRITE_XATTR)
        self.path_ = path
        self.key_ = key
        self.value_ = value

    def __str__(self):
        return f'WRITE_XATTR {self.path_} {self.key_}: {self.value_}'

    def __deep_copy__(self, memo):
        return WriteXattr(self.path_, self.key_, self.value_)


class ReadXattr(Command):
    def __init__(self, path, key):
        super().__init__(Command.READ_XATTR)
        self.path_ = path
        self.key_ = key

    def __str__(self):
        return f'READ_XATTR {self.path_} {self.key_}'

    def __deep_copy__(self, memo):
        return ReadXattr(self.path_, self.key_)


class RemountRoot(Command):
    def __init__(self):
        super().__init__(Command.REMOUNT_ROOT)

    def __str__(self):
        return 'REMOUNT_ROOT'

    def __deep_copy__(self, memo):
        return RemountRoot()


class StatFs(Command):
    def __init__(self, path):
        super().__init__(Command.STATFS)
        self.path_ = path

    def __str__(self):
        return f'STATFS {self.path_}'

    def __deep_copy__(self, memo):
        return StatFs(self.path_)


class Deepen(Command):
    def __init__(self, path):
        super().__init__(Command.DEEPEN)
        self.path_ = path

        self.depth_ = None # Parameter field

    def __str__(self):
        return f'DEEPEN {self.path_}'

    def __deep_copy__(self, memo):
        return Deepen(self.path_)


class Mknod(Command):
    def __init__(self, path):
        super().__init__(Command.MKNOD)
        self.path_ = path

        self.mode_ = None # Parameter field
        self.dev_ = None # Parameter field

    def __str__(self):
        return f'MKNOD {self.path_}'

    def __deep_copy__(self, memo):
        return Mknod(self.path_)


class Chroot(Command):
    """ This command is used only for generation.
        It will not be translated into C code. """

    def __init__(self, path):
        super().__init__(Command.CHROOT)
        self.path_ = path

    def __str__(self):
        return f'CHROOT {self.path_}'

    def __deep_copy__(self, memo):
        return Chroot(self, path_)
