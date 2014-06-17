package VZNope::Container;

use strict;
use warnings;
use Carp;
use VZNope::Constants;
use VZNope::Util qw|random_name parse_conf|;
use VZNope::MetaData;
use Sys::HostIP;
use File::Slurp;

our $DO_SYSTEM = 1;

sub create {
    my ($class, %opts) = @_;
    $opts{name} ||= random_name();

    my $id = delete $opts{id};

    unless ($opts{ip}) {
        my $hostip = Sys::HostIP->new;
        my @ip_list = ref( $hostip->ip ) eq 'ARRAY' ? @{$hostip->ip} : ($hostip->ip);
        my $network = $ip_list[0];
        $network =~ s|\.[0-9]+$|.%s|;
        $opts{ip} ||= sprintf($network, $id);
    }

    ! $class->cmd(
        'vzctl', 
        create         => $id, 
        '--ostemplate' => $opts{image}, 
        '--name'       => $opts{name},
        '--hostname'   => $opts{name},
        '--ipadd'      => $opts{ip},
    ) or die 'Could not create a container';

    VZNope::MetaData->init($id);
    VZNope::MetaData->add_action($id, 'create', @opts{qw|image name|});
    VZNope::MetaData->commit($id, 'created');
}


sub destroy {
    my ($class, $ident) = @_;

    my $ct = $class->fetch_config($ident);
    $class->cmd('vzctl', destroy => $ident);

    VZNope::MetaData->remove($ct->{VEID});
}

sub exec {
    my ($class, $ident, @cmd) = @_;

    my $ct = $class->fetch_config($ident);
    $class->cmd('vzctl', exec => $ident, @cmd);

    VZNope::MetaData->add_action($ct->{VEID}, 'exec', @cmd);
}

sub list {
    my $class = shift;
    my $privdir = CT_PRIVDIR;
    my $glob = File::Spec->catdir($privdir, '*');
    my @ct_list = glob($glob);
    map {
        my ($id) = $_ =~ m|^$privdir/([0-9]+)$|;
        my $conf = $class->_conf($id);
        my $status = $class->is_running($id);
        my $commit = VZNope::MetaData->commit_hash($id);
        { VEID => $id, STATUS => $status, COMMIT => $commit, %$conf };
    } @ct_list;
}

sub _conf {
    my ($class, $id) = @_;
    my $conf_file = File::Spec->catfile(CT_CONFDIR, $id. '.conf');
    my @lines = eval { read_file($conf_file) } or croak $@;
    parse_conf(@lines);
}

sub is_running {
    my ($class, $id) = @_;
    my $conf = $class->_conf($id);
    my $ve_root = $conf->{VE_ROOT};
    $ve_root =~ s/"//g;
    $ve_root =~ s/\$VEID/$id/g;
    scalar(glob "$ve_root/*") ? 'running' : 'stopped';
}

sub start {
    my ($class, $ident) = @_;

    my $ct = $class->fetch_config($ident);
    $class->cmd('vzctl', start => $ident);

    VZNope::MetaData->add_action($ct->{VEID}, 'start');
}

sub stop {
    my ($class, $ident) = @_;

    my $ct = $class->fetch_config($ident);
    $class->cmd('vzctl', stop => $ident);

    VZNope::MetaData->add_action($ct->{VEID}, 'stop');
}

sub fetch_config {
    my ($class, $ident) = @_;

    my @ct_list = $class->list;

    my ($ct_target) = grep {$_->{NAME} eq $ident} @ct_list;
    ($ct_target) = grep {$_->{VEID} eq $ident} @ct_list unless $ct_target;

    $ct_target;
}

sub cmd {
    my $class = shift;
    $DO_SYSTEM ? system(@_) : `@_`;
}

1;
