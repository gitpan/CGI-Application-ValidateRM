use Test::More tests => 7;
BEGIN { use_ok('CGI::Application::ValidateRM') };

use CGI::Application::ValidateRM;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use lib './t';
use strict;

$ENV{CGI_APP_RETURN_ONLY} = 1;

use CGI;
use TestApp1;
my $t1_obj = TestApp1->new(QUERY=>CGI->new("email=broken"));
my $t1_output = $t1_obj->run();

like($t1_output, qr/Some fields below/, 'err__');

like($t1_output, qr/name="email".*Invalid/, 'basic invalid');

like($t1_output,qr/name="phone".*Missing/, 'basic missing');


 my $t2_obj    = TestApp1->new(
 	QUERY=>CGI->new("email=broken"),
	params => {
		vrm => {
			error_fmt => 'Test-Error-Fmt<b>* %s</b>',
			missing   => 'Test-Missing',
			invalid   => 'Test-Invalid',
		},
	}
 );

 my $t2_output = $t2_obj->run();
 
 like($t2_output, qr/Test-Error-Fmt/, 'over-riding error_fmt');
 like($t2_output, qr/Test-Missing/, 'over-riding missing');
 like($t2_output, qr/Test-Invalid/, 'over-riding invalid');
 

