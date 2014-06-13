package VZNope::Images;
use strict;
use warnings;
use LWP::UserAgent;
use Carp;
use Time::Piece;

our $BASEURL = $ENV{VZNOPE_IMAGES_URL} || 'http://download.openvz.org/template/precreated/';

my $agent = LWP::UserAgent->new(agent => __PACKAGE__);

sub get_list {
    my ($class, $subtype) = @_;
    my $url = $subtype ? $BASEURL.$subtype : $BASEURL;
    my $res = $agent->get($url);
    unless ($res->is_success) {
        croak($res->status_line);
    }
    my @matched = 
        $res->content =~ 
        m|<td><a href="(.+?).tar.gz">.+?</a></td><td align="right">(.+?)  </td><td align="right">(.+?)</td>|g;

    my @images;
    while ( my ($name, $modified, $size) = splice @matched, 0, 3 ) {
        push @images, {name => $name, modified => Time::Piece->strptime($modified, '%d-%b-%Y %H:%M'), size => $size};
    }

    @images;
}

1;
