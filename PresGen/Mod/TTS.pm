package PresGen::Mod::TTS;

use API;
# use API::API;
# use API::SourceManager;
use PerlLib::SwissArmyKnife;

use Template;
use URI::Encode;
use Digest::MD5 qw(md5_base64);
use Text::Unidecode;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / NoOverwriting MyURIEncode MyAPIManager
   MyCloudGoogleComTextToSpeech /

  ];

sub init {
  my ($self,%args) = @_;
  $self->NoOverwriting($args{NoOverwriting});
  $self->MyURIEncode(URI::Encode->new({encode_reserved => 1}));
  $self->MyAPIManager(API->new());
  # API::Source::CloudGoogleComTextToSpeech::TextToSpeech;
  $self->MyCloudGoogleComTextToSpeech
    ($self->MyAPIManager->GetAPI(API => 'CloudGoogleComTextToSpeech/TextToSpeech'));
}

sub GenerateTTS {
  my ($self,%args) = @_;
  my $res1;
  if (0) {
    $res1 = $self->GenerateTTSFestival(%args);
  } else {
    $res1 = $self->GenerateTTSGCloudTTS(%args);
  }
  if ($res1->{Success}) {
    my $audiofile = $res1->{Results}{AudioFile};
    return
      {
       Success => 1,
       Results => {
		   AudioFile => $audiofile,
		   Duration => $self->GetDurationOfAudioFile(AudioFile => $audiofile),
		  },
      };
  }
}

sub GetDurationOfAudioFile {
  my ($self,%args) = @_;
  my $qaudiofile = shell_quote($args{AudioFile});
  my $text = `exiftool $qaudiofile | grep -E '^Duration'`;
  chomp $text;
  my $duration;
  if ($text =~ /([0-9]+):([0-9]+):([0-9]+)/) {
    $duration = $1 * 3600.0 + $2 * 60.0 + $3;
  } elsif ($text =~ /([0-9\.]+)/) {
    $duration = $1;
  }
  return $duration;
}

sub GenerateTTSFestival {
  my ($self,%args) = @_;
  my $base = ConcatDir('/media/andrewdo/SSD2/PresGen/projects/'.$UNIVERSAL::presgen->MyProject->Class.'/'.$UNIVERSAL::presgen->MyProject->Name.'/videos','a'.$args{ID});
  my $outputfile = $base.'.wav';
  my $qoutputfile = shell_quote($outputfile);

  my $mp3file = $base.'.mp3';
  my $qmp3file = shell_quote($mp3file);

  if ($self->NoOverwriting) {
    if (-f $mp3file) {
      return
	{
	 Success => 1,
	 Results => {
		     AudioFile => $mp3file,
		    },
	};
    } else {
      print STDERR "Error: no overwriting specified but no mp3file exists\n";
      return
	{
	 Success => 0,
	 Results => {
		     AudioFile => $mp3file,
		    },
	};
    }
  } else {
    print "Generating Festival TTS\n";
    # my $command = 'echo '.shell_quote($args{Text}).' | text2wave -o '.$qoutputfile;
    my $command = 'echo '.shell_quote($args{Text}).' | festival_client --ttw > '.$qoutputfile;
    print $command."\n";
    if ($command !~ /echo ''/) {
      system $command;
      if (-f $qoutputfile) {
	my $command2 = 'lame -b 320 -h '.$qoutputfile.'  '.$qmp3file;
	print $command2."\n";
	system $command2;
      }
    } else {
      print "GENERATING AN EMPTY WAV\n";
      if (! -f $mp3file) {
	my $command = 'touch '.$qmp3file;
	print $command."\n";
	system $command;
      } else {
	my $command = 'truncate --size '.$qmp3file;
	print $command."\n";
	system $command;
      }
    }
    return
      {
       Success => {-f $mp3file},
       Results => {
		   AudioFile => $mp3file,
		  },
      };
  }
}

sub GenerateFilenameFromText {
  my ($self,%args) = @_;
  my $text = $args{Text};
  $text =~ s/[^0-9a-zA-Z]/_/sg;
  $text =~ s/^_//sg;
  $text =~ s/_*$//sg;
  return substr($text,0,50).'-'.md5_base64($text).'.mp3';
}

sub GenerateTTSGCloudTTS {
  my ($self,%args) = @_;

  my $base = ConcatDir('/media/andrewdo/SSD2/PresGen/projects/'.$UNIVERSAL::presgen->MyProject->Class.'/'.$UNIVERSAL::presgen->MyProject->Name.'/videos','a'.$args{ID});
  my $mp3file = $base.'.mp3';
  my $qmp3file = shell_quote($mp3file);

  my $text = unidecode($args{Text});

  # FIXME: modify text more
  $text =~ s/\// /sg;
  $text =~ s/[\n\r]+/ /sg;
  $text =~ s/\x{a}/ /sg;
  $text =~ s/[^[:ascii:]]+/ /sg;
  $text =~ s/^\s+//sg;
  $text =~ s/\s+$//sg;

  print Dumper({TextWTFAsshole => $text});

  my $filename = $self->GenerateFilenameFromText(Text => $text);
  my $fullfilename = "/var/lib/myfrdcsa/codebases/minor/text-to-speech/data/generated/gcloud-tts/$filename";
  if (! -f $fullfilename) {
    my $res1 = $self->MyCloudGoogleComTextToSpeech->TextToSpeech
      (
       Overwrite => 1,
       Input => $text,
       Filename => $filename,
      );
    print Dumper({Res1 => $res1});
  }
  my $chase = `chase $qmp3file`;
  chomp $chase;
  if (-f $fullfilename and $chase ne $fullfilename) {
    my $command2 = "mv -b $qmp3file /tmp";
    print $command2."\n";
    system $command2;
    my $command2 = "ln -s ".shell_quote($fullfilename)." $qmp3file";
    print $command2."\n";
    system $command2;
  }
  if (-f $mp3file and -f $fullfilename) {
    return
      {
       Success => 1,
       Results => {
		   AudioFile => $mp3file,
		   Duration => $self->GetDurationOfAudioFile(AudioFile => $mp3file),
		  },
      };
  } else {
    return {
	    Success => 0,
	   };
  }
}

# sub GenerateTTSGCloudTTSOrig {
#   my ($self,%args) = @_;
#   my $base = ConcatDir('/media/andrewdo/SSD2/PresGen/projects/'.$UNIVERSAL::presgen->MyProject->Class.'/'.$UNIVERSAL::presgen->MyProject->Name.'/videos','a'.$args{ID});
#   my $mp3file = $base.'.mp3';
#   my $qmp3file = shell_quote($mp3file);

#   my $encoded = $self->MyURIEncode->encode($args{Text});

#   my $command1 = "curl -X PUT http://miguel:python\@127.0.0.1:5000/todo/api/v1.0/tts/$encoded";
#   print $command1."\n";
#   system $command1;
#   my $command2 = "mv /var/lib/myfrdcsa/sandbox/python-texttospeech-20220311/python-texttospeech-20220311/output.mp3 $qmp3file";
#   print $command2."\n";
#   system $command2;

#   if (-f $mp3file) {
#     return
#       {
#        Success => 1,
#        Results => {
# 		   AudioFile => $mp3file,
# 		   Duration => $self->GetDurationOfAudioFile(AudioFile => $mp3file),
# 		  },
#       };
#   } else {
#     return {
# 	    Success => 0,
# 	   };
#   }
# }

1;
