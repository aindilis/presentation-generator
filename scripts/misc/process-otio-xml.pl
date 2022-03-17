#!/usr/bin/env perl

use PerlLib::SwissArmyKnife;

# mst recommends Mojo::DOM instead of XML::Simple;
use XML::Simple;

my $inputfile = '/var/lib/myfrdcsa/codebases/minor/presentation-generator/data-git/kdenlive/bytelibrary.otio.xml';
my $outputfile = '/var/lib/myfrdcsa/codebases/minor/presentation-generator/data-git/kdenlive/bytelibrary.2.otio.xml';
if (-f $inputfile) {
  my $data = XMLin($inputfile, keyattr => [], ForceArray => 1);
  print Dumper({Data => $data});
  die;
  my $xml = XMLout($data, keyattr => []);
  WriteFile(Contents => $xml, File => $outputfile);
}

# otioconvert -i bytelibrary.2.otio.xml -o bytelibrary.2.kdenlive
