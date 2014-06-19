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
        my ($dist, $version, $arch) = $name =~ /^(.+)\-(.+)\-(.+)$/;
        { 
            dist => $dist,
            version => $version,
            arch => $arch,
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
        my ($dist, $version, $arch, $tag) = split /\-/, $name, 4;
        push @images, {
            dist => $dist, 
            version => $version, 
            arch => $arch, 
            tag => $tag,
            modified => Time::Piece->strptime($modified, '%d-%b-%Y %H:%M'), 
            size => $size,
        };
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
    my ($class, $dist, $version, %opts) = @_;

    my $baseurl = BASEURL;
    my $cache_dir = CACHEDIR;

    my $subtype = $opts{subtype};

    my $target = $class->available_image_name($dist, %opts);

    my $url = $subtype ? "$baseurl$subtype/$target.tar.gz" : "$baseurl$target.tar.gz";
    my $dest_path = File::Spec->catfile($cache_dir, "$target.tar.gz");

    system('wget', $url, '-O', $dest_path);
}

sub available_image_name {
    my ($class, $dist, %opts) = @_;

    my $tag = $opts{tag};
    my $arch = $opts{arch} || `uname -i` =~ s/\n//r;
    my $version = $dist =~ /\@/ ? 
        [$dist =~ /\@(.+)$/]->[0] : 
        $class->latest_available_version_of($dist, $arch, $subtype)
    ;

    join('-', grep {$_} ($dist, $version, $arch, $tag) );
}

sub image_name {
    my ($class, $dist, %opts) = @_;

    my $tag = $opts{tag};
    my $arch = $opts{arch} || `uname -i` =~ s/\n//r;
    my $version = $dist =~ /\@/ ? 
        [$dist =~ /\@(.+)$/]->[0] : 
        $class->latest_version_of($dist, $arch, $subtype)
    ;

    join('-', grep {$_} ($dist, $version, $arch, $tag) );
}

sub latest_available_version_of {
    my ($class, $dist, $arch, $subtype) = @_;
    my @images = 
        sort {$b->{version}+0 <=> $a->{version}+0}
        grep {$_->{dist} eq $dist && $_->{arch} eq $arch} 
        $class->get_available($subtype)
    ;
    my $image = shift(@images) if @images;
    $image->{version} if $image;
}

sub latest_version_of {
    my ($class, $dist, $arch, $subtype) = @_;
    my @images = 
        sort {$b->{version}+0 <=> $a->{version}+0}
        grep {$_->{dist} eq $dist && $_->{arch} eq $arch} 
        $class->get_list($subtype)
    ;
    shift(@images) if @images;
}

1;
