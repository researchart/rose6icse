from Command import *
import re

class Parser:
    parsers = {}

    @staticmethod
    def add(cmd_name):
        def wrap(func):
            Parser.parsers[cmd_name] = func
            return func
        return wrap


class CodeParser:
    def parse_command(self, line):
        cmd_name, args = re.findall(r'do_(\w+)\((.*)\);', line)[0]
        assert cmd_name in Parser.parsers
        return Parser.parsers[cmd_name](self, args)

    @Parser.add('mkdir')
    def _parse_mkdir(self, args):
        path, param = args.split(',')
        cmd = Mkdir(path.replace('"', ''))
        cmd.param_ = param.strip()
        return cmd

    @Parser.add('create')
    def _parse_create(self, args):
        path, param = args.split(',')
        cmd = Create(path.replace('"', ''))
        cmd.param_ = param.strip()
        return cmd

    @Parser.add('symlink')
    def _parse_symlink(self, args):
        old_path, new_path = re.findall(r'"(.+?)"', args)
        return Symlink(new_path, old_path)

    @Parser.add('hardlink')
    def _parse_hardlink(self, args):
        old_path, new_path = re.findall(r'"(.+?)"', args)
        return Hardlink(new_path, old_path)

    @Parser.add('remove')
    def _parse_remove(self, args):
        path = re.findall(r'"(.+?)"', args)[0]
        return Remove(path)

    @Parser.add('open')
    def _parse_open(self, args):
        fd, path, param = args.split(',')
        cmd = Open(path.strip().replace('"', ''))

        #
        # NOTE: Open command contains a FileDescriptor field which is str here;
        # however, this field with both types has the same behaviors.
        #
        cmd.fd_ = fd.strip()
        cmd.param_ = param.strip()
        return cmd

    @Parser.add('open_tmpfile')
    def _parse_open_tmpfile(self, args):
        fd, path, param = args.split(',')
        cmd = OpenTmpfile(path.replace('"', ''))
        cmd.fd_ = fd.strip()
        cmd.param_ = param.strip()
        return cmd

    @Parser.add('close')
    def _parse_close(self, args):
        fd = re.search(r'fd_\d+', args)[0]
        return Close(fd)

    @Parser.add('read')
    def _parse_read(self, args):
        fd, buf_id, size = args.split(',')
        cmd = Read(fd.strip())
        cmd.buf_id_ = buf_id.strip()
        cmd.size_ = size.strip()
        return cmd

    @Parser.add('write')
    def _parse_write(self, args):
        fd, buf_id, size = args.split(',')
        cmd = Write(fd.strip())
        cmd.buf_id_ = buf_id.strip()
        cmd.size_ = size.strip()
        return cmd

    @Parser.add('rename')
    def _parse_rename(self, args):
        old_path, new_path = re.findall(r'"(.+?)"', args)
        return Rename(new_path, old_path)

    @Parser.add('sync')
    def _parse_sync(self, args):
        return Sync()

    @Parser.add('fsync')
    def _parse_fsync(self, args):
        fd, is_last = args.split(',')
        cmd = Fsync(fd.strip())
        if is_last.strip() == 'true':
            cmd.is_last_ = True
        return cmd

    @Parser.add('xsync')
    def _parse_xsync(self, args):
        path, is_last = args.split(',')
        cmd = Xsync(path.strip().replace('"', ''))
        if is_last.strip() == 'true':
            cmd.is_last_ = True
        return cmd

    @Parser.add('enlarge')
    def _parse_enlarge(self, args):
        path, size = args.split(',')
        cmd = Enlarge(path.replace('"', ''))
        cmd.size_ = size
        return cmd

    @Parser.add('fallocate')
    def _parse_fallocate(self, args):
        path, mode, offset, size = args.split(',')
        cmd = Fallocate(path.replace('"', ''))
        cmd.mode_ = mode
        cmd.offset_ = offset
        cmd.size_ = size
        return cmd

    @Parser.add('reduce')
    def _parse_reduce(self, args):
        path = re.findall(r'"(.+?)"', args)[0]
        return Reduce(path)

    @Parser.add('write_xattr')
    def _parse_parse_xattr(self, args):
        path, key, value = args.split(',')
        return WriteXattr(path.strip().replace('"', ''),
                          key.strip().replace('"', ''),
                          value.strip().replace('"', ''))

    @Parser.add('read_xattr')
    def _parse_read_xattr(self, args):
        path, key = args.split(',')
        return ReadXattr(path.strip().replace('"', ''),
                         key.strip().replace('"', ''))

    @Parser.add('remount_root')
    def _parse_remount_root(self, args):
        return RemountRoot()

    @Parser.add('statfs')
    def _parse_statfs(self, args):
        path = re.findall(r'"(.+?)"', args)[0]
        return StatFs(path)

    @Parser.add('deepen')
    def _parse_deepen(self, args):
        path, depth = args.split(',')
        cmd = Deepen(path.replace('"', ''))
        cmd.depth_ = depth
        return cmd

    @Parser.add('mknod')
    def _parse_mknod(self, args):
        path, mode, dev = args.split(',')
        cmd = Mknod(path.strip().replace('"', ''))
        cmd.mode_ = mode.strip()
        cmd.dev_ = dev.strip()
        return cmd

    @Parser.add('chroot')
    def _parse_chroot(self, args):
        path = re.findall(r'"(.+?)"', args)[0]
        return Chroot(path)
