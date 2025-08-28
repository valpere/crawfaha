package CrawFaHa::Utils;

use strict;
use warnings 'all';
use v5.38;

#*******************************************************************************
use FindBin  qw($Bin);
use Exporter qw(import);

use English qw(-no_match_vars);
use Data::Dumper;

use IO::File;
use Ref::Util qw(
    is_scalarref
);
use Clone qw(clone);

#*******************************************************************************
our @EXPORT_OK = qw(
    dump_data

    binary_load
    binary_save

    flatten
);

#*****************************************************************************
sub dump_data(@data) {

    my $data;
    if (@data < 1) {
        return '';
    }
    elsif (@data > 1) {
        $data = [@data];
    }
    else {
        $data = $data[0];
    }

    if (is_scalarref($data)) {
        $data = ${$data};
    }

    local $Data::Dumper::Deepcopy = 1;
    local $Data::Dumper::Terse    = 0;
    local $Data::Dumper::Indent   = 2;
    local $Data::Dumper::Useqq    = 0;
    local $Data::Dumper::Sortkeys = 1;

    $data = Dumper($data);
    $data =~ s/^\$VAR1\s*=\s*(.+);$/$1/s;

    return $data;
} ## end sub dump_data

#***********************************************************************
sub binary_save($file, $data) {
    my $fh = IO::File->new($file, 'w') || die("Can't create file '$file': $OS_ERROR\n");
    $fh->binmode(':bytes');
    my $res = $fh->print($data);
    $fh->close;

    return $res;
}

#***********************************************************************
sub binary_load($file) {
    local $INPUT_RECORD_SEPARATOR = undef;
    my $fh = IO::File->new($file, 'r') || die("Can't open file '$file': $OS_ERROR\n");
    $fh->binmode(':bytes');
    my $data = <$fh>;
    $fh->close;

    return $data;
}

#*****************************************************************************
#** @function private flatten (@$array)
# @brief Flatten a nested array
#
# Produces a flat array out of a nested one weeding out duplicated
# items. For example, the following transformations will be performed:
#   - [1,2,3,4,5] -> [1,2,3,4,5];
#   - [1,[2,3],[4,5]] -> [1,2,3,4,5];
#   - [1,[2,[3,[4,[5]]]]] -> [1,2,3,4,5];
#   - [1,1,1,1,1] -> [1].
#
# @params @$array   reference to an array that contains scalars or
#                   nested arrays
# @retval @$array   reference to a copy of the input array that contains
#                   only unique scalars
#*
#-----------------------------------------------------------------------------
sub flatten($array) {
    my $flat_array = clone($array);

    my $len = scalar(@{$flat_array});
    for my $i (0 .. $len - 1) {
        my $el = $flat_array->[$i];

        if (is_bool_json($el)) {
            next;
        }

        my $type = ref($el);
        if (!$type) {
            next;
        }

        if ($type ne 'ARRAY') {
            fatalf('Unsupported ref type: %s', dump_data($el));
        }

        splice(@{$flat_array}, $i, 1, @{$el});
        # retry the same element to process nested arrays
        $len += scalar(@{$el}) - 1;
        $i--;
    } ## end for my $i (0 .. $len - ...)

    # filter out duplicated values
    my %seen;
    @{$flat_array} = grep {!$seen{$_ // 'NULL'}++} @{$flat_array};

    return $flat_array;
} ## end sub flatten

#*****************************************************************************
sub this {
    my $this = (caller(1))[3];
    $this =~ s/^.*:://;

    return $this;
}

#*****************************************************************************
1;
__END__
