import M4
import random


class NameSpace:
    def __init__(self):
        super().__init__()
        self.foo_id_ = 0
        self.seq_id_ = 0

    def unique_name(self):
        self.foo_id_ += 1
        prefix = M4.rand_str(random.randint(1, 50))
        return f'{prefix}foo_{self.foo_id_}'

    def sequence_name(self):
        self.seq_id_ += 1
        return f'seq_{self.seq_id_}'

    def __deepcopy__(self, memo):
        ns = NameSpace()
        ns.foo_id_ = self.foo_id_
        ns.seq_id_ = self.seq_id_
        return ns
