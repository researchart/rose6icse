from CodeWriter import CodeWriter
from CodeParser import CodeParser
from Sequence import Sequence


class B3TestCase:
    def __init__(self, case_path, seq, seed):
        self.path_ = case_path
        self.seq_ = seq
        self.seed_ = seed

    def save_as(self, case_path):
        with open(case_path, 'w') as self.fd_:
            self.fd_.write('#include "b3-template.h"\n')
            self.fd_.write('namespace fs_testing {\n')
            self.fd_.write('namespace tests {\n')

            self._save_fd()
            self._save_seq()

            self.fd_.write('} \n')
            self.fd_.write('} \n')

    def save(self):
        self.save_as(self.path_)

    def _save_fd(self):
        self.fd_.write('int ')
        for fd_key in self.seq_.all_fd_keys():
            self.fd_.write(f'{fd_key} = -1, ')
        self.fd_.write('__end_fd = -1;\n')

    def _save_seq(self):
        self.fd_.write('int Example::run(int checkpoint) {\n')
        #
        # Set the rand seed for the test case
        #
        self.fd_.write(f'srand({self.seed_});\n')

        cw = CodeWriter()
        for cmd in self.seq_:
            self.fd_.write(f'{cw.write_command(cmd)}; \n')

        self.fd_.write('return 0;\n')
        self.fd_.write('}\n')
