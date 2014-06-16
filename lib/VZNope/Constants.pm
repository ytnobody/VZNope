package VZNope::Constants;
use strict;
use warnings;
use parent qw/Exporter/;

use constant BASEURL  => $ENV{VZNOPE_IMAGES_URL} || 'http://download.openvz.org/template/precreated/';
use constant CACHEDIR => $ENV{VZNOPE_IMAGE_CACHE_DIR} || File::Spec->catdir(qw|/ var lib vz template cache|);

our @EXPORT = qw/BASEURL CACHEDIR/;

1;
