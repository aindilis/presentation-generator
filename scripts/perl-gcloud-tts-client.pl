#!/usr/bin/env perl

use URI::Encode qw(uri_encode);

my $encoded = uri_encode($ARGV[0]);

my $command = "curl -X PUT http://miguel:python\@127.0.0.1:5000/todo/api/v1.0/tts/$encoded";
print $command."\n";
system $command;
system 'mplayer output.mp3'
