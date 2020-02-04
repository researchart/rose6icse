#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import re
import sys
import os
import subprocess
import multiprocessing
import M4

from Command import *
from Sequence import Sequence
from CodeParser import CodeParser
from TestCase import TestCase
from Qemu import Qemu


class Trigger:
    def __init__(self, trigger_script_path):
        self.script_path_ = trigger_script_path

    def start(self):
        def target():
            command_process = subprocess.Popen([self.script_path_])
            command_process.communicate()

        M4.print_green(f'Start trigger {self.script_path_}')

        self.trigger_thread_ = multiprocessing.Process(target=target)
        self.trigger_thread_.start()

        M4.wait_for(20, 'Running triggering script')

    def stop(self):
        if self.trigger_thread_.is_alive():
            self.trigger_thread_.terminate()


class Reducer:
    '''
    Reduce a workload into a shorter one.
    Two passes:
      - Binary reduction: find a shortest prefix of sequence
        that still manifest the bug
      - Sinble reduction: iteratively remove syscall and its dependencies
    '''
    def __init__(self, case_dir):
        self.case_dir_ = case_dir
        self.test_case_ = TestCase.from_file(M4.path_join(case_dir, 'bingo.c'))

    def single_reduce(self):
        idx = 0
        while idx < len(self.test_case_.seq_):

            M4.print_cyan(f'Reduce {idx} --{str(self.test_case_.seq_[idx])}')

            new_case = self.test_case_.filter_out_seq(idx)

            M4.print_blue('Save new C file', no_newline=True)
            new_case.save()
            M4.print_blue('... ending')

            if self._reproduce() == True:
                M4.print_green(f'Yes [{idx}]')
                #
                # idx should not change because we move the next command forward
                # to the current `idx` position.
                #
                self.test_case_ = new_case
            else:
                M4.print_red(f'No [{idx}]')
                idx += 1
        self.test_case_.save()

    def binary_reduce(self):
        left, right = 0, len(self.test_case_.seq_) - 1
        #
        # It's not that restrict for indexes.
        #
        while left + 3 < right:
            mid = left + (right - left) // 2;

            M4.print_cyan(f'Reduce {left}--{right}: {mid}')

            new_case = self.test_case_.truncate_seq(mid - 1)

            M4.print_blue('Save new C file', no_newline=True)
            new_case.save()
            M4.print_blue('... ending')

            if self._reproduce() == True:
                M4.print_green(f'Yes [{left},{right}] => [{left},{mid}]')
                right = mid
            else:
                M4.print_red(f'No [{left},{right}] => [{mid},{right}]')
                left = mid

        new_case = self.test_case_.truncate_seq(right)
        new_case.save()

    def _reproduce(self):
        #
        # Prepare qemu
        #
        self.qemu_ = Qemu()
        self.qemu_.start()
        #
        # RUN trigger.sh
        #
        trigger = Trigger(os.path.join(self.case_dir_, 'trigger.sh'))
        trigger.start()

        #
        # Check log
        #
        result = self._check_result()

        #
        # If a bug occurs, qemu will restart; we wait for it
        #
        if result is True:
            M4.wait_for(13, 'Wait for qemu restarting')

        self.qemu_.stop()
        trigger.stop()

        #
        # Wait for qemu releasing the socket
        #
        M4.wait_for(5)
        return result

    def _check_result(self):
        return self.qemu_.log_contain([r'\WBUG\W', r'\WRIP\W'])


if __name__ == "__main__":

    reducer = Reducer(sys.argv[1])
    reducer.binary_reduce()
    reducer.single_reduce()
