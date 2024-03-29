use Module::Build;
my $class = Module::Build->subclass(
     class => 'My::Builder',
     code => q{
        sub ACTION_dist {
            my $self = shift;
            `perldoc -t lib/CGI/Application/ValidateRM>README`;
            $self->SUPER::ACTION_dist;
        }
    },
);


$class->new(
	module_name => 'CGI::Application::ValidateRM',
	license => 'perl',
	requires => {
		'CGI::Application'    => 3.0,
		'Data::FormValidator' => 3.00,
		'HTML::FillInForm'	  => 0,	 
	},
    create_makefile_pl => 'traditional',
	sign=>1,
)->create_build_script;

