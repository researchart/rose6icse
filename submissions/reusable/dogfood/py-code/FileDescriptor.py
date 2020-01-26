import M4


class FileDescriptor:
    id_count_ = 0

    def __init__(self, path, fd_id=None):
        self.path_ = path

        if fd_id:
            self.fd_id_ = fd_id
        else:
            FileDescriptor.id_count_ += 1
            self.fd_id_ = FileDescriptor.id_count_

    def __str__(self):
        return f'fd_{self.fd_id_}'

    def __deep_copy__(self, memo):
        fd = FileDescriptor(self.path_, self.fd_id_)
        return fd

    def __hash__(self):
        h1 = M4.hash_int(self.fd_id_)
        h2 = M4.hash_str(self.path_)
        return M4.hash_concat(h1, h2)

    def __eq__(self, other):
        if isinstance(other, FileDescriptor):
            if self.fd_id_ == other.fd_id_:
                assert self.path_ == other.path_
                return True
        return False
