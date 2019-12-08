#!/usr/bin/perl

package C08_2;

use strict;
use warnings;
use feature qw( say );

use C08_1;

my $width = 25;
my $height = 6;
my $layer_size = $width * $height;


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub stack_layers {
    my @layers = @_;
    my @rendering = @{$layers[0]};

    for my $layer (@layers[1 .. $#layers]) {
        for my $i (0 .. $#rendering) {
            $rendering[$i] = $rendering[$i] == 2 ? $layer->[$i] : $rendering[$i];
        }
    }

    return \@rendering;
}


sub print_layer {
    my ($layer) = @_;

    my @layer = map { $_ == 1 ? "▓" : " " } @$layer;

    for my $i (0 .. $height-1) {
        say @layer[$i*$width .. ($i+1) * $width - 1];
    }

}


sub main {
    # ($width, $height) = (3, 2);
    # my $data = "123456789012";

    ($width, $height) = (25, 6);
    open my $FH, '<', "input_08.txt" or die $!;
    my $data = do { local $/ = undef; <$FH> };

    my @layers = C08_1::layerize_image(split //, $data);

    my $rendering = stack_layers(@layers);

    print_layer($rendering);

}

1;
