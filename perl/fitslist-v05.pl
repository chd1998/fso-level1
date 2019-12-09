#!/usr/bin/perl

use File::Basename;
use Data::Dumper;
use File::Find::Rule;
use PDL;
use PDL::IO::Dumper;
use PDL::IO::FITS;

if (@ARGV < 2 || @ARGV >=3)
{
	print "Usage : fitslist /path/ yourlogfilename\n";
	print "Purpose : Classify the fits files in a directory with regard to objects \n";
	print "Example : ./fitslist-v0.5 ./HA/ ha.log\n";
}
else
{
	@namelist = ("");
	@tmp = ("");
	$result = 0;

	$e = (-e $ARGV[1]);
	if ($e == 1)
	{
		unlink("$ARGV[1]");
	}
	$count = 0; 
	rint "=============================================================\n";
	print "=                                                           =\n";
	print "=            FSO fits files Archiving Utility               =\n";
	print "=                                                           =\n";
	print "=        fitslist to sort the files of each object          =\n";
	print "=                                                           =\n";
	print "=                 Rev. 0.5 (2019-11-11)                     =\n";
	print "=                                                           =\n";
	print "=============================================================\n";
	print "FSO Fits files sorting, please wait .....\n";
	#opendir(DIR, "$ARGV[0]") or die ("Could not open $ARGV[0]");
	$DIR = $ARGV[0] ||= "./" || die $!;
	print "Getting all files under $DIR, please wait.....\n";
	@files = get_all_files($DIR);
	@files = sort(@files);
	print "Getting file list finished! \n";
	#my $count = 0;
	#foreach $file(@files) {
	#    print "$count $file \n" ;
	#    $count += 1;
	#}


	#get namelist of objects
	print "Getting name list of objects, please wait.....\n";
	foreach $file(@files)
	{	
	
		#print "$tcount : $file \n";
		$objname = getobjname($file);	
		#print "$count: $objname found \n ";
		$result = 0;
		#$i = 0;
		foreach my $name(@namelist)
		{
			if ($objname eq $name)
			{
				$result = 1;
				last;	
			}	
		}
		
		if ($result == 0)
		{
			$tmp[0]=$objname;
			push(@namelist,@tmp);
       		print "$count : $objname found!\n";
       		$count += 1;
			@tmp = ("");
		}	
	}

	#print "$#namelist Objects Name Found...\n";
	shift(@namelist);
	@namelist = sort(@namelist);
	$count = 0;
	open(txt, ">>$ARGV[1]");
	#my $ncount = 0;
	#foreach $cname1(@namelist) {
	#    print "$ncount : $cname1 \n" ;
	#    $ncount += 1;
	#}
	print txt "***************START*******************\n";
	print "***************START*******************\n";
	#sort out the files with regard to each object
	print "Sorting files with regard to each object, please wait.....\n";
	foreach $name(@namelist)
	{
		print txt "$name \n";
		print txt "***************************************\n";
		$exist =  -d "./$name/";
		if(!$exist)
		{
			mkdir("./$name", 0755);
		}
		foreach $file(@files)
		{
			$tmpobj = getobjname($file);
			if ($tmpobj eq $name)
			{
				print "$count : Copying $file to ./$name/\n";
				@tmpf = split(/\//,$file);
				$tmpn = @tmpf[$#tmpf];
				print txt "./$name/$tmpn\n";
            	$count += 1;
				$status = system("cp -f $file ./$name/.");
			}
		}
		print txt "***************************************\n";
	}
	print txt "*******************END*****************\n";
	print "*******************END*****************\n";
	print "Finished!\n";
}

sub get_all_files {
    my $dir = @_[0];
    my @Files = File::Find::Rule->file()->name('*.fits')->in($dir);
    # Use $File::Find::name instead of $_ to get the paths.
    #find(sub { push @Files, $_ }, $dir);
    #find(sub { push @Files, $File::Find::name }, $dir);
    #find(sub { (-f && /\.fits$/i); push @Files,  $File::Find::name }, $dir);
    return @Files
}

sub getobjname
{
    #open infile, "<$_[0]" or die("Could not open $_[0]");
    #print $_[0];
    my $infits = rfits ($_[0]);
    my $h = $infits->gethdr;
    my $obj = $$h{OBSOBJ};
    return $obj;
}

