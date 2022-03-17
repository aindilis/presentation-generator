package PresGen::Mod::TTSPreprocessor;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

sub PreprocessTTSInput {
  my ($self,%args) = @_;
  my $t = $args{Text};
  return $t;
}

1;
