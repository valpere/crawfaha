package CrawFaHa::Config;

use strict;
use warnings 'all';
use v5.38;

#*******************************************************************************
use FindBin qw($Bin);
use Exporter qw(import);

use English qw(-no_match_vars);
use Data::Dumper;

use Getopt::Long;
use JSON;

#*******************************************************************************
our $APPLICATION_NAME = 'crawfaha';
our $VERSION          = '0.010';

our @EXPORT_OK = qw(
  app_configuration
);

my $configuration;

my @default_config_pathts = (
    "$Bin/$APPLICATION_NAME.json",
    "$ENV{HOME}/.$APPLICATION_NAME.json",
    "$ENV{HOME}/.$APPLICATION_NAME/config.json",
    "$ENV{HOME}/.config/$APPLICATION_NAME/config.json",
    "/etc/$APPLICATION_NAME/config.json",
);

#*******************************************************************************
sub app_configuration() {

    my $help  = 0;    # handled locally
    my $ident = 0;    # handled locally

    if ($configuration) {
        return $configuration;
    }

    $configuration = {
        config    => '',
        words     => [],
        ident     => 0,
        help      => 0,
        verbose   => 0,
        debug     => 0,
        api_token => '',
    };

    if (@ARGV) {
        GetOptions(
            "config|c=s"     => \$configuration->{config},
            "api_token|at=s" => '',
            "words|w=s@"     => $configuration->{words},
            'ident'          => \$ident,
            'help|h|?'       => \$help,
            'verbose',
            'debug',
        ) or app_usage(2);
    }

    if (!$configuration->{config}) {
        for my $path (@default_config_pathts) {
            if (-r $path) {
                $configuration->{config} = $path;
                last;
            }
        }
    }

    if ($configuration->{config}) {
        my $fh = IO::File->new($configuration->{config}, 'r');
        if ($fh) {
            local $INPUT_RECORD_SEPARATOR;
            my $data = <$fh>;
            $fh->close();
            my $json = JSON->new()->relaxed(1);
            say("Is XS: " . ($json->is_xs() ? 'yes' : 'no'));
            my $cfg = $json->decode($data);
            for my $key (keys %{$cfg}) {
                $configuration->{$key} = $cfg->{$key};
            }
        }
        else {
            die("Cannot open file '$configuration->{config}': " . $OS_ERROR . "\n");
        }

    }

    app_usage(0) if ($help);
    app_ident()  if ($ident);

    return $configuration;
} ## end sub app_configuration

#*******************************************************************************
sub app_ident() {
    say("This is $APPLICATION_NAME [$VERSION]");
}

#*******************************************************************************
sub app_usage ($exit = undef) {

    if ($exit) {
        select \*STDERR;
        say("Error in command line arguments");
    }

    app_ident();

    print <<EndOfUsage;
Usage: $0 [options] [file ...]
    ### ADD OPTIONS HERE ###
    --config=CFG        load options from config file
    --help              this message
    --ident             show identification
    --verbose           verbose information
EndOfUsage

    exit($exit) if (defined($exit));
} ## end sub app_usage

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
