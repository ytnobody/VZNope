#!/bin/bash

APPROOT=$(cd $(dirname $0) ; pwd)
PERLROOT=$APPROOT/perl5/perl-5.18
BINDIR=$PERLROOT/bin
PERL=$BINDIR/perl

if [ ! -d $PERLROOT ]; then
    curl https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build | perl - 5.18.2 ./perl5/perl-5.18 &&
    curl https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm > $BINDIR/cpanm &&
    chmod +x $BINDIR/cpanm &&
    $PERL $BINDIR/cpanm Carton --notest &&
    $PERL $BINDIR/carton 
    echo . $APPROOT/vznope.bashrc >> $HOME/.bash_profile
    exec /bin/bash
fi
