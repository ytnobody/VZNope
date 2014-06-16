package VZNope::Container;

use strict;
use warnings;
use VZNope::Constants;
use VZNope::Util qw|random_name|;
use Sys::HostIP;
use Guard;
use Cwd;

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

1;
