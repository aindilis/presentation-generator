#!/usr/bin/env perl

use UniLang::Agent::Agent;
use UniLang::Util::Message;

use Data::Dumper;

$UNIVERSAL::agent = UniLang::Agent::Agent->new
  (Name => 'TestIEM2ValStep',
   ReceiveHandler => \&Receive);

$UNIVERSAL::agent->DoNotDaemonize(1);
$UNIVERSAL::agent->Register
  (
   Host => 'localhost',
   Port => '9000',
  );

# plan-cycle
my $response = $UNIVERSAL::agent->QueryAgent
  (
   Receiver => 'Verber',
   Data => {
	    Command => 'plan',

	    Name => 'video/2/generation',

	    'Timing' =>
	    {
	     StartDateString => '2021-03-12_00:00:00',
	     EndDateString => '2021-03-12_23:59:59',
	     Units => '0000-00-00_01:00:00',
	    },

	    # Planners => ['OPTIC_CLP'],
	    # Name => 'finance/current/tsimpleopticclp20170723',

	    Context => undef,
	    Goals => [['played', 'vc1']],

	    IEM => 2,
	    IEMConfiguration => 16,
	   },
  );
# print Dumper($response);

# we will want to take the world, and send it on to the IEM if it is
# valid
$UNIVERSAL::agent->SendContents
  (
   Receiver => 'IEM2',
   Data => {
	    World => $response->Data->{World},
	    Domain => $response->Data->{Domain},
	    Problem => $response->Data->{Problem},
	    # Extra => {
	    # 		EntryMap => $self->EntryMap,
	    # 		Context => $self->Context,
	    # 	       },
	   },
  );


# (video-transitioned vt2-3)
#    (video-transitioned vt1-2)
#    (played vc3)
#    (played vc5)
#    (played vc4)
#    (video-transitioned vt4-5)
#    (video-transitioned vt3-4)
#    (played vc1)
#    (played vc2)
