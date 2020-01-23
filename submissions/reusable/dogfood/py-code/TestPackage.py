import M4
import random
import config

from FsState import FsState
from TestCase import TestCase
from B3TestCase import B3TestCase
from ConcatTestCase import ConcatTestCase


class TestPackage:
    def __init__(self):
        self.package_path_ = self._make_new_package_dir()
        self.file_id_ = 1

    def new_test_case(self, state):
        file_path = M4.path_join(self.package_path_, f'{self.file_id_}.c')
        self.file_id_ += 1

        return  TestCase(file_path,
                         state.seq_,
                         random.randint(1, 100000000))

    def new_b3_test_case(self, state):
        file_path = M4.path_join(self.package_path_, f'{self.file_id_}.cpp')
        self.file_id_ += 1

        return  B3TestCase(file_path,
                         state.seq_,
                         random.randint(1, 100000000))

    def _make_new_package_dir(self):
        dir_name = f'{M4.time_str()}-{M4.rand_str(5)}'
        dir_path = M4.path_join(config.get('OUTPUT_DIR'), dir_name)
        M4.mkdir(dir_path)
        return dir_path

    def new_concat_test_case(self, state):
        file_path = M4.path_join(self.package_path_, f'{self.file_id_}.c')
        self.file_id_ += 1

        return  ConcatTestCase(file_path,
                         state.seq_,
                         random.randint(1, 100000000))

