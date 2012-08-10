#!/usr/bin/perl
use strict;
use warnings;

my @weights  = (2.15, 2.75, 3.35, 3.55, 4.20, 5.80);

my $total = 0;
my @order = ();

iterate($total, @order);

sub iterate
{
    my ($total, @order) = @_;
    foreach my $w (@weights)
    {
    	if ($total+$w == 15.05)
    	{
    		print join (', ', (@order, $w)), "\n";
    	}
    	if ($total+$w < 15.05)
    	{
    		iterate($total+$w, (@order, $w));
    	}
    }
}