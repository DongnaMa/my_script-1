#!perl

use Getopt::Std;
getopts "x:i:e:";


if ((!defined $opt_x) || (!defined $opt_i) || (!defined $opt_e)) {
    die "************************************************************************
    Usage: perl $0 -x xmap -i ref.fasta -e BspQI
      -h : help and usage.
      -x : xmap from hybrid assembly
      -i : ref.fasta
      -e : in silico digest enzyme
************************************************************************\n";
}else{
  print "************************************************************************\n";
  print "Version 1.0\n";
  print "Copyright to Tanger, tanger.zhang\@gmail.com\n";
  print "RUNNING...\n";
  print "************************************************************************\n";
	
	}
$ref_file = $opt_i;
$enzyme   = $opt_e;
$xmap     = $opt_x;

if($ref_file ne "ref.fasta"){
	$cmd = "ln -s $ref_file ./ref.fasta" ;
  system($cmd);
	}


$cmd = "perl ~/Irys-scaffolding/KSU_bioinfo_lab/assemble_XeonPhi/third-party/fa2cmap_multi.pl -i ref.fasta -e $enzyme";
system($cmd);

$key_file = "ref_".$enzyme."_key.txt";

open(IN, $key_file) or die"";
while(<IN>){
	chomp;
	next if(/#/);
	next if(/CompntId/);
	@data = split(/\s+/,$_);
	$id   = $data[0];
	$scaf = $data[1];
	$iddb{$id} = $scaf;
	}
close IN;

open(IN, $xmap) or die"";
while(<IN>){
	chomp;
	next if(/#/);
	@data      = split(/\s+/,$_);
	$chr_id    = $data[1];
	$chr_posia = $data[3];
	$chr_posib = $data[4]; 
	$lg        = $data[2];
	$lg_posia  = $data[5];
	$lg_posib  = $data[6];
	$infordb{$lg}->{$lg_posia} = $chr_id."_".$chr_posia; 
	$infordb{$lg}->{$lg_posib} = $chr_id."_".$chr_posib; 
	}
close IN;
open(OUT, "> bionano.map.csv") or die"";
print OUT "Scaffold ID,scaffold position,LG,genetic position\n";
foreach $lg(sort {$a<=>$b} keys %infordb){
	foreach $lg_posi (sort {$a<=>$b} keys %{$infordb{$lg}}){
		($chr_id,$chr_posi) = split(/_/,$infordb{$lg}->{$lg_posi});
		$chrn = $iddb{$chr_id};
		print OUT "$chrn,$chr_posi,$lg,$lg_posi\n";
		}
	}
close OUT;
