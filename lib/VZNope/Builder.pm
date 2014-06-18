package VZNope::Builder;

use strict;
use warnings;
use Carp;
use VZNope::Container;
use VZNope::MetaData;

sub run {
    my ($class, $ctid, $method, @opts) = @_;
    printf "[CT:%s] RUN: %s %s\n", $ctid, $method, join(' ', @opts);
    my $task = sub { VZNope::Container->$method($ctid, @opts) };
    if ($method eq 'create') {
        my ($image, $name) = @opts;
        $task = sub { VZNope::Container->$method(id => $ctid, image => $image, name => $name) };
    }
    if ( $task->() ) {
        croak 'Task FAIL!';
    }
}

sub build {
    my ($class, %opts) = @_;
    my $ctid = $opts{id};
    my $name = $opts{name};
    my @lines = @{$opts{script}};

    my @logs = VZNope::MetaData->commit_logs($ctid);

    for my $i (0 .. $#lines) {
        my $line = $lines[$i];
        chomp($line);

        my $pair_log = $logs[$i];
        if ($pair_log) {
            if ($pair_log->{message} eq 'created' && $line =~ /^create /) {
                printf "SKIP: %s\nalready commited (%s)\n\n", $line, $pair_log->{hash};
                next;
            }
            elsif ($pair_log->{message} eq $line) {
                printf "SKIP: %s\nalready commited (%s)\n\n", $line, $pair_log->{hash};
                next;
            }
        }

        my ($method, @opts) = split(' ', $line);
        my $task = sub { $class->run($ctid, $method, @opts) };
        if ($method eq 'create' && $name) {
            my ($image, $default_name) = @opts;
            $task = sub { $class->run($ctid, $method, $image, $name) };
        }
        $task->();
        my $commit_mes = sprintf("RUN: '%s'", $line);      
        VZNope::MetaData->commit($ctid, $line);
    }
}

1;
