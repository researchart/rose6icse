from CodeWriter import CodeWriter
from CodeParser import CodeParser
from Sequence import Sequence
import re


class ConcatTestCase:
    '''
    This test case can concatenate other test cases.
    In other word, it contains multiple sequences.
    '''
    def __init__(self, case_path, seq, seed):
        self.path_ = case_path
        self.seq_list_ = [seq]
        self.seed_ = seed

    def save_as(self, case_path):
        with open(case_path, 'w') as self.fd_:
            self.fd_.write('#include "executor.h"\n')

            self._save_fd()
            self._save_seq_list()

    def save(self):
        self.save_as(self.path_)

    def concat_test_case(self, another):
        assert len(another.seq_list_) == 1
        seq = another.seq_list_[0]

        seq.name_ = f'test_syscall_{len(self.seq_list_)}'

        self.seq_list_.append(seq)

    def _save_fd(self):
        self.fd_.write('int ')
        for seq in self.seq_list_:
            for fd_key in seq.all_fd_keys():
                self.fd_.write(f'{fd_key} = -1, ')
        self.fd_.write('__end_fd = -1;\n')

    def _save_seq_list(self):
        for seq in self.seq_list_:
            self.fd_.write(f'int {seq.name_}()\n')
            self.fd_.write('{\n')
            #
            # Set the rand seed for the test case
            #
            if seq.name_ == 'test_syscall':
                self.fd_.write(f'srand({self.seed_});\n')

            cw = CodeWriter()
            for cmd in seq:
                self.fd_.write(f'{cw.write_command(cmd)}; \n')

            self.fd_.write('return 0;\n}\n')

        #
        # Write two dummy functions to avoid
        # `undefined reference` compilation errors
        #
        self.fd_.write('int concurrent_syscall_1() { return 0; }\n')
        self.fd_.write('int concurrent_syscall_2() { return 0; }\n')

