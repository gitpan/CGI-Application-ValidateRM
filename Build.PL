shift(@ARGV) if $ARGV[0] eq 'Build'; # accomodate with CPAN autoinstall
use Module::Build;

Module::Build->new(
	module_name => 'CGI::Application::ValidateRM',
	license => 'perl',
	requires => {
		'CGI::Application'    => 3.0,
		'Data::FormValidator' => 2.10,
		'HTML::FillInForm'	  => 0,	 
	},
	sign=>1,
)->create_build_script;

