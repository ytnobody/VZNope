package VZNope::Images;
use strict;
use warnings;
use LWP::UserAgent;
use Carp;
use Time::Piece;
use File::Spec;

our $BASEURL  = $ENV{VZNOPE_IMAGES_URL} || 'http://download.openvz.org/template/precreated/';
our $CACHEDIR = $ENV{VZNOPE_IMAGE_CACHE_DIR} || File::Spec->catdir(qw|/ var lib vz template cache|);

my $agent = LWP::UserAgent->new(agent => __PACKAGE__);

sub req {
    my ($class, $url) = @_;
    my $res = $agent->get($url);
    unless ($res->is_success) {
        croak($res->status_line);
    }
    $res;
}

sub get_list {
    my $class = shift;
    my $search_path = File::Spec->catfile($CACHEDIR, '*.tar.gz');
    map {
        my @stat = stat $_;
        my $name = $_;
        $name =~ s|$CACHEDIR/||;
        { name => $name, update => Time::Piece->strptime($stat[9], '%s') };
    } glob $search_path;
    
}

sub get_available {
    my ($class, $subtype) = @_;
    my $url = $subtype ? $BASEURL.$subtype : $BASEURL;
    my $res = $class->req($url);
    my @matched = 
        $res->content =~ 
        m|<td><a href="(.+?).tar.gz">.+?</a></td><td align="right">(.+?)  </td><td align="right">(.+?)</td>|g;

    my @images;
    while ( my ($name, $modified, $size) = splice @matched, 0, 3 ) {
        push @images, {name => $name, modified => Time::Piece->strptime($modified, '%d-%b-%Y %H:%M'), size => $size};
    }

    @images;
}

sub get_subtypes {
    my $class = shift;
    my $url = $BASEURL;
    my $res = $class->req($url);

    my @matched = 
        $res->content =~ 
        m|<td><a href="(.+?)/">.+?</a></td><td align="right">(.+?)  </td>|g;

    my @subtypes;
    while ( my ($name, $modified) = splice @matched, 0, 2 ) {
        push @subtypes, {name => $name, modified => Time::Piece->strptime($modified, '%d-%b-%Y %H:%M')};
    }

    @subtypes;
}

sub fetch {
    my ($class, $target, $subtype) = @_;

    my $url = $subtype ? "$BASEURL$subtype/$target.tar.gz" : "$BASEURL$target.tar.gz";
    my $dest_path = File::Spec->catfile($CACHEDIR, "$target.tar.gz");

    system('wget', $url, '-O', $dest_path);
}

1;
