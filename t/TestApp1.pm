
package TestApp1;

use strict;

use CGI::Application;
@TestApp1::ISA = qw(CGI::Application);

sub setup {
	my $self = shift;

	$self->start_mode('form_display');

	$self->run_modes(qw/
		form_display
		form_process
	/);
}

# This is the run mode that will be validated. Notice that it accepts
# some errors to be passed in, and on to the template system.
sub form_display {
	my $self = shift;
	my $errs = shift;

	my $t = $self->load_tmpl('t/01_display.html',
		die_on_bad_params=>0,
		);

	$t->param($errs) if $errs;
	return $t->output;
}

sub form_process {
	my $self = shift;

	use CGI::Application::ValidateRM;
	my ($results, $err_page) = $self->validate_rm('form_display', '_form_profile' );
	return $err_page if $err_page; 

	return 'success';
}

sub _form_profile {
	return {
		required => [qw/email phone/],
		constraints => {
			email => 'email',
		},
		msgs => { 
			any_errors => 'err__',
			prefix => 'err_',
		},
	};
}


