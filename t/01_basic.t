use Test::More tests => 7;
BEGIN { use_ok('CGI::Application::ValidateRM') };

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

my $t2_obj = TestApp1->new(QUERY=>CGI->new("email=broken;rm=form_display_with_ref"));
my $t2_output = $t2_obj->run();

like($t2_output, qr/Some fields below/, 'err__');

like($t2_output, qr/name="email".*Invalid/, 'basic invalid');

like($t2_output,qr/name="phone".*Missing/, 'basic missing');


