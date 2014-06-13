package VZNope;
use 5.008005;
use strict;
use warnings;
use VZNope::Images;

our $VERSION = "0.01";

sub images {
    my ($class, $subtype) = @_;
    VZNope::Images->get_list($subtype);
}

sub image_subtypes {
    my ($class, $subtype) = @_;
    VZNope::Images->get_subtypes;
}

sub get_image {
    my ($class, $name, $subtype) = @_;
    VZNope::Images->fetch($name, $subtype);
}


1;
__END__

=encoding utf-8

=head1 NAME

VZNope - It's new $module

=head1 SYNOPSIS

    use VZNope;

=head1 DESCRIPTION

VZNope is ...

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

