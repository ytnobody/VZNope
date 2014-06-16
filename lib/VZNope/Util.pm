package VZNope::Util;

use strict;
use warnings;
use parent 'Exporter';
use List::Util 'shuffle';

our @EXPORT_OK = qw| 
    random_name
    parse_conf
|;

sub random_name {
    my @rows = <DATA>;
    join('_', @{[map {s|\n||;$_} shuffle(@rows)]}[0,1]);
}

sub parse_conf {
    my @conf_lines = grep {$_ =~ /=/} grep {$_ !~ /^#/} @_;
    my $rtn = +{ map {chomp; (split /=/, $_, 2)} @conf_lines };
    for my $key (keys %$rtn) {
        $rtn->{$key} =~ s/^"//;
        $rtn->{$key} =~ s/"$//;
    }
    $rtn;
}

__DATA__
ape
aiming
bat
beauty
cat
copper
dog
dream
eel
elder
fox
fire
giraffe
gold
hippo
human
insect
illusion
jackal
jasmine
kangaroo
king
lama
life
mouse
muse
nutria
nitro
octopus
order
python
phoenix
quick
queen
running
roud
shark
speed
tiger
thunder
ugly
unicorn
visible
voice
wheal
wing
xtream
xenic
yeti
yeoman
zombie
zero
