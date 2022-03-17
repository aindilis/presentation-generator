package PresGen::Mod::Slide;

use PresGen::Mod::BulletPointGenerator;
use PresGen::Mod::Highlighter;

use PerlLib::SwissArmyKnife;

use Template;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTemplate CurrentSlide MyBulletPointGenerator /

  ];

my $stub = '';

sub init {
  my ($self,%args) = @_;
  $self->MyBulletPointGenerator
    (PresGen::Mod::BulletPointGenerator->new
     ());
  my $config =
    {
     INCLUDE_PATH => '/var/lib/myfrdcsa/codebases/minor/presentation-generator/data-git/templates', # or list ref
     INTERPOLATE  => 1,		# expand "$var" in plain text
     POST_CHOMP   => 1,		# cleanup whitespace
     # PRE_PROCESS  => 'header', # prefix each template
     EVAL_PERL    => 1,		# evaluate Perl code blocks
    };
  $self->MyTemplate
    (Template->new
     (
      $config
     ));
}

sub GenerateSlide {
  my ($self,%args) = @_;
  my @items;

  my $current = $self->MyBulletPointGenerator->GenerateBulletPoints
    (
     Text => $args{Current},
    );
  push @items, {
		Content => $current."\n",
		SectionArgs => {
				'data-autoslide' => 120000,
			       },
	       };
  my $startisquotes = $PresGen::Mod::Highlighter::startisquotes;
  print "<my-startisquotes:$startisquotes>\n";

  my $next;
  if (exists $args{Next}) {
    $next = $self->MyBulletPointGenerator->GenerateBulletPoints
      (
       Text => $args{Next},
      );
    push @items, {
		  Content => $next."\n",
		  SectionArgs => {
				  'data-autoslide' => 120000,
				 },
		 };
  }
  $PresGen::Mod::Highlighter::startisquotes = $startisquotes;

  # print Dumper({Items => \@items});
  my $vars =
    {
     self => $self,
     items => \@items,
    };
  $self->MyTemplate->process
    (
     'slide.tt',
     $vars,
     sub {$stub = $_[0];},
    ) || die $self->MyTemplate->error(), "\n";
  my $rendered1 = $stub;
  $stub = '';

  my $duration = 2500;
  if (exists $args{TTS}{Results}{Duration}) {
    $duration = $args{TTS}{Results}{Duration} * 1000.0;
  }
  if ($current =~ /<video data-autoplay src="file:\/\/([^"]+?)">/s) {
    my $videofile = $1;
    print Dumper({Hallelujah => $duration});
    my $res1 = $self->GetDurationOfVideoFile(VideoFile => $videofile);
    print Dumper({Res1 => $res1});
    if ($res1->{Success}) {
      my $videoduration = ($res1->{Results} * 1000.0);
      if ($videoduration > $duration) {
	$duration = $videoduration;
      }
    }
  }
  # FIXME Have something judging how long it would take the audio to
  # read and process the visual text on the screen, and have that
  # duration too accounted for.
  print Dumper({Duration => $duration});
  $vars =
    {
     self => $self,
     items => [{
		Content => $current,
		AudioFile => 'file://'.$args{TTS}{Results}{AudioFile},
		Duration => $duration,
		SectionArgs => {
				# 'data-autoslide' => $duration,
			       },
	       }],
    };

  # print Dumper({Vars => $vars});

  $self->MyTemplate->process
    (
     'slide.tt',
     $vars,
     sub {$stub = $_[0];},
    ) || die $self->MyTemplate->error(), "\n";
  my $rendered2 = $stub;
  $stub = '';
  print Dumper({Current => $rendered2});
  $self->CurrentSlide($rendered2);

  return $rendered1;
}

sub GetDurationOfVideoFile {
  my ($self,%args) = @_;
  print Dumper({Args => \%args});
  if (-f $args{VideoFile}) {
    my $qvideofile = shell_quote($args{VideoFile});
    my $command = "exiftool $qvideofile | grep -E '^Duration'";
    print $command."\n";
    my $text = `$command`;
    chomp $text;
    print $text."\n";
    my $duration;
    if ($text =~ /([0-9]+):([0-9]+):([0-9]+)/) {
      $duration = $1 * 3600.0 + $2 * 60.0 + $3;
    } elsif ($text =~ /([0-9\.]+)/) {
      $duration = $1;
    }
    return
      {
       Success => 1,
       Results => $duration,
      };
  } else {
    return
      {
       Success => 0,
      };
  }
}


1;

