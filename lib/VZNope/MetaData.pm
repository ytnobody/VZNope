package VZNope::MetaData;

use strict;
use warnings;
use VZNope::Constants;
use File::Slurp;
use File::Spec;
use File::Copy;
use File::Basename 'dirname';
use Cwd;
use Guard;

our $DO_SYSTEM = 1;

sub add_action {
    my ($class, $id, $action, @opts) = @_;
    if ($id) {
        my $vznfile = $class->vznfile($id);
        my $row = join(' ', $action, @opts). "\n";
        write_file($vznfile, {append => 1}, $row);
    }
}

sub remove {
    my ($class, $id) = @_;
    if ($id) {
        my $metadir = $class->metadir($id);
        system('rm', '-rf', $metadir);
    }
}

sub sync_config {
    my ($class, $id) = @_;
    if ($id) {
        my $conf_file = File::Spec->catfile(CT_CONFDIR, $id. '.conf');
        my $metadir = $class->metadir($id);
        my $dest_conf = $class->conffile($id);
    
        copy($conf_file, $dest_conf);
    }
}

sub commit_hash {
    my ($class, $id) = @_;
    if ($id) {
        my $hash = $class->git_exec($id, qw|log --format=format:%h -n 1|);
        $hash =~ s/\r|\n//gr;
    }
}

sub metadir {
    my ($class, $id) = @_;
    File::Spec->catdir(CT_METADIR, $id);
}

sub vznfile {
    my ($class, $id) = @_;
    my $metadir = $class->metadir($id);
    File::Spec->catfile($metadir, 'vznfile');
}

sub conffile {
    my ($class, $id) = @_;
    my $metadir = $class->metadir($id);
    File::Spec->catfile($metadir, 'container.conf');
}

sub git {
    my ($class, $id, @opts) = @_;
    if (-d $class->metadir($id)) {
        my $pwd = getcwd;
        {
            my $guard = guard {
                chdir $pwd;
            };
    
            chdir $class->metadir($id);
            $DO_SYSTEM ? system(qw|git|, @opts) : `git @opts`;
        };
    }
}

sub git_exec {
    my ($class, $id, @opts) = @_;
    local $DO_SYSTEM = 0;
    $class->git($id, @opts);
}

sub init {
    my ($class, $id) = @_;
    if ($id) {
        my $metadir = $class->metadir($id);
        mkdir $metadir unless -d $metadir;
        $class->git($id, 'init');
    }
}

sub commit {
    my ($class, $id, $message) = @_;
    if ($class) {
        $class->sync_config($id);
        $class->git($id, 'add', '.');
        $message ? $class->git($id, 'commit', '-m', $message) : $class->git($id, 'commit');
    }
}

sub commit_logs {
    my ($class, $id) = @_;
    if ($id) {
        my @logs = $class->git_exec($id, qw[log --format='format:%h|%s']);
        reverse map {
            chomp;
            my ($hash, $message) = split(/\|/, $_, 2);
            {hash => $hash, message => $message};
        } grep {$_} @logs;
    }
}

1;
