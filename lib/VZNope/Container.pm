package VZNope::Container;

use strict;
use warnings;
use VZNope::Util qw|random_name|;
use Sys::HostIP;

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
    system(
        'vzctl', 
        create         => $opts{id}, 
        '--ostemplate' => $opts{image}, 
        '--name'       => $opts{name},
        '--hostname'   => $opts{name},
        '--ipadd'      => $opts{ip},
    );
}

1;
