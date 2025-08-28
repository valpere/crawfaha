#!/usr/bin/env perl
package crawfaha;

use strict;
use warnings 'all';
use v5.38;

#*******************************************************************************
use FindBin qw($Bin);
use lib("$Bin/lib");
use File::Basename qw(basename);

use CrawFaHa;

#*******************************************************************************

CrawFaHa->run();

#*******************************************************************************
__END__
