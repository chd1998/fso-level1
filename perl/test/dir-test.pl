#!/usr/bin/perl 
use File::Basename;
use Data::Dumper;
use File::Find;

my $dir = $ARGV[0] ||= "." || die $!;
my @files = get_all_files($dir);

sub get_all_files {
    my ($dir) = @_;
    my @Files;
    # Use $File::Find::name instead of $_ to get the paths.
    #find(sub { push @Files, $_ }, $dir);
    #find(sub { push @Files, $File::Find::name }, $dir);
    find(sub { (-f && /\.fits$/i); push @Files,  $File::Find::name }, $dir);    
    return @Files
}


my $count = 0;
foreach $file(@files) {
    print "$count $file \n" ;
    $count += 1;
}    

