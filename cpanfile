requires 'perl', '5.008001';
requires 'LWP::UserAgent';
requires 'Carp';
requires 'Time::Piece';
requires 'List::Util';
requires 'File::Spec';
requires 'File::Basename';
requires 'Sys::HostIP';
requires 'Guard';
requires 'File::Slurp';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

