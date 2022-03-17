#!/usr/bin/env perl

use PerlLib::SwissArmyKnife;

use XML::Simple;

# my $inputsolfile = '/var/lib/myfrdcsa/codebases/minor/presentation-generator/data-git/verber/generation.p.pddl.LPG.sol';
my $inputsolfile = '/var/lib/myfrdcsa/codebases/internal/verber/data/worldmodel/worlds/video/3/generation.p.pddl.LPG.sol';
my $outputfile = '/var/lib/myfrdcsa/codebases/minor/presentation-generator/data-git/verber/generation2.xml';

my $numslides = 45;

my $c = read_file($inputsolfile);
my @steps;
my $actions = {};
my $timepoints = {};
my $i = 1;
foreach my $line (split /\n/, $c) {
  if ($line =~ /([\d\.]+):\s*\((.*?)\)\s\[([\d\.]+)\]/) {
    my $starttime = $1;
    my $action = [split /\s+/, $2];
    my $duration = $3;
    $actions->{$i} =
      {
       StartTime => $starttime,
       Action => $action,
       Duration => $duration,
      };
    push @{$timepoints->{$starttime}{Start}}, $i;
    push @{$timepoints->{$starttime + $duration}{End}}, $i;
    ++$i;
  }
}

print Dumper($timepoints);

my $timebase = 60;
my $audiostarttimes = {};
my $audiodurations = {};
my @videoclipitem;
my @audioclipitem;
foreach my $timepoint (sort {$a <=> $b} keys %$timepoints) {
  if (exists $timepoints->{$timepoint}{End}) {
    # do nothing yet
  }
  if (exists $timepoints->{$timepoint}{Start}) {
    foreach $actionid (@{$timepoints->{$timepoint}{Start}}) {
      if ($actions->{$actionid}{Action}[0] eq 'PLAY-AUDIO-CLIP') {
	my $starttime = ConvertPlanTimeToTimelineTime(Time => $actions->{$actionid}{StartTime});
	my $duration = ConvertPlanTimeToTimelineTime(Time => $actions->{$actionid}{Duration});
	my $offset = $actions->{$actionid}{Action}[1];
	print "<<<$offset>>>\n";
	$offset =~ s/^AC//;
	$audiostarttimes->{$offset} = $starttime;
	$audiodurations->{$offset} = $duration;
	my $fileid = $offset;
	print Dumper({StartTime => $starttime, Duration => $duration});
	print "$starttime\n";
	push @audioclipitem,
	  CreateAudioClipItem
	  (
	   ID => "file-$fileid",
	   ClipItemID => "clipitem-$fileid",
	   Name => "s$offset.wav",
	   PathURL => "/media/andrewdo/SSD2/PresGen/projects/logicmoo-videos/logicmoo-video-1/videos/a$offset.wav",
	   StartTime => $starttime,
	   EndTime => ($starttime + $duration),
	   Duration => $duration,
	  );
      }
    }
  }
}

print Dumper
  ({
    AudioStartTimes => $audiostarttimes,
    AudioDurations => $audiodurations,
   });

foreach my $timepoint (sort {$a <=> $b} keys %$timepoints) {
  if (exists $timepoints->{$timepoint}{End}) {
    # do nothing yet
  }
  if (exists $timepoints->{$timepoint}{Start}) {
    foreach $actionid (@{$timepoints->{$timepoint}{Start}}) {
      if ($actions->{$actionid}{Action}[0] eq 'PLAY-VIDEO-CLIP') {
	print Dumper($actions->{$actionid});
	my $starttime = ConvertPlanTimeToTimelineTime(Time => $actions->{$actionid}{StartTime});
	my $duration = ConvertPlanTimeToTimelineTime(Time => $actions->{$actionid}{Duration});
	my $offset = $actions->{$actionid}{Action}[1];
	print "<<<$offset>>>\n";
	if ($offset =~ /^VC/) {
	  $offset =~ s/^VC//;
	  my $fileid = $numslides + $offset;
	  print Dumper({StartTime => $starttime, Duration => $duration});
	  push @videoclipitem,
	    CreateVideoClipItem
	    (
	     ID => "file-$fileid",
	     ClipItemID => "clipitem-$fileid",
	     Name => "s$offset-".($offset + 1).".mp4",
	     PathURL => "/media/andrewdo/SSD2/PresGen/projects/logicmoo-videos/logicmoo-video-1/videos/s$offset-".($offset + 1).".mp4",
	     StartTime => $starttime,
	     EndTime => ($starttime + $duration),
	     Duration => $duration,
	    );
	} elsif ($offset =~ /^IC/) {
	  $offset =~ s/^IC//;
	  print "WWTF $offset\n";
	  my $fileid = (2 * $numslides) + $offset;
	  my $length = $audiodurations->{$offset} - 119;
	  if ($length < 0) {
	    $length = 1;
	  }
	  print Dumper({StartTime => $audiostarttimes->{$offset}, Duration => $length});
	  push @videoclipitem,
	    CreateVideoClipItem
	    (
	     ID => "file-$fileid",
	     ClipItemID => "clipitem-$fileid",
	     Name => "s$offset.png",
	     PathURL => "/media/andrewdo/SSD2/PresGen/projects/logicmoo-videos/logicmoo-video-1/videos/s$offset.png",
	     StartTime => $audiostarttimes->{$offset},
	     EndTime => ($audiostarttimes->{$offset} + $length),
	     Duration => $length,
	    );
	}
      }
    }
  }
}
print Dumper(\@videoclipitem);
# print Dumper(\@audioclipitem);

