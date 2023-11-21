project('it.lichtzeit.mizu', 'vala', 'c', version: run_command('git', 'describe', '--tags').stdout().strip())

prefix = get_option('prefix')
bindir = get_option('bindir')
datadir = get_option('datadir')

subdir('src')