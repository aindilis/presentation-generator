package PresGen::Mod::Presentation;

use Template;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTemplate /

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
}

sub GeneratePresentation {
  my ($self,%args) = @_;
  my $vars =
    {
     self => $self,
     slides => $args{Slides},
    };
  print Dumper($args{Slides}) if $UNIVERSAL::debug;
  $self->MyTemplate->process
    (
     'presentation-kottans.tt',
     $vars,
     sub {$stub = $_[0];},
    ) || die $self->MyTemplate->error(), "\n";
  my $rendered = $stub;
  $stub = '';
  return $rendered;
}

1;
