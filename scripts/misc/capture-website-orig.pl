#!/usr/bin/env perl

system 'killall Xvfb';
system 'xvfb-run --server-args="-screen 0 1920x1080x24" google-chrome --start-fullscreen --window-size=1920,1080 --window-position=0,0 file:///home/vagrant/index.html &';
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
  system "DISPLAY=:99 XAUTHORITY='$xauth' scrot";
  system"XAUTHORITY='$xauth' ffmpeg -video_size 1920x1080 -draw_mouse 0 -framerate 60 -f x11grab -i :99+0,0  -c:v libx264 -crf 18 -preset ultrafast recording.mkv -y &";
}
sleep 60;
system 'killall ffmpeg';
system 'killall Xvfb';

# ffmpeg -i recording.mkv -c:v libvpx -qmin 0 -crf 5 -b:v 1M -c:a libvorbis recording.webm
