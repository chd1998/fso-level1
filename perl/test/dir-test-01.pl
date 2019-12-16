#!/usr/bin/perl
use File::Basename;
use Data::Dumper;
user File::Find;

my @files; 
my $path = shift; 

find(sub { (-f && /\.fits$/i) or return; push @files, $File::Find::name;}, $path);

foreach $file(@files)
{
  print "$file \n";
}
