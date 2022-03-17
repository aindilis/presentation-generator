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

  my $bulletpoint = join("\nFDJldfjkd9fs\n",@$bulletpoints);
  my $t = $self->HTMLFilter(Text => $bulletpoint);

  # do headings
  $t =~ s|^([A-Z\s\?]+)$|<h2>$1</h2>|smg;

  # do URLs
  my $scheme = qr/(f|ht)tps?/;
  $t =~ s/($RE{URI}{HTTP}{-scheme => $scheme})/<a href="$1">$1<\/a>/sg;

  # do IRC entries
  $t =~ s|([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})|<span style="font-size:32px"><em>$1</em></span>|sg;

  # do quotations
  $t =~ s|&quot;(.*?)&quot;|<blockquote cite=""><span style="color:black;"><em>&ldquo;$1&rdquo;</em></span></blockquote>|smg;

  # highlight names
  $t =~ s/(dmiles|Doug(las)?( Miles)?)/<span style="color:green;">$1<\/span>/smg;

  $t =~ s/(CYC|LOGICMOO)/<span style="color:yellow;">$1<\/span>/smg;

  $t =~ s|(<blockquote.*?)\nFDJldfjkd9fs\n(.*?</blockquote>)|$1 $2|sg;

  my $retval = [split /\nFDJldfjkd9fs\n/, $t];
  print Dumper({Retval => $retval});
  return $retval;
}

sub HTMLFilter {
  my ($self,%args) = @_;
  my $t = $args{Text};
  $t =~ s/&/&amp;/sg;
  $t =~ s/</&lt;/sg;
  $t =~ s/>/&gt;/sg;
  $t =~ s/"/&quot;/sg;
  return $t;
}

1;
