package VZNope::Images;
use strict;
use warnings;
use LWP::UserAgent;
use Carp;
use Time::Piece;
use File::Spec;
use VZNope::Constants;

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
    my $cache_dir = CACHEDIR;
    my $search_path = File::Spec->catfile($cache_dir, '*.tar.gz');
    map {
        my @stat = stat $_;
        my $name = $_;
        $name =~ s|$cache_dir/||;
        $name =~ s|.tar.gz||;
        { 
            name => $name, 
            size => sprintf('%0.01fM', $stat[7] / 1024 / 1024),
            update => Time::Piece->strptime($stat[9], '%s'),
        };
    } glob $search_path;
    
}

sub get_available {
    my ($class, $subtype) = @_;
    my $baseurl = BASEURL;
    my $url = $subtype ? $baseurl.$subtype : $baseurl;
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
    my $url = BASEURL;
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

    my $baseurl = BASEURL;
    my $cache_dir = CACHEDIR;
    my $url = $subtype ? "$baseurl$subtype/$target.tar.gz" : "$baseurl$target.tar.gz";
    my $dest_path = File::Spec->catfile($cache_dir, "$target.tar.gz");

    system('wget', $url, '-O', $dest_path);
}

1;
