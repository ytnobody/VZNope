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
        my ($image, $default_name, $name) = @opts;
        $name ||= $default_name;
        $task = sub { VZNope::Container->$method(id => $ctid, image => $image, name => $name) };
    }
    eval { $task->() };
    croak $@ if $@;
}

sub build {
    my ($class, %opts) = @_;
    my $ctid = $opts{id};
    my $name = $opts{name};
    my @lines = @{$opts{script}};
    for my $line (@lines) {
        chomp($line);
        my ($method, @opts) = split(' ', $line);
        my $task = sub { $class->run($ctid, $method, @opts) };
        if ($method eq 'create' && $name) {
            $task = sub { $class->run($ctid, $method, @opts, $name) };
        }

        my $commit_mes = sprintf("RUN: '%s'", $line);      
        VZNope::MetaData->commit($ctid, $line);
    }
}

1;
