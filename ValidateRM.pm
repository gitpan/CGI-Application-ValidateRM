package CGI::Application::ValidateRM;
use HTML::FillInForm;
use Data::FormValidator;
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
$VERSION = '0.02';


# Preloaded methods go here.

sub validate_rm {
	my $self = shift;
	my $return_rm  = shift  || die 'validate_rm: missing required input argument';
	my $profile = shift || die 'validate_rm: missing required input argument';

	require Data::FormValidator;
	my $v = new Data::FormValidator({ profile => $profile });
	my ($valid,$missing,$invalid) =  $v->validate($self->query, 'profile');

	# if there are errors, prepare an error page;
	my $err_page;
	if (@$missing or @$invalid) {
		 croak "Bad argument to validate_rm: '$return_rm' is not an object method" unless $self->can($return_rm);                                                                                                            
		 my %opt;
		 if (ref $self->param('vrm') eq 'HASH') {
		 	my $opt_ref = $self->param('vrm');
			%opt = %$opt_ref;
		 }

		 my %defaults = (
			 error_fmt => '<span style="color:red;font-weight:bold"><span id="vrm_errors">* %s</span></span>',
			 missing   => 'Missing',
			 invalid   => 'Invalid',
		 );
		 %opt = ( %defaults, %opt );

		 my $return_page = $self->$return_rm(error_marks($missing, $invalid,undef,\%opt));

		 require HTML::FillInForm;
		 my $fif = new HTML::FillInForm;
		 $err_page = $fif->fill(
			 scalarref => \$return_page,
			 fobject => $self->query
		 )
	}
		
	return ($valid,$err_page);
}

# This will eventually support Data::FormValidators
# ability to have multiple constraints on a single field
sub error_marks {
	my ($missing, $invalid, $msgs, $opt) = @_;

  # set one field just to say "we have some errors"
  my $err_h;
  $err_h = { 'err__' => 1 } if @$missing or @$invalid;

	foreach my $err (@$missing) {
		$msgs->{$err} ||= $opt->{missing};
		$err_h->{'err_'.$err} = sprintf $opt->{error_fmt}, $msgs->{$err};
	}
	foreach my $err (@$invalid) {
		$msgs->{$err} ||= $opt->{invalid};
		$err_h->{'err_'.$err} = sprintf $opt->{error_fmt}, $msgs->{$err};
	}
	return $err_h;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

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

This CGI::Application method takes two required and one optional argument, as
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
your template system to display a general message at the top of the page.  The
remaining fields will have "err_" prepended to name of the offending field.

HTML::Template users may want to pass C<die_on_bad_params=E<gt>0> to the
HTML::Template constructor to prevent the preference of the "err_" tokens from
triggering an error when the errors are I<not> being displayed.

By default the text will be styled bold and red. This default can be overridden
using the parameterse in the third argument.

=item 2. A hash reference to a Data::FormValidator profile.

You can also put a subroutine call here, as long as the subroutine returns the
right hash reference.

=item 3. A hash reference of options to override the default text and formatting.

The defaults are as follows:

 {
   error_fmt => 
    '<span style="color:red;font-weight:bold"><span id="vrm_errors">%s</span></span>',
   missing   => 'Missing',
   invalid   => 'Invalid',
 }

You can see that the error format first styles the text red and bold, which can
be overridden with a style sheet by applying a style to C<vrm_errors>.

To alleviate the need for passing in your own preferences here everytime, the
function will check the contents of the C<vrm> CGI::Application parameter,
If it contains a hash reference with appropriate keys, it will be tried first.

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


=head1 KNOWN BUGS

Currently Data::FormValidator's ability to apply multiple constraints to a
single field is not supported.

There's probably a better way to handle the internationalization of the
strings.

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

