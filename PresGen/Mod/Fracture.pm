package PresGen::Mod::Fracture;

@EXPORT_OK = qw(my_init fract);

use Text::Fracture;

sub my_init {
  Text::Fracture::init($_[0]);
}

sub fract {
  ExtractText
    (
     Text => $_[0],
     Fractures => Text::Fracture::fract($_[0]),
    );
}

sub ExtractText {
  my (%args) = @_;
  my @res;
  foreach my $entry (@{$args{Fractures}}) {
    my $t = substr($args{Text},$entry->[0],$entry->[1]);
    push @res, $t;
  }
  return \@res;
}

1;
