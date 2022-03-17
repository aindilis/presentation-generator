#!/usr/bin/env perl

use MyFRDCSA;
use PerlLib::SwissArmyKnife;

use Verber::Ext::PDDL::Problem;
use Verber::Util::DateManip;

use DateTime::Duration;

my $delay = 1;
my $datemanip = Verber::Util::DateManip->new();
my $problem = Verber::Ext::PDDL::Problem->new
  (
   Domain => 'videogeneration',
   Problem => 'videogeneration',
   DateManip => $datemanip,
  );

foreach my $m (1..12) {
  $problem->AddObject
    (
     Type => "video-track",
     Object => "vk$m",
    );
  $problem->AddObject
    (
     Type => "audio-track",
     Object => "ak$m",
    );
}

$problem->StartDate
  ($datemanip->GetPresent());

$problem->Units
  (DateTime::Duration->new(seconds => 1));

my $dir = '/media/andrewdo/SSD2/PresGen/projects/logicmoo-videos/logicmoo-video-1/videos';
my $i = 1;
while (-f ConcatDir($dir,"s$i.png")) {
  ++$i;
}
--$i;

print $i."\n";

my $fps = 60;

foreach my $j (1..$i) {
  my $vtobject1 = "vt$j-$j";
  my $vtobject2 = "vt$j-".($j+1);
  $problem->AddObject
    (
     Type => "video-transition",
     Object => "$vtobject1",
    );
  $problem->AddObject
    (
     Type => "video-transition",
     Object => "$vtobject2",
    );
  my $atobject = "at$j-".($j+1);
  $problem->AddObject
    (
     Type => "audio-transition",
     Object => "$atobject",
    );


  my $imagefile = ConcatDir($dir,"s$j.png");
  my $imageframecount;

  my $audiofile = ConcatDir($dir,"a$j.wav");
  my $audioframecount;
  if (-f $audiofile) {
    my $qaudiofile = shell_quote($audiofile);
    my $text = `exiftool $qaudiofile | grep -E '^Duration'`;
    chomp $text;
    my $duration;
    if ($text =~ /([0-9]+):([0-9]+):([0-9]+)/) {
      $duration = $1 * 3600.0 + $2 * 60.0 + $3;
    } elsif ($text =~ /([0-9\.]+)/) {
      $duration = $1;
    }
    print "<A:$text>\n";
    if ($duration) {
      $audioframecount = ConvertToFrames(Duration => $duration);
      $imageframecount = $audioframecount;
      print $audioframecount."\n";
    } else {
      $audioframecount = 0;
      $imageframecount = 0;
      # die "WTF MY\n";
    }
  } else {
    die "WTF\n";
  }
  my $videoframecount;
  my $videofile = ConcatDir($dir,"s$j-".($j+1).".mp4");
  print "<$videofile>\n";
  if (-f $videofile) {
    my $qvideofile = shell_quote($videofile);
    my $text = `exiftool $qvideofile | grep -E '^Duration'`;
    chomp $text;
    if ($text =~ /([0-9]+):([0-9]+):([0-9]+)/) {
      $duration = $1 * 3600.0 + $2 * 60.0 + $3;
    } elsif ($text =~ /([0-9\.]+)/) {
      $duration = $1;
    }
    print "<V:$text>\n";
    if ($duration) {
      $videoframecount = ConvertToFrames(Duration => $duration);
      print $videoframecount."\n";
    } else {
      die "WTF MY2\n";
    }
  } else {
    die "WTF\n";
  }

  # desired order is ic1 vc1 ic2 vc2 ic3 vc3 ic4 vc4 ic5 vc5
  # (so
  # (depends vc1 ic1)
  # (depends ic2 vc1)
  # (depends vc2 ic2)
  # (depends ic3 vc2)
  # )

  # missing 

  # add the video transition away clip
  $problem->AddObject
    (
     Type => "video-clip",
     Object => "vc$j",
    );

  $problem->AddInit
    (
     Structure =>
     [
      "=",
      [
       "video-clip-duration",
       "vc$j",
      ],
      "$videoframecount",
     ]
    );

  # add the image
  $problem->AddObject
    (
     Type => "video-clip",
     Object => "ic$j",
    );

  $problem->AddInit
    (
     Structure =>
     [
      "=",
      [
       "video-clip-duration",
       "ic$j",
      ],
      "$imageframecount",
     ]
    );


  # add the audio clip
  $problem->AddObject
    (
     Type => "audio-clip",
     Object => "ac$j",
    );

  $problem->AddInit
    (
     Structure =>
     [
      "=",
      [
       "audio-clip-duration",
       "ac$j",
      ],
      "$audioframecount",
     ]
    );


  if ($j != $i) {
    $problem->AddInit
      (
       Structure =>
       [
	"=",
	[
	 "video-transition-duration",
	 "$vtobject1",
	],
	$delay,
       ]
      );
    $problem->AddInit
      (
       Structure =>
       [
	"=",
	[
	 "video-transition-duration",
	 "$vtobject2",
	],
	$delay,
       ]
      );
    $problem->AddInit
      (
       Structure =>
       [
	"video-transition",
	"$vtobject1",
	"ic$j",
	"vc$j",
       ]
      );
    $problem->AddInit
      (
       Structure =>
       [
	"video-transition",
	"$vtobject2",
	"vc$j",
	"ic".($j + 1),
       ]
      );
    $problem->AddGoal
      (
       Structure =>
       [
	"video-transitioned",
	$vtobject1,
       ]
      );
    $problem->AddGoal
      (
       Structure =>
       [
	"video-transitioned",
	$vtobject2,
       ]
      );

    $problem->AddInit
      (
       Structure =>
       [
	"=",
	[
	 "audio-transition-duration",
	 "$atobject",
	],
	$delay,
       ]
      );
    $problem->AddInit
      (
       Structure =>
       [
	"audio-transition",
	"$atobject",
	"ac$j",
	"ac".($j + 1),
       ]
      );
    $problem->AddGoal
      (
       Structure =>
       [
	"audio-transitioned",
	$atobject,
       ]
      );

  }

  if ($j > 1) {
    $problem->AddInit
      (
       Structure =>
       [
	"video-depends",
	"ic$j",
	"vc".($j - 1),
       ]
      );

    $problem->AddInit
      (
       Structure =>
       [
	"video-depends",
	"vc$j",
	"ic$j",
       ]
      );
    $problem->AddInit
      (
       Structure =>
       [
	"audio-depends",
	"ac$j",
	"ac".($j - 1),
       ]
      );
  }
  $problem->AddGoal
    (
     Structure =>
     [
      "played",
      "vc$j",
     ]
    );
  $problem->AddGoal
    (
     Structure =>
     [
      "played",
      "ic$j",
     ]
    );
  $problem->AddGoal
    (
     Structure =>
     [
      "played",
      "ac$j",
     ]
    );

  $problem->AddInit
    (
     Structure =>
     [
      "synchronized",
      "ic$j",
      "ac$j",
     ]
    );


}

$problem->AddInit
  (
   Structure =>
   [
    "video-depends",
    "vc1",
    "ic1",
   ]
  );


$problem->Metric
  ({minimize => ["minimize", ["total-time"]]});

$output = $problem->Generate
  (Output => "verb");
print $output."\n";
WriteFile
  (
   File => '/var/lib/myfrdcsa/codebases/internal/verber/data/worldmodel/templates/video/3/generation.p.verb',
   Contents => $output,
  );
system 'cd /var/lib/myfrdcsa/codebases/internal/verber && ./verber -p LPG -w video/3/generation';
system '/var/lib/myfrdcsa/codebases/minor/presentation-generator/scripts/parse-generated-timeline.pl';
system 'killall kdenlive';
system 'cd ~/ && ./kdenlive-21.04.3b-x86_64.appimage --geometry "1900x1000+0+0" /var/lib/myfrdcsa/codebases/minor/presentation-generator/data-git/verber/generation2.kdenlive &';

sub ConvertToFrames {
  my (%args) = @_;
  return round($args{Duration} * $fps);
}
