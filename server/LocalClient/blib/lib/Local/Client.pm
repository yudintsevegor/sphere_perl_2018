package Client;

use 5.016000;
use strict;
use warnings;
use File::Copy;
use DDP;
#use vars qw($self->{dir} $self->{currentdir} $arg3 $self->{arg2} @arrstd $self->{verbose} $vverbose $self->{arg1}) ;

our $VERSION = '0.01';

sub new {
	my $class = shift;
	my %args = @_;
	my $self = bless \%args, $class;
	#p @_;
	return $self;

}

sub Method {
	my($self) = @_;
		
	if ($self->{symbol} eq "!")
	{
		given( $self->{method} )	{
			when("ls")	{function_loc_ls(@_);}
			when("mv")	{function_loc_mv(@_);}
			when("rm")	{function_loc_rm(@_);}	
			when("exit")	{exit();}
			default		{say "There no commands such '$self->{method}' in current dir., try to:\n exit\n !ls\n !rm\n !mv\n";}

		}	
	}
	else
	{	
		given($self->{method})  {
			when("cp")	{function_cp(@_);}
			when("ls")	{function_ls(@_);}
			when("mv")	{function_mv(@_);}
			when("rm")	{function_rm(@_);}	
			when("exit")	{exit();}
			default		{say "There no commands such '$self->{method}' in current dir., try to:\n exit\n ls\n rm\n mv\n";}
		}
	}
}

sub function_loc_ls {
	my($self) = @_;
	if ( $self->{verbose} == 1  ) 
	{
		print "This command shows files local directory.\n ";
	}
	elsif( $self->{verbose} > 1 ) {
		print "This command shows files from $self->{currentdir}. \n";
	}
	system('ls');

}

sub function_loc_rm {
	my($self) = @_;
	if ( $self->{verbose} == 1 ) 
	{
		print "This command delete the file. Parameter - the name of the  file. \n ";
	}
	elsif( $self->{verbose} > 1 ) {
		print "This command delete the file. Parameter - the name of the  file. Delete $self->{arg1} from directry $self->{currentdir}.\n";
	}
	system("rm","$self->{arg1}");

}
sub function_loc_mv {
	my($self) = @_;
	if ( $self->{verbose} == 1 ) 
	{
		print "This command rename the file in current  directory. The first parameter - the name of the old file. The second paramameter - the name of the new file.\n ";
	}
	elsif( $self->{verbose} > 1 ) {
		print "This command rename the file. The first parameter - the name of the old file. The second paramameter - the name of the new file. Rename $self->{arg1} (from directory $self->{currentdir} to $self->{arg2}. \n";
	}
	system("mv","$self->{arg1}","$self->{arg2}");

}

sub function_cp {
	my($self) = @_;
	if ( $self->{verbose} == 1 ) 
	{
		if ( $self->{arg2} eq "")
		{
			print "This command copy the file. Parameter - the name of the  file.\n ";
		}
		else
		{
			print "This command copy the file. The first parameter - the name of the  file. The second - the name of copied file.\n ";
		}

	}
	elsif( $self->{verbose} > 1)
	{
		if ($self->{arg2} eq "")
		{
			print "This command copy the file. Parameter - the name of the  file. Copy $self->{arg1} from current directory $self->{currentdir} to $self->{dir}, without changing the name of the file.\n";
		}
		else 
		{
			print "This command copy the file. The first parameter - the name of the  file. The second - the name of copied file. Copy $self->{arg1} from current directory $self->{currentdir} to $self->{dir}, whit changing the name of the file to $self->{arg2}.\n";
		}	
	}
	if ($self->{arg2} eq "")
	{
		copy($self->{arg1},"$self->{dir}"."$self->{arg1}") or die "Can't copy $self->{arg1} to $self->{dir}: $!\n" ;
	}
	else
	{
		copy($self->{arg1},"$self->{dir}"."$self->{arg2}") or die "Can't copy $self->{arg1} to $self->{dir} with new name $self->{arg2}: $!\n" ;
	}		 
}

sub function_mv {
	my($self) = @_;
	opendir DIR, "$self->{dir}" or die "ERROR";
	my @arrDIR=readdir(DIR);

	if ($self->{verbose} == 1) 
	{
		print "This command rename the file in  another directory. The first parameter - the name of the old file. The second paramameter - the name of the new file.\n ";
	}
	elsif( $self->{verbose} > 1 ) {
		print "This command rename the file. The first parameter - the name of the old file. The second paramameter - the name of the new file. Rename $self->{arg1} (from directory $self->{dir}) to $self->{arg2}. \n";
	}

	foreach my $fname(@arrDIR)
	{		
		if ($self->{arg1} eq $fname)
		{
			our $nameMV=$fname ;
		}
	}
	chomp our $nameMV;
	rename("$self->{dir}"."$nameMV", "$self->{dir}"."$self->{arg2}" ) or die "There some problems with changing the name of the file $nameMV to new name $self->{arg2}\n" ;
	closedir(DIR);         
}
sub function_ls {
	my($self) = @_;
	p $self;
	opendir DIR, $self->{dir} or die "ERROR! Something went wrong!";
	if ($self->{arg1} ne "")
	{
		opendir DIR, "$self->{dir}"."$self->{arg1}" or die "ERROR! Something went wrong!";
	}
	if ($self->{verbose} == 1) 
	{
		print "This command shows files from directory.\n ";
	}
	elsif($self->{verbose} > "1") {
		print "This command shows files from $self->{dir}. \n";
	}

	while (my $fname = readdir DIR)
	{
		next if $fname=~/^\.\.?$/;
		print "$fname  ";
	}
	print "\n";
	closedir(DIR);              
}
sub function_rm {
	my($self) = @_;
	opendir DIR, "$self->{dir}" or die "ERROR! Something went wrong!";
	my @arrDIR=readdir(DIR);
	if ( $self->{verbose} == 1 ) 
	{
		print "This command delete the file. Parameter - the name of the  file. \n ";
	}
	elsif( $self->{verbose} > 1 ) {
		print "This command delete the file. Parameter - the name of the  file. Delete $self->{arg1} from directry $self->{dir}.\n";
	}

	foreach my $fname(@arrDIR)
	{
		if ($fname eq $self->{arg1} )
		{
			our $nameRM=$fname;
		}
	}
	chomp our $nameRM;
	unlink ("$self->{dir}"."$nameRM") or die "ERROR! Some problem(-s) with deleting of $nameRM.\n" ;
	closedir(DIR);   

}

1;

