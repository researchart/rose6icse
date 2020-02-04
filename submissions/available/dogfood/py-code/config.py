from Command import *
import M4

class DefaultConfig:
    data_ = {
        'NR_SEGMENT'             : 10,
        'LENGTH_PER_SEGMENT'     : 100,
        'KMEANS_CLUSTER'         : 3,
        'NR_TEST_PACKAGE'        : 1,
        'NR_TESTCASE_PER_PACKAGE': 500,
        'TREE_MAX_SIZE'          : 100000,
        'OUTPUT_DIR'             : '../workspace/C-output',
        'NR_CONCAT'              : 5,
    }

    command_prob_ = {
        Command.MKDIR       : 100,
        Command.CREATE      : 100,
        Command.SYMLINK     : 100,
        Command.HARDLINK    : 100,
        Command.REMOVE      : 7,
        Command.OPEN        : 100,
        Command.CLOSE       : 100,
        Command.READ        : 100,
        Command.WRITE       : 100,
        Command.RENAME      : 100,
        Command.SYNC        : 10,
        Command.FSYNC       : 20,
        Command.XSYNC       : 0,
        Command.ENLARGE     : 3,
        Command.FALLOCATE   : 0,
        Command.REDUCE      : 3,
        Command.WRITE_XATTR : 0,
        Command.READ_XATTR  : 0,
        Command.REMOUNT_ROOT: 3,
        Command.STATFS      : 3,
        Command.OPEN_TMPFILE: 0,
        Command.DEEPEN      : 3,
        Command.MKNOD       : 7,
        Command.CHROOT      : 2,
    }


class B3Config:
    data_ = {
        'NR_SEGMENT'             : 2,
        'LENGTH_PER_SEGMENT'     : 20,
        'KMEANS_CLUSTER'         : 3,
        'NR_TEST_PACKAGE'        : 1,
        'NR_TESTCASE_PER_PACKAGE': 100000,
        'TREE_MAX_SIZE'          : 100000,
        'OUTPUT_DIR'             : './output',
    }

    command_prob_ = {
        Command.MKDIR       : 100,
        Command.CREATE      : 100,
        Command.SYMLINK     : 0,
        Command.HARDLINK    : 100,
        Command.REMOVE      : 60,
        Command.OPEN        : 100,
        Command.CLOSE       : 100,
        Command.READ        : 100,
        Command.WRITE       : 60,
        Command.RENAME      : 100,
        Command.SYNC        : 80,
        Command.FSYNC       : 80,
        Command.XSYNC       : 80,
        Command.ENLARGE     : 60,
        Command.FALLOCATE   : 60,
        Command.REDUCE      : 60,
        Command.WRITE_XATTR : 0,
        Command.READ_XATTR  : 0,
        Command.REMOUNT_ROOT: 0,
        Command.STATFS      : 0,
        Command.OPEN_TMPFILE: 0,
        Command.DEEPEN      : 0,
        Command.MKNOD       : 0,
        Command.CHROOT      : 0,
    }

config_ = DefaultConfig()

def use_config(which):
    global config_
    if which == 'B3':
        config_ = B3Config()

def get(key):
    if key not in config_.data_:
        M4.print_red(f'Error config keyword: {key}')
        return None

    return config_.data_.get(key)

def get_command_prob(cmd_type):
    if cmd_type not in config_.command_prob_:
        raise Exception('Get command prob error')
    return config_.command_prob_[cmd_type]
