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
        my $dist = shift(@opts);
        my %cmd_opts = ( @opts );
        for my $key ( keys %cmd_opts ) {
            my $newkey = $key =~ s/^\-\-//r;
            $cmd_opts{$newkey} = delete $cmd_opts{$key};
        }
        $task = sub { VZNope::Container->$method(id => $ctid, dist => $dist, %cmd_opts) };
    }
    if ( $task->() ) {
        croak 'Task FAIL!';
    }
}

sub build {
    my ($class, %input_opts) = @_;

    my $ctid = delete $input_opts{id};
    my @lines = grep {$_ !~ /^#/} grep {$_ !~ /^$/} @{delete $input_opts{script}};

    my @logs = VZNope::MetaData->commit_logs($ctid);

    for my $i (0 .. $#lines) {
        my $line = $lines[$i];
        chomp($line);
        next unless $line;

        my $pair_log = $logs[$i];
        if ($pair_log) {
            if ($pair_log->{message} eq 'created' && $line =~ /^create /) {
                printf "SKIP: %s\nalready committed (%s)\n\n", $line, $pair_log->{hash};
                next;
            }
            elsif ($pair_log->{message} eq $line) {
                printf "SKIP: %s\nalready committed (%s)\n\n", $line, $pair_log->{hash};
                next;
            }
        }

        my ($method, @opts) = split(' ', $line);
        my $task = sub { $class->run($ctid, $method, @opts) };

        if ($method eq 'create') {
            my $cmd_opts = [@opts, ( %input_opts )];
            $task = sub { $class->run($ctid, $method, @$cmd_opts) };
        }
        $task->();
        my $commit_mes = sprintf("RUN: '%s'", $line);      
        VZNope::MetaData->commit($ctid, $line);
    }
}

1;
