package PresGen::Mod::Highlighter;

use PerlLib::SwissArmyKnife;

use Regexp::Common qw(URI);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

our $startisquotes = 0;

sub init {
  my ($self,%args) = @_;
}

sub HighlightPlainText {
  my ($self,%args) = @_;
  my $quotationcount = 0;
  my $bulletpoints = $args{BulletPoints};
  foreach my $text (@$bulletpoints) {
    foreach my $letter (split //, $text) {
      if ($letter eq '"') {
	++$quotationcount;
      }
    }
  }
  print Dumper({BulletPoints => $bulletpoints});
  print "<quotationcount:$quotationcount>\n";
  print "<startisquotes:$startisquotes>\n";
  if (!($quotationcount % 2)) {
    # there are an even number of quotes
    if ($startisquotes) {
      $startisquotes = 1;
      $bulletpoints->[0] = '"...'.$bulletpoints->[0];
      $bulletpoints->[-1] = $bulletpoints->[-1].'..."';
    } else {
      $startisquotes = 0;
    }
  } else {
    # there are an odd number of quotes
    if ($startisquotes) {
      $bulletpoints->[0] = '"...'.$bulletpoints->[0];
      $startisquotes = 0;
    } else {
      $bulletpoints->[-1] = $bulletpoints->[-1].'..."';
      $startisquotes = 1;
    }
  }

  my @points1;
  foreach my $bulletpoint (@$bulletpoints) {
    push @points1, $self->HTMLFilter(Text => $bulletpoint);
  }
  print Dumper({Points1 => \@points1});

  my $t = join("\nFDJldfjkd9fs\n",@points1);

  # do headings
  $t =~ s|^([A-Z\s\?]+)$|<h2>$1</h2>|smg;

  # do images
  my $scheme1 = qr/(f|ht)tps?/;

  my @matches1 = $t =~ /(.*?)($RE{URI}{HTTP}{-scheme => $scheme1}\.(jpe?g|gif|pn[mg]))(.*?)/sg;
  print Dumper({Matches1 => \@matches1});
  my @matches2 = $t =~ /(.*?)($RE{URI}{file}\.(jpe?g|gif|pn[mg]))(.*?)/sg;
  print Dumper({Matches2 => \@matches2});
  $t =~ s/($RE{URI}{HTTP}{-scheme => $scheme1}\.(jpe?g|gif|pn[mg]))/<img src="$1">/isg;
  $t =~ s/($RE{URI}{file}\.(jpe?g|gif|pn[mg]))/<img src="$1">/isg;

  # /var/lib/myfrdcsa/codebases/minor/presentation-generator/data-git/templates/slide.tt

  # <section data-autoslide="120000">
  #   <video data-autoplay src="file:///var/lib/myfrdcsa/codebases/minor/flp-videos/data-git/flp-videos/flp-video-3/slides/dummy/video/DCS_AH64D.webm" type="video/webm">Your browser does not support the HTML5 Video element.</video>
  # </section>

  # <video data-autoplay src="http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"></video>)

  # do videos
  $t =~ s/($RE{URI}{HTTP}{-scheme => $scheme1}\.(mkv|webm|flv|vob|ogg|ogv|drc|gifv|mng|avi|mov|qt|wmv|yuv|rm|rmvb|asf|amv|mp4|m4v|svi|3gp|flv|f4v|mv))/<video data-autoplay src="$1">Your browser does not support the HTML5 Video element.<\/video>/isg;
  $t =~ s/($RE{URI}{file}\.(mkv|webm|flv|vob|ogg|ogv|drc|gifv|mng|avi|mov|qt|wmv|yuv|rm|rmvb|asf|amv|mp4|m4v|svi|3gp|flv|f4v|mv))/<video data-autoplay src="$1">Your browser does not support the HTML5 Video element.<\/video>/isg;

  # do pdfs

  $t =~ s/($RE{URI}{HTTP}{-scheme => $scheme1}\.(pdf|txt))/<iframe src="$1" width="100%" height="500px"><\/iframe>/isg;
  $t =~ s/($RE{URI}{file}\.(pdf|txt))/<iframe src="$1" width="100%" height="500px"><\/iframe>/isg;

  if ($t !~ /<(video|img|iframe)/) {

    # do URLs
    my $scheme1 = qr/(f|ht)tps?/;
    $t =~ s/($RE{URI}{HTTP}{-scheme => $scheme1})/<a href="$1">$1<\/a>/sg;

    # do IRC entries
    $t =~ s|([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})|<span style="font-size:32px"><em>$1</em></span>|sg;


    # do quotations
    $t =~ s|&quot;(.*?)&quot;|<blockquote class="quote" cite=""><em>&ldquo;$1&rdquo;</em></blockquote>|smg;

    # highlight names, have to fix this so it doesn't touch URIs
    $t =~ s/(dmiles|(Doug(las)? Miles))/<span class="author">$1<\/span>/ismg;
    $t =~ s/(aindilis)/<span class="author">$1<\/span>/ismg;

    $t =~ s/((Doug(las)?)( [^L]\w+))/<span class="author">$2<\/span> $4/ismg;
    $t =~ s/((And(rew|y))( Dougherty)?)/<span class="author">$1<\/span>/ismg;

    $t =~ s/(CYC|LOGICMOO)/<span class="named-entity">$1<\/span>/smg;
    $t =~ s/(FLP|FRDCSA|FREE LIFE PLANNER)/<span class="named-entity">$1<\/span>/ismg;

    $t =~ s|(<blockquote.*?)\nFDJldfjkd9fs\n(.*?</blockquote>)|$1 $2|sg;
  }

  my $retval = [split /\nFDJldfjkd9fs\n/, $t];
  print Dumper({Retval => $retval});
  return $retval;
}

sub HTMLFilter {
  my ($self,%args) = @_;
  my $t = $args{Text};
  if ($t =~ /<code>?(.*?)<\/code>/s) {
    my $codesnippet = $1;
    # detect language
    my $language;
    if ($codesnippet =~ /:-/) {
      $language = 'prolog';
    } else {
      $language = 'lisp';
    }
    # "3-5|8-10|13-15"
    # ( class="ruby")?
    $t =~ s/<code ?/<pre class="stretch"><code data-language="$language" data-line-numbers="1-10" data-trim data-noescape /sg;
    $t =~ s/<\/code>/<\/code><\/pre>/sg;
  } elsif ($t =~ /<(pre|math)>?(.*?)<\/(pre|math)>/s) {

  } else {
    $t =~ s/&/&amp;/sg;
    $t =~ s/</&lt;/sg;
    $t =~ s/>/&gt;/sg;
    $t =~ s/"/&quot;/sg;
  }
  return $t;
}

1;
