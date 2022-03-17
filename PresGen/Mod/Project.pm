package PresGen::Mod::Project;

use PresGen::Mod::Fracture qw(my_init fract);
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Class Name Directory /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Class($args{Class});
  $self->Name($args{Name});
  $self->Directory($args{Directory});
}

sub GenerateProject {
  my ($self,%args) = @_;
  my $textfile = ConcatDir($self->Directory,'presentation.txt');
  if (-f $textfile) {
    my @results;
    PresGen::Mod::Fracture::my_init({max_lines => 8, max_cpl => 80, max_chars => 400});
    # now we have to process this into a presentation
    my $c = read_file($textfile);
    $c =~ s/___END___.*$//s;
    $c =~ s/##.*$//mg;
    # die Dumper({C => $c});
    my @texts = split /\n---\n/, $c;
    my $toread = '';
    my $readall = 0;
    foreach my $text (@texts) {
      my $toshow = '';
      if ($text =~ /===/s) {
	my @to = split /===/s, $text;
	$toshow = $to[0] || '';
	$toread = $to[1] || '';
	$readall = 0;
      } else {
	$toshow = $text || '';
	$toread = $text || '';
	$readall = 1;
      }
      my @entries = $toshow =~ /(.*?)<(code|pre|math)>(.*?)<\/(code|pre|math)>(.*?)/sg;
      my @fragments;
      if (@entries) {
	while (scalar @entries) {
	  my $start = shift @entries;
	  my $tag1 = shift @entries;
	  my $code = shift @entries;
	  my $tag2 = shift @entries;
	  my $end = shift @entries;
	  # PresGen::Mod::Fracture
	  push @fragments, @{PresGen::Mod::Fracture::fract($start)};
	  push @fragments, '<'.$tag1.'>'.$code.'</'.$tag2.'>';
	  push @fragments, @{PresGen::Mod::Fracture::fract($end)};
	}
      } else {
	push @fragments, @{PresGen::Mod::Fracture::fract($toshow)};
      }
      if ($readall) {
	foreach my $fragment (@fragments) {
	  push @results, {
			  Fragments => [$fragment],
			  ToRead => [$fragment],
			  ReadAll => 1,
			 };
	}
      } else {
	push @results,
	  {
	   Fragments => \@fragments,
	   ToRead => [$toread],
	   ReadAll => 0,
	  };
      }
    }
    return
      {
       Success => 1,
       Results => {
		   Results => \@results,
		  },
      };
  }
}

1;
