from CodeWriter import CodeWriter
from CodeParser import CodeParser
from Sequence import Sequence
import re


class TestCase:
    '''
    This class is used to save sequences (workloads) into C files.
    For a sequence: <call:1, ..., call:N-1, call:N>, it is wrapped in a C function:
    ```C
    int test_syscall() {
        call:1,
        call:2,
        ...
        call:N-2
    } 
    ```
    Since there are explicit def-use relations of file descriptors (opening and following uses),
    we define all file descriptors first.
    '''

    def __init__(self, case_path, seq, seed):
        self.path_ = case_path
        self.seq_ = seq
        self.seed_ = seed

    def save_as(self, case_path):
        with open(case_path, 'w') as self.fd_:
            self.fd_.write('#include "executor.h"\n')

            self._save_fd()
            self._save_seq()

    def save(self):
        self.save_as(self.path_)

    def _save_fd(self):
        '''
        This method define all available file descriptors.
        ```C
        int fd_1 = -1, fd_2 = -1, ..., __end_fd = -1;
        ```
        '''
        self.fd_.write('int ')
        for fd_key in self.seq_.all_fd_keys():
            self.fd_.write(f'{fd_key} = -1, ')
        self.fd_.write('__end_fd = -1;\n')

    def _save_seq(self):
        self.fd_.write(f'int {self.seq_.name_}()\n')
        self.fd_.write('{\n')
        #
        # Set the rand seed for the test case first
        #
        self.fd_.write(f'srand({self.seed_});\n')

        cw = CodeWriter()
        for cmd in self.seq_:
            self.fd_.write(f'{cw.write_command(cmd)}; \n')

        self.fd_.write('return 0;\n}\n')

        #
        # Write two dummy functions to avoid
        # `undefined reference` compilation errors
        #
        self.fd_.write('int concurrent_syscall_1() { return 0; }\n')
        self.fd_.write('int concurrent_syscall_2() { return 0; }\n')

    @staticmethod
    def from_file(case_path):
        '''
        Parse a C file into test case.
        '''
        seq = Sequence('test_syscall')
        seed = 0
        code_parser = CodeParser()
        with open(case_path, 'r') as fd:
            for line in fd:
                if 'do_' in line:
                    cmd = code_parser.parse_command(line.strip())
                    seq.push(cmd)
                elif 'srand' in line:
                    seed = re.findall(r'srand\((\d+)\)', line)[0]

        return TestCase(case_path, seq, seed)

    def truncate_seq(self, length):
        '''
        Truncate the sequence by the length and return a new test case.
        '''
        return TestCase(self.path_,
                        self.seq_.truncate(length),
                        self.seed_)

    def filter_out_seq(self, idx):
        '''
        Remove a syscall from the sequence specified by the index `idx`,
        and return a new test case.
        '''
        return TestCase(self.path_,
                        self.seq_.filter_out(idx),
                        self.seed_)