my $data = CreatePerl
  (
   VideoClipItem => \@videoclipitem,
   AudioClipItem => \@audioclipitem,
  );
my $xml = XMLout($data, keyattr => []);
print "$outputfile\n";
WriteFile(Contents => $xml, File => $outputfile);
my $kdenlivefile = $outputfile;
$kdenlivefile =~ s/\.xml$/.kdenlive/;
system 'otioconvert -i '.shell_quote($outputfile).' -o '.shell_quote($kdenlivefile);

sub ConvertPlanTimeToTimelineTime {
  my (%args) = @_;
  return round($args{Time});
}

sub CreateVideoClipItem {
  my (%args) = @_;
  return
    {
     'end' => [
	       $args{EndTime},
	      ],
     'out' => [
	       $args{Duration}, # $args{EndTime},
	      ],
     'rate' => [
		{
		 'timebase' => [
				'60'
			       ],
		 'ntsc' => [
			    'TRUE'
			   ]
		},
		{
		 'ntsc' => [
			    'TRUE'
			   ],
		 'timebase' => [
				'60'
			       ]
		}
	       ],
     'file' => [
		{
		 'media' => [
			     {
			      'audio' => [
					  {
					  }
					 ],
			      'video' => [
					  {
					  }
					 ]
			     }
			    ],
		 'timecode' => [
				{
				 'frame' => [
					     '0'
					    ],
				 'rate' => [
					    {
					     'timebase' => [
							    '60'
							   ],
					     'ntsc' => [
							'TRUE'
						       ]
					    }
					   ],
				 'string' => [
					      '00:00:00:00'
					     ],
				 'displayformat' => [
						     'NDF'
						    ]
				}
			       ],
		 'pathurl' => [
			       $args{PathURL},
			      ],
		 'duration' => [
				$args{Duration},
			       ],
		 'id' => $args{ID},
		 'rate' => [
			    {
			     'ntsc' => [
					'TRUE'
				       ],
			     'timebase' => [
					    '60'
					   ]
			    }
			   ],
		 'name' => [
			    $args{Name},
			   ]
		}
	       ],
     'frameBlend' => 'FALSE',
     'name' => [
		{
		}
	       ],
     'start' => [
		 $args{StartTime},
		],
     'id' => $args{ClipItemID},
     'duration' => [
		    $args{Duration},
		   ],
     'in' => [
	      '0',
	      # $args{StartTime},
	     ]
    };
}

sub CreateAudioClipItem {
  my (%args) = @_;
  return
    {
     'file' => [
		{
		 'name' => [
			    $args{Name},
			   ],
		 'duration' => [
				$args{Duration},
			       ],
		 'rate' => [
			    {
			     'timebase' => [
					    '60'
					   ],
			     'ntsc' => [
					'TRUE'
				       ]
			    }
			   ],
		 'timecode' => [
				{
				 'rate' => [
					    {
					     'timebase' => [
							    '60'
							   ],
					     'ntsc' => [
							'TRUE'
						       ]
					    }
					   ],
				 'displayformat' => [
						     'NDF'
						    ],
				 'string' => [
					      '00:00:00:00'
					     ],
				 'frame' => [
					     '0'
					    ]
				}
			       ],
		 'media' => [
			     {
			      'audio' => [
					  {
					  }
					 ]
			     }
			    ],
		 'pathurl' => [
			       $args{PathURL},
			      ],
		 'id' => $args{ID},
		}
	       ],
     'start' => [
		 $args{StartTime},
		],
     'id' => $args{ClipItemID},
     'frameBlend' => 'FALSE',
     'out' => [
	       $args{Duration},
	       # $args{EndTime},
	      ],
     'end' => [
	       $args{EndTime},
	      ],
     'in' => [
	      '0',
	      # $args{StartTime},
	     ],
     'name' => [
		{
		}
	       ],
     'duration' => [
		    $args{Duration},
		   ],
     'rate' => [
		{
		 'ntsc' => [
			    'TRUE'
			   ],
		 'timebase' => [
				'60'
			       ]
		},
		{
		 'ntsc' => [
			    'TRUE'
			   ],
		 'timebase' => [
				'60'
			       ]
		}
	       ]

    };
} 

  

sub CreatePerl {
  my (%args) = @_;
  return
    {
     'Data' => {
		'version' => '4',
		'project' => [
			      {
			       'children' => [
					      {
					       'sequence' => [
							      {
							       'name' => [
									  'Kdenlive imported timeline'
									 ],
							       'duration' => [
									      '817'
									     ],
							       'rate' => [
									  {
									   'timebase' => [
											  '60'
											 ],
									   'ntsc' => [
										      'TRUE'
										     ]
									  }
									 ],
							       'media' => [
									   {
									    'audio' => [
											{
											 'track' => [
												     {
												      'clipitem' => $args{AudioClipItem},
												     },
												     {
												     }
												    ]
											}
										       ],
									    'video' => [
											{
											 'track' => [
												     {
												      'clipitem' => $args{VideoClipItem},
												     },
												     {
												     }
												    ]
											}
										       ]
									   }
									  ],
							       'id' => 'sequence-1'
							      }
							     ]
					      }
					     ],
			       'name' => [
					  'Kdenlive imported timeline'
					 ]
			      }
			     ]
	       }
    };
}

print $kdenlivefile."\n";
