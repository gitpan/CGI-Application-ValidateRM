package CGI::Application::ValidateRM;
use HTML::FillInForm;
use Data::FormValidator 2.05;
use CGI::Carp;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	validate_rm	
);

$VERSION = '1.00';

sub validate_rm {
	my $self = shift;
	my $return_rm  = shift  || die 'validate_rm: missing required input argument';
	croak "Bad argument to validate_rm: '$return_rm' is not an object method" unless $self->can($return_rm); 
	my $profile = shift || die 'validate_rm: missing required input argument';
	$profile->{msgs} || die 'validate_rm: profile must use msgs key';

	my ($valid,$missing,$invalid) =  Data::FormValidator->validate($self->query, $profile);

	# if there are errors, prepare an error page;
	my $err_page;
	if (keys %$missing or keys %$invalid) {
		 my $return_page = $self->$return_rm({ %$missing, %$invalid, err__ => 1 }  );
		 require HTML::FillInForm;
		 my $fif = new HTML::FillInForm;
		 $err_page = $fif->fill(
			 scalarref => \$return_page,
			 fobject => $self->query
		 )
	}
		
	return ($valid,$err_page);
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

CGI::Application::ValidateRM - Help validate CGI::Application run modes using Data::FormValidator

=head1 SYNOPSIS

 use CGI::Application::ValidateRM;

 my ($valid_href, $err_page) 
	= $self->validate_rm('form_display' ,$dfv_profile_href );
  return $err_page if $err_page; 

=head1 DESCRIPTION

CGI::Application::ValidateRM helps to validate web forms when using the
CGI::Application framework and the Data::FormValidator module. 

B<validate_rm> 

This CGI::Application method takes two required arguments , as
follows:

=over 

=item 1. Name of the run mode to return with errors.

The errors will be passed in as a hash reference, which can then be handed to a
templating system for display.  The hash will look like this:  

 {
 	err__	  => 1,
 	err_email => '* Invalid',
 	err_phone => '* Missing',
 }

The first field is just say "We have some errors". You can check for this in
your template system to display a general message at the top of the page.  

The remaining fields should be prepared using Data::FormValidator's
built-in support for returning error messages as a hash reference.   
Returning the errors with a prefix, such as "err_" is recommended. 
To use this prefix and the other defaults, add this to your Data::FormValidator
profile:

msgs => { prefix =>'' },


HTML::Template users may want to pass C<die_on_bad_params=E<gt>0> to the
HTML::Template constructor to prevent the preference of the "err_" tokens from
triggering an error when the errors are I<not> being displayed.

By default the text will be styled bold and red. This default can be overridden
in the Data::FormValidator profile.

=item 2. A hash reference to a Data::FormValidator profile.

You can also put a subroutine call here, as long as the subroutine returns the
a compatible hash reference.

=back

=head1 EXAMPLE

In a CGI::Application module:

 # This is the run mode that will be validated. Notice that it accepts
 # some errors to be passed in, and on to the template system.
 sub form_display {
 	my $self = shift;
 	my $errs = shift;
 
 	my $t = $self->load_tmpl('page.html');
 
 	$t->param($errs) if $errs;
 	return $t->output;
 }
 
 sub form_process {
 	my $self = shift;
 
 	use CGI::Application::ValidateRM;
 	my ($valid_href, $err_page) = $self->validate_rm('form_display', _form_profile() );
 	return $err_page if $err_page; 
 
 	my $t = $self->load_tmpl('success.html');
 	return $t->output;
 }
 
 sub _form_profile {
 	return {
 		required => 'email',
 	};
 }

In page.html:

 <!-- tmpl_if err__ -->
 	<h3>Some fields below are missing or invalid</h3>
 <!-- /tmpl_if -->
 <form>
 	<input type="text" name="email"> <!-- tmpl_var err_email -->
 </form>


=head1 SEE ALSO

L<CGI::Application>, L<Data::FormValidator>, perl(1)

=head1 AUTHOR

Mark Stosberg <mark@stosberg.com>


=head1 LICENSE

Copyright (C) 2003 Mark Stosberg <mark@stosberg.com>

This module is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 1, or (at your option) any later version,

or

b) the "Artistic License" 

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
the GNU General Public License or the Artistic License for more details.

For a copy of the GNU General Public License along with this program; if not,
write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
Boston, MA 02111-1307 USA


=cut

