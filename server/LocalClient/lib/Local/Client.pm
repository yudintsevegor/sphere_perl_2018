package Client;

use 5.016000;
use strict;
use warnings;
use File::Copy;
use DDP;
use LocalClient::lib::Local::Commands;
use LocalClient::lib::Local::Regexp;
	
our $VERSION = '0.01';

sub new {
	my $class = shift;
	my %args = @_;
	my $self = bless \%args, $class;
	return $self;

}

sub Method {
	my($self) = @_;
	say "METHOD";
	p $self;
	$self->Regexp::parsing;
	my @answer;
		given($self->{method})  {
			when("touch")	{@answer = $self->Commands::function_touch;}
			when("rmdir")	{@answer = $self->Commands::function_rmdir;}
			when("mkdir")	{@answer = $self->Commands::function_mkdir;}
			when("cat")	{@answer = $self->Commands::function_cat;}
	
			when("cp")	{@answer = $self->Commands::function_cp;}
			when("ls")	{@answer = $self->Commands::function_ls;}
			when("mv")	{@answer = $self->Commands::function_mv;}
			when("rm")	{@answer = $self->Commands::function_rm;}	
			when("exit")	{exit();}
			default		{say "There is no command such '$self->{method}', try to:\n exit\n ls\n rm\n mv\n mkdir\n rmdir\n touch\n cat\n";}
		}

}

1;

