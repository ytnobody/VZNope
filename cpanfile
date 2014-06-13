requires 'perl', '5.008001';
requires 'LWP::UserAgent';
requires 'Carp';
requires 'Time::Piece';
requires 'List::Util';
requires 'File::Spec';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

