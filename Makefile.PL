use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'CGI::Application::ValidateRM',
    'VERSION_FROM' => 'ValidateRM.pm', # finds $VERSION
	'PREREQ_PM' => {
		'CGI::Application'    => 3.0,
		'Data::FormValidator' => 2.0,
		'HTML::FillInForm'	  => 0,	 
	},   # Packages used by CGI::Application::ValidateRM
	($] ge '5.005') ? (
		'AUTHOR' => 'Mark Stosberg <mark@summersault.com>',
		'ABSTRACT' => 'Help validate CGI::Application run modes using Data::FormValidator',
	) : (),   # For ActivePerl PPM
);
