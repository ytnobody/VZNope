package VZNope::Container;

use strict;
use warnings;
use VZNope::Util qw|random_name|;

sub create {
    my ($class, %opts) = @_;
    $opts{name} ||= random_name();
    system(
        'vzctl', 
        create         => $opts{id}, 
        '--ostemplate' => $opts{image}, 
        '--name'       => $opts{name},
        '--hostname'   => $opts{name},
        '--ipadd'      => sprintf('192.168.230.%s', $opts{id}),
    );
}

1;
