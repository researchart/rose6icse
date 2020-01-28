# -*-cperl-*-
#
# Copyright 2016-2017 The MathWorks, Inc.
use strict;
use File::Glob 'bsd_glob';
if (@ARGV != 1) { die "usage: $0 GLOB_PATTERN\n";}
(my $pat = $ARGV[0]) =~ s/\\/\//g;
my @files = bsd_glob($pat);
my $result = 'matches={';
for (my $i=0; $i<@files; $i++) {
    (my $model = $files[$i]) =~ s/^.*[\/\\]([^\.]+)\..+$/$1/;
    $result .= "'$model'" . ($i+1 < @files? ",...\n": "");
}
print $result."};";
exit(0);
