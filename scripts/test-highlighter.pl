#!/usr/bin/env perl

use PresGen::Mod::Highlighter;

# see also
# /var/lib/myfrdcsa/codebases/minor/presentation-generator/data/projects/logicmoo-videos/logicmoo-video-1/presentation.txt
# /var/lib/myfrdcsa/codebases/minor/presentation-generator/data/projects/logicmoo-videos/logicmoo-video-1/slides/s.html

my $highlighter = PresGen::Mod::Highlighter->new();

print $highlighter->HighlightPlainText
  (
   Text => 'Douglas Miles and the LOGICMOO Project

A Select Look at Some of His Work

INTRODUCTION'
  );
