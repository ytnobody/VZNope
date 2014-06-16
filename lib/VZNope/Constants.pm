package VZNope::Constants;
use strict;
use warnings;
use parent qw/Exporter/;

use constant BASEURL  => $ENV{VZNOPE_IMAGES_URL} || 'http://download.openvz.org/template/precreated/';
use constant VZDIR    => $ENV{VZDIR} || File::Spec->catdir(qw|/ var lib vz|);
use constant CACHEDIR => $ENV{VZNOPE_IMAGE_CACHE_DIR} || File::Spec->catdir(VZDIR, qw|template cache|);
use constant PRIVDIR  => $ENV{VZNOPE_CT_PRIVDIR} || File::Spec->catdir(VZDIR, qw|private|);
use constant CT_CONFDIR => $ENV{VZNOPE_CT_CONFDIR} || File::Spec->catdir(qw|/ etc vz conf|);

our @EXPORT = qw/BASEURL VZDIR CACHEDIR PRIVDIR CT_CONFDIR/;

1;
