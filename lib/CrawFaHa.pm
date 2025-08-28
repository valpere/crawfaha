package CrawFaHa;

use strict;
use warnings 'all';
use v5.38;

#*******************************************************************************
use FindBin qw($Bin);
use lib("../$Bin/lib");

use English qw(-no_match_vars);
use Data::Dumper;

use CrawFaHa::Config qw(app_configuration);

#*******************************************************************************
sub run {
    my ($self) = @_;

    local $Data::Dumper::Indent   = 2;
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Deepcopy = 1;

    my $config = app_configuration();

    say(Dumper($config));

    return 1;
}

#*******************************************************************************
1;
__END__
#*******************************************************************************
    
=pod
        
=head1 NAME

=head1 DESCRIPTION

=head1 AUTHOR

Valentyn Solomko C<< <valentyn.solomko@gmail.com> >>


=head1 COPYRIGHT

Copyright (c) 2025 Valentyn Solomko.
