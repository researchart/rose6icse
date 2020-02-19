#!/usr/bin/env python
# -*- coding: utf-8 -*-

from FsState import FsState
from TestPackage import TestPackage
import config
from Command import Sync

import sys
import signal


if __name__ == "__main__":
    config.use_config('B3')
    try:
        for cnt in range(config.get('NR_TEST_PACKAGE')):
            package = TestPackage()

            for _ in range(config.get('NR_TESTCASE_PER_PACKAGE')):
                state = FsState()

                for _ in range(config.get('NR_SEGMENT')):
                    state.rand_gen(config.get('LENGTH_PER_SEGMENT') // 2)
                    state.kmeans_gen(config.get('LENGTH_PER_SEGMENT') // 2)
                    state.take_command(Sync())

                state.expand_param()

                test_case = package.new_b3_test_case(state)
                test_case.save()

    except KeyboardInterrupt:
        print('Bye')
        sys.exit()
