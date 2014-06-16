package VZNope::Container;

use strict;
use warnings;
use VZNope::Constants;
use VZNope::Util qw|random_name parse_conf|;
use Sys::HostIP;
use Guard;
use Cwd;
use File::Slurp;

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

    my $pwd = getcwd;
    {
        my $guard = guard {
            chdir $pwd;
        };

        my $ct_dir = File::Spec->catdir(CACHEDIR, $opts{id});
        chdir $ct_dir;
        if (system(qw|git init|)) {
            warn 'Could not create a repository for container';
            $class->destroy($opts{name});
        }
        system(qw|git add .|);
        system(qw|git commit -m init|);
    };
}

sub destroy {
    my ($class, $ident) = @_;
    system('vzctl', destroy => $ident);
}

sub list {
    my $class = shift;
    my $privdir = PRIVDIR;
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

1;
