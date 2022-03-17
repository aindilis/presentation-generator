#!/usr/bin/env perl

use BOSS::Config;
use MyFRDCSA;
use PerlLib::SwissArmyKnife;

$specification = q(
	-c <class>		Project Class
	-p <projectname>	Project Name

	-f <file>		File to render
	-e			The file is not a transition slide but an entire presentation
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

if (! exists $conf->{'-c'}) {
  die "must specify -c\n";
}

if (! exists $conf->{'-p'}) {
  die "must specify -p\n";
}

if (! exists $conf->{'-f'} or ! -f $conf->{'-f'}) {
  die "must specify -f\n";
}

my $projectclass = $conf->{'-c'};
my $projectname = $conf->{'-p'};
my $file = $conf->{'-f'};
my $basename = basename($file);
$basename =~ s/\.html$//sg;
my $videodir = ConcatDir('/media/andrewdo/SSD2/PresGen/projects',$projectclass,$projectname,'videos');
if (! -d $videodir) {
  system 'mkdir -p '.shell_quote($videodir);
}
my $outputfile = ConcatDir($videodir,$basename.'.mp4');
my $screenshotfile = ConcatDir($videodir,$basename.'.png');
$screenshotfile =~ s|\/(s[0-9]+)-[0-9]+\.png|/$1.png|;

system 'killall Xvfb';
system 'xvfb-run --server-args="-screen 0 1920x1080x24" google-chrome --kiosk --start-fullscreen --window-size=1920,1080 --window-position=0,0 file://'.$file.' &';

sleep 1;
my $lines = `ps auxwww | grep Xvfb`;
my $xauth;
foreach my $line (split /\n/, $lines) {
  if ($line =~ /Xvfb :99 /) {
    if ($line =~ /-auth (.*?)$/) {
      $xauth = $1;
      last;
    }
  }
}

print "<$xauth>\n";
if ($xauth) {
  sleep 1;
  system "DISPLAY=:99 XAUTHORITY='$xauth' scrot ".shell_quote($screenshotfile);
  system "XAUTHORITY='$xauth' ffmpeg -video_size 1920x1080 -draw_mouse 0 -framerate 60 -f x11grab -i :99+0,0  -c:v libx264 -crf 18 -preset ultrafast ".shell_quote($outputfile)." -y &";
}
if (! $conf->{'-e'}) {
  sleep 2;
  system 'killall ffmpeg';
  system 'killall Xvfb';
} else {
  GetSignalFromUserToProceed();
  system 'killall ffmpeg';
  system 'killall Xvfb';
}

# ffmpeg -i recording.mkv -c:v libvpx -qmin 0 -crf 5 -b:v 1M -c:a libvorbis recording.webm
