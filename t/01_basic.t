use Test::More tests => 4;
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


