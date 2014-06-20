package VZNope;
use 5.012;
use strict;
use warnings;
use VZNope::Constants;
use VZNope::Images;
use VZNope::Container;
use VZNope::MetaData;
use VZNope::Builder;

our $VERSION = "0.01";

system('mkdir', WORKDIR, '-pv') unless -d WORKDIR;
system('mkdir', CT_METADIR, '-pv') unless -d CT_METADIR;

sub images {
    my ($class) = @_;
    VZNope::Images->get_list;
}

sub images_available {
    my ($class, $subtype) = @_;
    VZNope::Images->get_available($subtype);
}

sub image_subtypes {
    my ($class, $subtype) = @_;
    VZNope::Images->get_subtypes;
}

sub get_image {
    my ($class, $dist, $version, %opts) = @_;
    VZNope::Images->fetch($dist, $version, %opts);
}

sub create_container {
    my ($class, %opts) = @_;
    VZNope::Container->create(%opts);
}

sub destroy_container {
    my ($class, $ident) = @_;
    VZNope::Container->destroy($ident);
}

sub containers {
    my $class = shift;
    VZNope::Container->list;
}

sub start_container {
    my ($class, $ident) = @_;
    VZNope::Container->start($ident);
}

sub stop_container {
    my ($class, $ident) = @_;
    VZNope::Container->stop($ident);
}

sub commit {
    my ($class, $ident, @opts) = @_;
    my $ct = VZNope::Container->fetch_config($ident);
    VZNope::MetaData->commit($ct->{VEID}, @opts);
}

sub commit_log {
    my ($class, $ident) = @_;
    my $ct = VZNope::Container->fetch_config($ident);
    VZNope::MetaData->git($ct->{VEID}, 'log');
}

sub exec {
    my ($class, $ident, @cmd) = @_;
    VZNope::Container->exec($ident, @cmd);
}

sub build {
    my ($class, %opts) = @_;
    VZNope::Builder->build(%opts);
}

sub set {
    my ($class, $ident, @opts) = @_;
    VZNope::Container->set($ident, @opts);
}

1;
__END__

=encoding utf-8

=head1 NAME

VZNope - OpenVZ wrapper toolkit that aims to realize "Immutable Container"

=head1 SYNOPSIS

    use VZNope;

=head1 DESCRIPTION

NOTICE!!!!

THIS PRODUCT IS STILL ALPHA QUALITY. PLEASE USE YOUR OWN RISK.

VZNope.pm is a wrapper tool for OpenVZ. PLEASE DO NOT USE THIS MODULE DIRECTLY.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

