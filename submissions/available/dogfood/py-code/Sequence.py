from Command import Command
import queue
import M4


class Sequence:

    def __init__(self, name):
        super().__init__()
        self.cmd_list_ = []
        self.name_ = name

    def push(self, cmd):
        self.cmd_list_.append(cmd)

    def last_command(self):
        return self.cmd_list_[-1]

    def dump(self):
        for cmd in self.cmd_list_:
            cmd.dump()

    def all_fd_keys(self):
        fd_keys = set()

        for cmd in self.cmd_list_:
            if cmd.type_ in (Command.OPEN, Command.OPEN_TMPFILE):
                fd_keys.add(str(cmd.fd_))

        return sorted(list(fd_keys))

    def truncate(self, length):
        new_seq = Sequence(self.name_)
        new_seq.cmd_list_ = self.cmd_list_[:length]
        return new_seq

    def filter_out(self, idx):
        seq_len = len(self.cmd_list_)
        flags = [True] * seq_len

        flags[idx] = False
        worklist = queue.Queue()

        cmd = self.cmd_list_[idx]
        worklist.put(self._fetch_command_def(cmd))

        while not worklist.empty():
            cmd_def = worklist.get()
            for i in range(idx, seq_len):
                if flags[i]:
                    cmd = self.cmd_list_[i]
                    if cmd_def in self._fetch_command_use(cmd):
                        flags[i] = False
                        worklist.put(self._fetch_command_def(cmd))

        new_seq = Sequence(self.name_)
        new_seq.cmd_list_ = [
            cmd for (idx, cmd) in enumerate(self.cmd_list_) if flags[idx]
        ]
        return new_seq

    def _fetch_command_def(self, cmd):
        if cmd.type_ in (Command.MKDIR, Command.CREATE, Command.MKNOD):
            return cmd.path_
        elif cmd.type_ in (Command.SYMLINK, Command.HARDLINK, Command.RENAME):
            return cmd.new_path_
        elif cmd.type_ in (Command.OPEN, Command.OPEN_TMPFILE):
            return cmd.fd_
        else:
            return None

    def _fetch_command_use(self, cmd):
        if cmd.type_ in (Command.MKDIR, Command.CREATE, Command.MKNOD):
            return [M4.parent_dir(cmd.path_)]
        elif cmd.type_ in (Command.SYMLINK, Command.HARDLINK, Command.RENAME):
            return [cmd.old_path_, M4.parent_dir(cmd.new_path_)]
        elif cmd.type_ in (Command.CLOSE, Command.READ,
                           Command.WRITE, Command.FSYNC):
            return [cmd.fd_]
        elif cmd.type_ in (Command.SYNC, Command.REMOUNT_ROOT):
            return []
        else:
            return [cmd.path_]

    def __deep_copy__(self, memo):
        seq_copy = Sequence(self.name_)
        for cmd in self.cmd_list_:
            seq_copy.push(copy.deepcopy(cmd))

    def __len__(self):
        return len(self.cmd_list_)

    def __iter__(self):
        return iter(self.cmd_list_)

    def __getitem__(self, key):
        assert isinstance(key, int)
        return self.cmd_list_[key]
