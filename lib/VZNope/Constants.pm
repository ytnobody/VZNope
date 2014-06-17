package VZNope::Constants;
use strict;
use warnings;
use parent qw/Exporter/;
use File::Spec;

use constant BASEURL  => $ENV{VZNOPE_IMAGES_URL} || 'http://download.openvz.org/template/precreated/';
use constant VZDIR    => $ENV{VZDIR} || File::Spec->catdir(qw|/ var lib vz|);
use constant CACHEDIR => $ENV{VZNOPE_IMAGE_CACHE_DIR} || File::Spec->catdir(VZDIR, qw|template cache|);
use constant WORKDIR  => $ENV{VZNOPE_WORKDIR} || File::Spec->catdir($ENV{HOME}, '.vznope');
use constant CT_PRIVDIR => $ENV{VZNOPE_CT_PRIVDIR} || File::Spec->catdir(VZDIR, qw|private|);
use constant CT_CONFDIR => $ENV{VZNOPE_CT_CONFDIR} || File::Spec->catdir(qw|/ etc vz conf|);
use constant CT_METADIR => $ENV{VZNOPE_CT_METADIR} || File::Spec->catdir(WORKDIR, 'meta');

our @EXPORT = qw/BASEURL VZDIR CACHEDIR WORKDIR CT_PRIVDIR CT_CONFDIR CT_METADIR/;

1;
