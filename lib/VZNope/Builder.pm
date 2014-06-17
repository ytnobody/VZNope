package VZNope::Builder;

use strict;
use warnings;
use Carp;
use VZNope::Container;

sub run {
    my ($class, $ctid, $method, @opts) = @_;
    printf '[CT:%s] RUN: %s %s', $ctid, $method, join(' ', @opts);
    eval { VZNope::Container->$method($id, @opts) };
    croak $@ if $@;
}

sub build {
    my ($class, $ctid, @lines) = @_;
    for my $line (@lines) {
        chomp($line);

        my ($method, @opts) = split(' ', $line);

        $method eq 'create' ? 
            $class->run($ctid, $method, id => $ctid, @opts) :
            $class->run($ctid, $method, @opts)
        ;

        my $commit_mes = sprintf("RUN: '%s'", $line);      
        VZNope::Container->git($ctid, 'commit', $line)
    }
}

1;
