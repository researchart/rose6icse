#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from FsState import FsState
from TestPackage import TestPackage
from Qemu import Qemu
from Command import *
import config
import M4
import sys

from optparse import OptionParser


def check_options(options):
    if options.fs not in ('ext4', 'btrfs', 'f2fs', 'reiserfs',
                          'jfs', 'gfs2', 'ocfs2'):
        print(f'Unknown file system `{options.fs}`')
        sys.exit(1)
    if options.qemu and not options.test:
        print('Running qemu should enable --test')
        sys.exit(1)


def generate_test_case(package, options):
    state = FsState()
    #
    # we use kmeans generation and random generation alternately.
    #
    for _ in range(config.get('NR_SEGMENT')):
        state.rand_gen(config.get('LENGTH_PER_SEGMENT') // 2)
        state.kmeans_gen(config.get('LENGTH_PER_SEGMENT') // 2)

    #
    # Filling papameters
    #
    state.expand_param()

    test_case = package.new_test_case(state)

    test_case.save()
    M4.print_red(f'Test Case: {test_case.path_}')

    return test_case


def generate_concat_test_case(package, options):
    test_case_list = []

    for _ in range(config.get('NR_CONCAT')):
        state = FsState()

        for _ in range(config.get('NR_SEGMENT')):
            state.rand_gen(config.get('LENGTH_PER_SEGMENT') // 2)
            state.kmeans_gen(config.get('LENGTH_PER_SEGMENT') // 2)

        state.expand_param()

        test_case_list.append(package.new_multi_test_case(state))

    #
    # Merge all test cases into the first one
    #
    main_test_case = test_case_list[0]
    for i in range(1, config.get('NR_CONCAT')):
        main_test_case.concat_test_case(test_case_list[i])

    main_test_case.save()
    M4.print_red(f'Test Case: {main_test_case.path_}')

    return main_test_case


def main(options):
    '''
    There some implementation optimizations based on the algorithm presented in the paper:
    Algotirhm:
        while not terminate():
            s, w <- prio_pick(Q)

            fill papameter to w and execute w

            if length(w) > MAX:
                drop s, w

            s', w' <- generate_new_from(s)

    First, we set a pre-defined max value as
      the total number of workloads (i.e. testcases),
      and we group workloads into test packages.
      For each package, we create a new disk to manipulate.
    Second, the prio_pick procedure favours the longest workload,
      the queue Q is not necessary.
    Third, since checking each workload w incurs high overhead,
      we checking workloads in a batch.
      I.e., for workload w is <call1, call2> and its following workload w'
      is <call1, call2, call3>,
      there is not need to check them separately;
      when we execute w', w is also been executed.
    Fourth, kmeans incurs overhead,
      we use kmeans generation and random generation alternately.
    '''
    fs = options.fs

    for cnt in range(config.get('NR_TEST_PACKAGE')):
        package = TestPackage()

        if options.test:
            result = M4.exec(['./ctrl', 'disk', fs, f'{fs}-{cnt}'])
            M4.print_result(result)

        for _ in range(config.get('NR_TESTCASE_PER_PACKAGE')):
            test_case = generate_test_case(package, options)
            # test_case = generate_concat_test_case(package, options)

            if options.test:
                M4.process_exec([
                    './ctrl', 'run-case', fs, f'{fs}-{cnt}', test_case.path_
                ], timeout=20)
                # M4.print_result(result)
                M4.process_exec(['./ctrl', 'kill'])

        if options.test:
            result = M4.exec(['rm', '-rf', f'{fs}-{cnt}'])


if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option('--fs', default='f2fs', help='Which file system to test')
    parser.add_option('--qemu', action='store_true', default=False,
                      help='Start qemu automatically')
    parser.add_option('--test', action='store_true', default=False,
                      help='Start testing automatically')

    (options, args) = parser.parse_args()

    check_options(options)

    qemu = Qemu()
    if options.qemu:
        qemu.start()

    try:
        main(options)
    except KeyboardInterrupt:
        if options.qemu:
            qemu.stop()
        print('Bye')
        sys.exit()
