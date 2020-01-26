from Command import Command


class Writer:
    writers = {}

    @staticmethod
    def add(cmd_type):
        def wrap(func):
            Writer.writers[cmd_type] = func
            return func
        return wrap


class CodeWriter:
    def write_command(self, cmd):
        assert cmd.type_ in Writer.writers
        return Writer.writers[cmd.type_](self, cmd)

    @Writer.add(Command.MKDIR)
    def _write_mkdir(self, cmd):
        return f'do_mkdir("{cmd.path_}", {cmd.param_})'

    @Writer.add(Command.CREATE)
    def _write_create(self, cmd):
        return f'do_create("{cmd.path_}", {cmd.param_})'

    @Writer.add(Command.SYMLINK)
    def _write_symlink(self, cmd):
        return f'do_symlink("{cmd.old_path_}", "{cmd.new_path_}")'

    @Writer.add(Command.HARDLINK)
    def _write_hardlink(self, cmd):
        return f'do_hardlink("{cmd.old_path_}", "{cmd.new_path_}")'

    @Writer.add(Command.REMOVE)
    def _write_remove(self, cmd):
        return f'do_remove("{cmd.path_}")'

    @Writer.add(Command.OPEN)
    def _write_open(self, cmd):
        return f'do_open({str(cmd.fd_)}, "{cmd.path_}", {cmd.param_})'

    @Writer.add(Command.OPEN_TMPFILE)
    def _write_open_tmpfile(self, cmd):
        return f'do_open_tmpfile({str(cmd.fd_)}, "{cmd.path_}", {cmd.param_})'

    @Writer.add(Command.CLOSE)
    def _write_close(self, cmd):
        return f'do_close({str(cmd.fd_)})'

    @Writer.add(Command.READ)
    def _write_read(self, cmd):
        return f'do_read({str(cmd.fd_)}, {cmd.buf_id_}, {cmd.size_})'
        # return f'do_read({str(cmd.fd_)}, {buf_id}, 4096)'

    @Writer.add(Command.WRITE)
    def _write_write(self, cmd):
        return f'do_write({str(cmd.fd_)}, {cmd.buf_id_}, {cmd.size_})'
        # return f'do_write({str(cmd.fd_)}, {buf_id}, 4096)'

    @Writer.add(Command.RENAME)
    def _write_rename(self, cmd):
        return f'do_rename("{cmd.old_path_}", "{cmd.new_path_}")'

    @Writer.add(Command.SYNC)
    def _write_sync(self, cmd):
        if cmd.is_last_:
            return f'do_sync(true)'
        else:
            return f'do_sync(false)'

    @Writer.add(Command.FSYNC)
    def _write_fsync(self, cmd):
        if cmd.is_last_:
            return f'do_fsync({str(cmd.fd_)}, true)'
        else:
            return f'do_fsync({str(cmd.fd_)}, false)'

    @Writer.add(Command.XSYNC)
    def _write_xsync(self, cmd):
        if cmd.is_last_:
            return f'do_xsync("{cmd.path_}", true)'
        else:
            return f'do_xsync("{cmd.path_}", false)'

    @Writer.add(Command.ENLARGE)
    def _write_enlarge(self, cmd):
        return f'do_enlarge("{cmd.path_}", {cmd.size_})'

    @Writer.add(Command.FALLOCATE)
    def _write_fallocate(self, cmd):
        return f'do_fallocate("{cmd.path_}", {cmd.mode_}, {cmd.offset_}, {cmd.size_})'

    @Writer.add(Command.REDUCE)
    def _write_reduce(self, cmd):
        return f'do_reduce("{cmd.path_}")'

    @Writer.add(Command.WRITE_XATTR)
    def _write_write_xattr(self, cmd):
        return f'do_write_xattr("{cmd.path_}", "{cmd.key_}", "{cmd.value_}")'

    @Writer.add(Command.READ_XATTR)
    def _write_read_xattr(self, cmd):
        return f'do_read_xattr("{cmd.path_}", "{cmd.key_}")'

    @Writer.add(Command.REMOUNT_ROOT)
    def _write_remount_root(self, cmd):
        return 'do_remount_root()'

    @Writer.add(Command.STATFS)
    def _write_statfs(self, cmd):
        return f'do_statfs("{cmd.path_}")'

    @Writer.add(Command.DEEPEN)
    def _write_deepen(self, cmd):
        return f'do_deepen("{cmd.path_}", {cmd.depth_})'

    @Writer.add(Command.MKNOD)
    def _write_mknod(self, cmd):
        return f'do_mknod("{cmd.path_}", {cmd.mode_}, {cmd.dev_})'

    @Writer.add(Command.CHROOT)
    def _write_chroot(self, cmd):
        return f'// do_chroot("{cmd.path_}")'



