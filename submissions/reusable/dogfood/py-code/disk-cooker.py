#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import M4
import random
import subprocess
import sys
from termcolor import colored


def exec(cmd_list):
    print(colored(f'[RUN]: {cmd_list}', 'green'))
    print(' '.join(cmd_list))

    result = subprocess.run(' '.join(cmd_list),
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            shell=True)
    if result.returncode == 0:
        print(result.stdout.decode('utf-8'))
        print(result.stderr.decode('utf-8'))
        return True
    else:
        print(result.stdout.decode('utf-8'))
        print(result.stderr.decode('utf-8'))
        return False


def make_raw_disk(disk_name, size):
    ''' Size in MB'''
    cmd_list = [
        'dd', 'if=/dev/zero', f'of={disk_name}.img', 'bs=1M', f'count={size}'
    ]
    exec(cmd_list)
    return ' '.join(cmd_list)


def fs_format_disk(disk_name, fs):
    cmd_list = mkfs(disk_name, fs)
    if not exec(cmd_list):
        return None
    return ' '.join(cmd_list)


minix_options = (
    (False, lambda: random.choice(['-1', '-2', '-3'])),
    ('-n', lambda: random.choice([14, 30, 60])),
    ('-i', lambda: random.choice([1024, 2048, 4096])),
)

jfs_options = (
    ('-O', lambda: random.choice([True, False])),
    ('-s', lambda: random.randint(1, 20)),
    ('-L', lambda: random.choice(['x', 'xx', 'xxx'])),
    ('-q', lambda: True),
)

xfs_options = (
    ('-b', lambda: f'size={random.randint(9, 12)}'),
    ('-m', lambda: random.choice(['crc=0,finobt=0',
                                  'crc=1,finobt=0',
                                  'crc=1,finobt=1'])),
    # ('-d', lambda: f'agcount={random.randint(6, 30)}m',),
    ('-i', lambda: random.choice(['size=256',
                                  'size=1024',
                                  'size=2048',
                                  'sparse=0',
                                  'attr=0',
                                  'projid32bit=1'])),
    ('-s', lambda: 'size=1024'),
    ('-f', lambda: True),
    ('-q', lambda: True),
)

btrfs_options = (
    ('-A', lambda: random.randint(0, 2**16)),
    ('-M', lambda: random.choice([True, False])),
    ('-n', lambda: 2 ** random.randint(12, 16)),
    ('-K', lambda: random.choice([True, False])),
    ('-O', lambda: ','.join(M4.rand_sample(['mixed-bg',
                                            'extref',
                                            'raid56',
                                            'skinny-metadata',
                                            'no-holes']))),
    ('-f', lambda: True),
    ('-q', lambda: True),
)

reiserfs_options = (
    ('-s', lambda: random.randint(0, 2 ** 10)),
    ('-o', lambda: random.randint(0, 2 ** 8)),
    ('-t', lambda: random.randint(0, 2 ** 8)),
    ('-b', lambda: 2 ** random.randint(9, 12)),
    # ('--format', lambda: random.choice(['3.5', '3.6'])),
    ('-h', lambda: random.choice(['tea', 'rupasov', 'r5'])),
    ('-f', lambda: True),
    ('-q', lambda: True),
)

f2fs_options = (
    ('-a', lambda: random.randint(0, 1)),
    # ('-m', lambda: random.randint(0, 10)),
    ('-o', lambda: random.randint(0, 20)),
    ('-t', lambda: random.randint(0, 1)),
    ('-z', lambda: random.randint(1, 10)),
    ('-S', lambda: random.choice([True, False])),
    ('-f', lambda: True),
    ('-q', lambda: True),
)

gfs2_options = (
    # File system block size, in bytes
    ('-b', lambda: 2 ** random.randint(9, 12)),
    # Size of quota change file, in megabytes
    ('-c', lambda: 2 ** random.randint(3, 7)),
    # Size of journals, in megabytes
    ('-J', lambda: 2 ** random.randint(3, 10)),
    # Number of journals
    ('-j', lambda: random.randint(1, 10)),
    # Don't try to discard unused blocks
    ('-K', lambda: random.choice([True, False])),
    # Don't ask for confirmation
    ('-O', lambda: True),
    # Name of the locking protocol
    ('-p', lambda: random.choice(['lock_nolock'])),
    # Don't print anything
    ('-q', lambda: True),
    # Size of resource groups, in megabytes
    # ('-r', lambda: 2 ** random.randint(5, 12)),
    # ('-t', lambda: 'locktable')
)

ocfs2_options = (
    ('-b', lambda: random.choice(['512', '1k', '2k', '4k'])),
    ('-C', lambda: f'{random.randint(4, 9)}K'),
    ('-F', lambda: True),
    ('-T', lambda: random.choice(['mail', 'datafiles'])),
    ('--fs-features=', lambda: 'local,' + ','.join([
        opt if random.randint(0, 10) < 5 else f'no{opt}' for opt in [
            'backup-super', 'sparse', 'unwritten',
            'inline-data', 'extended-slotmap', 'xattr']
    ])),
    ('--fs-feature-level=', lambda: random.choice(['max-compat',
                                                   'default',
                                                   'max-features']))
)


def _rand_pick_option(options):
    option_values = []

    for (opt_name, opt_gen) in options:
        val = opt_gen()
        if opt_name is False:
            option_values.append(f'{val}')
        elif '=' in opt_name:
            option_values.append(f'{opt_name}{val}')
        elif val is not False:
            #
            # val is True or other string values
            #
            if val is True:
                option_values.append(f'{opt_name}')
            else:
                option_values.append(f'{opt_name} {val}')

    return option_values


def find(f, seq):
    for item in seq:
        if f(item):
            return item


def _fix_options(fs, options):
    options_string = ''.join(options)
    if fs == 'btrfs':
        if '-M' in options_string or 'mixed-bg' in options_string:
            item = find(lambda x: x.startswith('-n'), options)
            options.remove(item)
            options.append('-n 4096')
        if '-O' in options_string:
            #
            # Fucking BUG for this option in python: -O xx
            # must be -Oxx
            #
            item = find(lambda x: x.startswith('-O'), options)
            new_item = item.replace(' ', '')
            options.remove(item)
            options.append(new_item)
    elif fs == 'ocfs2':
        pass

    return options


def mkfs(disk_name, fs):
    fs_options = {
        'btrfs':    btrfs_options,
        'minix':    minix_options,
        'xfs':      xfs_options,
        'jfs':      jfs_options,
        'f2fs':     f2fs_options,
        'reiserfs': reiserfs_options,
        'gfs2':     gfs2_options,
        'ocfs2':    ocfs2_options,
    }

    if fs not in fs_options:
        raise Exception(f'Unknown fs {fs}')
    options = _rand_pick_option(fs_options[fs])
    options = _fix_options(fs, options)

    return [f'mkfs.{fs}', *options, f'{disk_name}.img']


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: disk-cooker <fs> <disk-name>')
        sys.exit(1)

    fs = sys.argv[1]
    disk_name = sys.argv[2]
    while True:
        size = random.randint(100, 200)

        disk_cmd = make_raw_disk(disk_name, size)
        format_cmd = fs_format_disk(disk_name, fs)

        if format_cmd:
            M4.print_cyan(' && '.join([disk_cmd, format_cmd]))
            break
