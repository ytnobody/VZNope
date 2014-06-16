package VZNope::Container;

use strict;
use warnings;
use VZNope::Constants;
use VZNope::Util qw|random_name parse_conf|;
use Sys::HostIP;
use Guard;
use Cwd;
use File::Slurp;
use File::Copy;

our $VEID;

sub create {
    my ($class, %opts) = @_;
    $opts{name} ||= random_name();

    unless ($opts{ip}) {
        my $hostip = Sys::HostIP->new;
        my @ip_list = ref( $hostip->ip ) eq 'ARRAY' ? @{$hostip->ip} : ($hostip->ip);
        my $network = $ip_list[0];
        $network =~ s|\.[0-9]+$|.%s|;
        $opts{ip} ||= sprintf($network, $opts{id});
    }

    ! system(
        'vzctl', 
        create         => $opts{id}, 
        '--ostemplate' => $opts{image}, 
        '--name'       => $opts{name},
        '--hostname'   => $opts{name},
        '--ipadd'      => $opts{ip},
    ) or die 'Could not create a container';

    $class->sync_config($opts{id});
    $class->git_init($opts{id});
}

sub destroy {
    my ($class, $ident) = @_;
    system('vzctl', destroy => $ident);
}

sub list {
    my $class = shift;
    my $privdir = CT_PRIVDIR;
    my $glob = File::Spec->catdir($privdir, '*');
    my @ct_list = glob($glob);
    map {
        my ($id) = $_ =~ m|^$privdir/([0-9]+)$|;
        my $conf = $class->conf($id);
        my $status = $class->is_running($id);
        { VEID => $id, STATUS => $status, %$conf };
    } @ct_list;
}

sub conf {
    my ($class, $id) = @_;
    my $conf_file = File::Spec->catfile(CT_CONFDIR, $id. '.conf');
    my @lines = read_file($conf_file) or die $!;
    parse_conf(@lines);
}

sub is_running {
    my ($class, $id) = @_;
    my $conf = $class->conf($id);
    my $ve_root = $conf->{VE_ROOT};
    $ve_root =~ s/"//g;
    $ve_root =~ s/\$VEID/$id/g;
    scalar(glob "$ve_root/*") ? 'running' : 'stopped';
}

sub start {
    my ($class, $ident) = @_;
    system('vzctl', start => $ident);
}

sub stop {
    my ($class, $ident) = @_;
    system('vzctl', stop => $ident);
}

sub fetch_config {
    my ($class, $ident) = @_;

    my @ct_list = $class->list;

    my ($ct_target) = grep {$_->{NAME} eq $ident} @ct_list;
    ($ct_target) = grep {$_->{VEID} eq $ident} @ct_list unless $ct_target;

    $ct_target;
}

sub sync_config {
    my ($class, $ident) = @_;

    my $conf = $class->fetch_config($ident);
    my $veid = $conf->{VEID};

    my $conf_file = File::Spec->catfile(CT_CONFDIR, $veid. '.conf');
    my $dest_conf = File::Spec->catfile(CT_PRIVDIR, $veid, 'etc', $veid. '.conf');

    copy($conf_file, $dest_conf);
}

sub git_init {
    my ($class, $ident) = @_;

    my $ct = $class->fetch_config($ident);

    my $pwd = getcwd;
    {
        my $guard = guard {
            chdir $pwd;
        };

        my $ct_dir = File::Spec->catdir(CT_PRIVDIR, $ct->{VEID});
        chdir $ct_dir;
        if (system(qw|git init|)) {
            warn 'Could not create a repository for container';
            $class->destroy($ct->{VEID});
        }
        system(qw|git add .|);
        system(qw|git commit -m init|);
    };
}

sub git {
    my ($class, $ident, @opts) = @_;

    my $ct = $class->fetch_config($ident);

    my $pwd = getcwd;
    {
        my $guard = guard {
            chdir $pwd;
        };

        my $ct_dir = File::Spec->catdir(CT_PRIVDIR, $ct->{VEID});
        chdir $ct_dir;
        system(qw|git|, @opts);
    };
}

1;
