package PresGen;

use BOSS::Config;
use MyFRDCSA;
use PerlLib::SwissArmyKnife;
use PresGen::Mod::Presentation;
use PresGen::Mod::Project;
use PresGen::Mod::Slide;
use PresGen::Mod::TTS;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config MyPresentation MyProject MySlide MyTTS MyResources
   ProjectsDir ProjectDir /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-c <class>		Project Class (i.e.)
	-p <project>		Project Name

	-f <file>		Presentation Notes

	--video			Which rendering stage to proceed to, i.e. 1, 2, 3.
	--tts 			Output text to speech files

	--no			No overwriting of TTS or Video output

	-u [<host> <port>]	Run as a UniLang agent

	-w			Require user input before exiting
";
  $UNIVERSAL::systemdir = ConcatDir(Dir("minor codebases"),"presentation-generator");
  $self->Config
    (BOSS::Config->new
     (Spec => $specification,
      ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  $self->MyResources({});
  $self->ProjectsDir(ConcatDir($UNIVERSAL::systemdir,'data','projects'));
  my $projectdir = ConcatDir($self->ProjectsDir,$conf->{'-c'},$conf->{'-p'});
  print "$projectdir\n";
  if (! -d $projectdir) {
    die "Need a valid project\n";
  }
  $self->MyProject
    (PresGen::Mod::Project->new
     (
      Class => $conf->{'-c'},
      Name => $conf->{'-p'},
      Directory => $projectdir,
     ));
  $self->ProjectDir($projectdir);
  $self->MyPresentation(PresGen::Mod::Presentation->new());
  $self->MySlide(PresGen::Mod::Slide->new());
  $self->MyTTS(PresGen::Mod::TTS->new(NoOverwriting => $conf->{'--no'}));
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
  $self->GenerateSlideHTMLFromSourceMaterial();
  if (exists $conf->{'--video'}) {
    $self->RenderAllSlideHTMLsToVideoClips();
  }
  # $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";
  # if (! exists $conf->{'-f'} or ! -f $conf->{'-f'}) {
  #   die "Need to specify the file with -f\n";
  # }
}

sub GenerateSlideHTMLFromSourceMaterial {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  my $res1 = $self->MyProject->GenerateProject();
  if (! $res1->{Success}) {
    print STDERR "No success\n";
  }
  my $data = $res1->{Results}{Results};
  my $lastentry;
  my $lasttoreadlist;
  # unshift @$data, ('The Start');
  # push @$data, ('The End','.');
  unshift @{$data->[0]->{Fragments}}, ('   ');
  push @{$data->[-1]->{Fragments}}, ('   ','.');
  # print Dumper($data);
  # die;
  my $slidedir = ConcatDir($self->ProjectDir,"slides","dummy");
  if (! -d $slidedir) {
    system 'mkdir -p '.shell_quote($slidedir);
    # cp -ar reveal-js-20210727/* $slidedir
  }
  my $i = 0;
  my @slides;
  foreach my $datum (@$data) {
    my $toreadlist = $datum->{ToRead};
    my $readall = $datum->{ReadAll};
    my $j = 0;
    foreach my $entry (@{$datum->{Fragments}}) {
      print Dumper({
		    Entry => $entry,
		    LastEntry => $lastentry,
		    ToReadList => $toreadlist,
		    LastToReadList => $lasttoreadlist,
		   }) if 0;
      if ($entry =~ /\S/ or $entry eq '   ') {
	if (defined $lastentry) { # and not defined $data->[$j+1]) {
	  if ($i > 5) {
	    # last;
	  }
	  if ($readall) {
	    print "<<<".$lasttoreadlist.">>>\n";
	    $self->MyResources->{ttses}->{$i} = $self->MyTTS->GenerateTTS
	      (
	       ID => $i,
	       Text => $lasttoreadlist, # $toreadlist->[0], # $lastentry,
	      ) if (exists $conf->{'--tts'});
	  } else {
	    print "<<<".$lasttoreadlist.">>>\n";
	    $self->MyResources->{ttses}->{$i} = $self->MyTTS->GenerateTTS
	      (
	       ID => $i,
	       Text => $lasttoreadlist,
	      ) if (exists $conf->{'--tts'});
	  }
	  print Dumper({TTS => $self->MyResources->{ttses}->{$i}});
	  $self->MyResources->{slides}->{$i} = $self->MySlide->GenerateSlide
	    (
	     Current => $lastentry,
	     Next => $entry,
	     TTS => $self->MyResources->{ttses}->{$i},
	    );
	  my $slide = $self->MySlide->CurrentSlide();
	  print Dumper({Slide => $slide});
	  push @slides, $slide;

	  print Dumper($self->MyResources->{slides}->{$i});

	  my $presentation = $self->MyPresentation->GeneratePresentation
	    (
	     Slides => [$self->MyResources->{slides}->{$i}],
	    );

	  # print $presentation."\n\n\n\n";
	  my $outputfile = "$slidedir/s$i-".($i + 1).'.html';
	  print "<$outputfile>\n";
	  WriteFile(Contents => $presentation, File => $outputfile);
	  $self->MyResources->{outputfiles}->{$i} = $outputfile;
	}
	++$i;
	++$j;
	$lastentry = $entry;
	$lasttoreadlist = $toreadlist->[0];
      }
    }
  }
  $i = 0;

  print Dumper({Slides => \@slides});
  print Dumper($self->MyResources) if $UNIVERSAL::debug;
  my $outputfile2 = "$slidedir/s.html";
  my $presentation2 = $self->MyPresentation->GeneratePresentation
    (
     Slides => \@slides,
    );
  # print "<$outputfile2>\n";
  WriteFile(Contents => $presentation2, File => $outputfile2);
  print Dumper
    ({
      Resources => $self->MyResources,
      Presentation => $presentation,
     }) if 0;
}

# now go ahead and render all the slide htmls to mp4

sub RenderAllSlideHTMLsToVideoClips {
  my ($self,%args) = @_;
  my $i = 0;
  foreach my $slideid (sort {$a <=> $b} keys %{$self->MyResources->{outputfiles}}) {
    if ($i++ > 5) {
      # die;
    }
    print $slideid."\n";
    my $outputfile = $self->MyResources->{outputfiles}{$slideid};
    my $qoutputfile = shell_quote($outputfile);
    my $command = '/var/lib/myfrdcsa/codebases/minor/presentation-generator/scripts/capture-website.pl -c '.shell_quote($UNIVERSAL::presgen->MyProject->Class).' -p '.shell_quote($UNIVERSAL::presgen->MyProject->Name).' -f '.$qoutputfile."\n";
    print "$command\n";
    system $command;
  }
}


sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^echo\s*(.*)/) {
      $UNIVERSAL::agent->SendContents
	(Contents => $1,
	 Receiver => $m->{Sender});
    } elsif ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    }
  }
}

1;
