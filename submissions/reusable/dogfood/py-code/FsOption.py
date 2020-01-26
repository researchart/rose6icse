import random


btrfs_options = (
    ( "", "acl", "noacl" ),
    ( "", "autodefrag", "noautodefrag" ),
    ( "", "barrier", "nobarrier" ),
    ( "", "commit=1", "commit=10", "commit=40", "commit=100" ),
    ( "", "compress",  ),
    ( "", "compress-force", ),
    ( "", "datacow", "nodatacow" ),
    ( "", "datasum", "nodatasum" ),
    ( "", "degraded" ),
    ( "", "discard", "nodiscard" ),
    ( "", "inode_cache", "noinode_cache" ),
    ( "", "max_inline=2", "max_inline=128", "max_inline=1024" ),
    ( "", "metadata_ratio=1", "metadata_ratio=10", "metadata_ratio=100"),
    ( "", "rescan_uuid_tree" ),
    ( "", "skip_balance" ),
    ( "", "thread_pool=1", "thread_pool=2", "thread_pool=8", "thread_pool=16"),
    ( "", "treelog", "notreelog" ),
    ( "", "user_subvol_rm_allowed" )
)

ext2_options = (
    ( "", "acl", "noacl" ),
    ( "", "bsddf", "minixdf" ),
    ( "", "nocheck" ),
    ( "", "grpquota", "noquota", "quota", "usrquota" ),
    ( "", "oldalloc", "orlov" ),
)

ext4_options = (
    ( "", "acl", "noacl" ),
    ( "", "data=journal", "data=ordered", "data=writeback" ),
    ( "", "commit=1", "commit=5", "commit=10" ),
    ( "", "orlov", "oldalloc" ),
    ( "", "user_xattr", "nouser_xattr" ),
    ( "", "bsddf", "minixdf" ),
    ( "", "quota", "noquota" ),
    ( "", "jqfmt=vfsold", "jqfmt=vfsv0", "jqfmt=vfsv1" ),
    ( "", "journal_checksum", "nojournal_checksum" ),
    ( "", "journal_async_commit" ),
    ( "", "barrier=0", "barrier=1", "barrier", "nobarrier" ),
    ( "", "inode_readahead_blks=2", "inode_readahead_blks=8",
          "inode_readahead_blks=1024" ),
    ( "", "delalloc", "nodelalloc" ),
    ( "", "max_batch_time=0", "max_batch_time=100",
          "max_batch_time=1000", "max_batch_time=10000"),
    ( "", "min_batch_time=0", "min_batch_time=100",
          "min_batch_time=1000", "min_batch_time=10000"),
    ( "", "journal_ioprio=0", "journal_ioprio=1", "journal_ioprio=2",
          "journal_ioprio=3", "journal_ioprio=4", "journal_ioprio=5",
          "journal_ioprio=6", "journal_ioprio=7"),
    ( "", "auto_da_alloc", "noauto_da_alloc" ),
    ( "", "noinit_itable"),
    ( "", "init_itable=0", "init_itable=1", "init_itable=4", "init_itable=128"),
    ( "", "discard", "nodiscard"),
    ( "", "block_validity", "noblock_validity" ),
    ( "", "dioread_lock", "nodioread_lock" ),
    ( "", "nombcache" ),
    ( "", "prjquota" )
)

xfs_options = (
    ( "", "allocsize=4096", "allocsize=16384" ),
    ( "", "attr2", "attr2" ),
    ( "", "discard", "nodiscard" ),
    ( "", "grpid", "bsdgroups", "nogrpid", "sysvgroups" ),
    ( "", "filestreams" ),
    ( "", "ikeep", "noikeep" ),
    ( "", "inode32", "inode64" ),
    ( "", "largeio", "nolargeio" ),
    ( "", "logbufs=2", "logbufs=3", "logbufs=4",
          "logbufs=5", "logbufs=6", "logbufs=7"),
    ( "", "noalign" ),
    # ( "", "norecovery" ),
    ( "", "nouuid" ),
    ( "", "noquota" ),
    ( "", "uquota", "usrquota", "quota", "uqnoenforce", "qnoenforce" ),
    ( "", "pquota", "prjquota", "pqnoenforce" ),
    ( "", "swalloc" ),
    ( "", "wsync" ),
)

jfs_options = (
    # ( "", "nointegrity" ),
    ( "", "noquota", "quota", "usrquota", "grpquota" ),
)

reiserfs_options = (
    ( "", "acl" ),
    ( "", "conv" ),
    ( "", "nolog" ),
    ( "", "notail" ),
    ( "", "replayonly" ),
    ( "", "user_xattr" ),
    ( "", "block-allocator=hashed_relocation",
          "block-allocator=no_unhashed_relocation",
          "block-allocator=noborder",
          "block-allocator=border" ),
);

f2fs_options (
    ( "", "background_gc=on", "background_gc=off", "background_gc=sync" ),
    ( "", "disable_roll_forward" ),
    ( "", "norecovery" ),
    ( "", "discard", "nodiscard" ),
    ( "", "no_heap" ),
    ( "", "nouser_xattr" ),
    ( "", "noacl" ),
    ( "", "active_logs=2", "active_logs=4", "active_logs=6" ),
    ( "", "disable_ext_identify" ),
    ( "", "inline_xattr" ),
    ( "", "noinline_xattr" ),
    ( "", "inline_xattr_size=1", "inline_xattr_size=2",
          "inline_xattr_size=8", "inline_xattr_size=16" ),
    ( "", "inline_data" ),
    ( "", "inline_dentry" ),
    ( "", "noinline_dentry" ),
    ( "", "flush_merge" ),
    ( "", "nobarrier" ),
    ( "", "fastboot" ),
    ( "", "extent_cache" ),
    ( "", "noextent_cache" ),
    ( "", "noinline_data" ),
    ( "", "data_flush" ),
    ( "", "mode=adaptive", "mode=lfs" ),
    ( "", "io_bits=3", "io_bits=7" ),
    ( "", "usrquota" ),
    ( "", "grpquota" ),
    ( "", "prjquota" ),
    # ( "", "offusrjquota" ),
    # ( "", "offgrpjquota" ),
    # ( "", "offprjjquota" ),
    ( "", "quota" ),
    ( "", "noquota" ),
    # ( "", "whint_mode=off", "whint_mode=user-based", "whint-mode=fs-based" ),
    ( "", "alloc_mode=reuse" ),
    ( "", "fsync_mode=posix", "fsync_mode=strict", "fsync_mode=nobarrier" ),
    ( "", "test_dummy_encryption" ),
    ( "", "checkpoint=disable", "checkpoint=enable"),
)


def _rand_pick_option(options):
    option_values = [random.choice(opt) for opt in options]
    #
    # Filter out empty option values
    #
    option_values = list(filter(lambda v: v, option_values))
    if not option_values:
        return ''
    else:
        return ','.join(option_values)


def pick_fs_option(fs):
    if fs == "btrfs":
        return _rand_pick_option(btrfs_options)
    elif fs == "ext2":
        return _rand_pick_option(ext2_options)
    elif fs == "ext4":
        return _rand_pick_option(ext4_options)
    elif fs == "xfs":
        return _rand_pick_option(xfs_options)
    elif fs == "jfs":
        return _rand_pick_option(jfs_options)
    elif fs == "reiserfs":
        return _rand_pick_option(reiserfs_options)
    elif fs == "f2fs":
        return _rand_pick_option(f2fs_options)
    else:
        raise Exception(f'Unknown fs {fs}')
