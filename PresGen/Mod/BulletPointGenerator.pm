package PresGen::Mod::BulletPointGenerator;

use PresGen::Mod::Highlighter;

use PerlLib::SwissArmyKnife;

use Lingua::EN::Sentence qw(get_sentences);

use Template;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTemplate MyHighlighter /

  ];

my $stub = '';

sub init {
  my ($self,%args) = @_;
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
  $self->MyHighlighter
    (PresGen::Mod::Highlighter->new
     ());
}

sub GenerateBulletPoints {
  my ($self,%args) = @_;

  # in the future, use GPT-3, for now, just extract sentences, and add
  # to bullet points.

  my @bulletpoints;
  foreach my $tmp (split /[\n\r]{2,}/, $args{Text}) {
    if ($tmp =~ /^<(code|pre|math)>/) {
      push @bulletpoints, $tmp;
    } else {
      my $sentences = get_sentences($tmp);
      foreach my $sentence (@$sentences) {
	$sentence =~ s/[\n\r\s]+/ /sg;
	push @bulletpoints, $sentence;
      }
    }
  }
  return
    $self->RenderBulletPoints
    (
     BulletPoints => $self->MyHighlighter->HighlightPlainText(BulletPoints => \@bulletpoints),
    );
}

sub RenderBulletPoints {
  my ($self,%args) = @_;
  my $vars =
    {
     self => $self,
     bulletpoints => $args{BulletPoints},
    };
  $self->MyTemplate->process
    (
     'bulletpoints.tt',
     $vars,
     sub {$stub = $_[0];},
    ) || die $self->MyTemplate->error(), "\n";
  my $rendered = $stub;
  $stub = '';
  return $rendered;
}

1;
