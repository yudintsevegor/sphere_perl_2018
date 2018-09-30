package LocalCommands;

use parent LocalClient::lib::Local::Client;
use 5.016000;
use strict;
use warnings;
use File::Copy;
use DDP;


sub function_loc_ls {
	my($self) = @_ ;
	if ( $self->{verbose} == 1  ) 
	{
		print "This command shows files local directory.\n ";
	}
	elsif( $self->{verbose} > 1 ) {
		print "This command shows files from $self->{currentdir}. \n";
	}
	if ( @{ $self->{args}}[0] ne "") {
		foreach my $a ( @{ $self->{args}} ) {	
			my ($minidir) = $a =~ /(.*\/).*/;
			my $glob_dir = $self->{currentdir}.$minidir;
			my @files = glob("$glob_dir*");
			my $grep_dir = $self->{currentdir}.$a;
			#if (my $check = grep(/$grep_dir/ , @files) ) {
				my $directory = $self->{currentdir}.$a;
				say 
				system("ls $directory");
			#}
			#else {say "Something WENT WRONG for $grep_dir";}
		}
	}
	else {
		system('ls');
	}

}

sub function_loc_rm {
	my($self) = @_;
	if ( $self->{verbose} == 1 ) 
	{
		print "This command delete the file. Parameter - the name of the  file. \n ";
	}
	elsif( $self->{verbose} > 1 ) {
		print "This command delete the file. Parameter - the name of the  file. Delete @{ $self->{args} }[0] from directry $self->{currentdir}.\n";
	}
	my $glob_dir = $self->{currentdir}."/";	
	my @files = glob("$glob_dir*");
	foreach my $target ( @{ $self->{args}} ) {
		if (my $check = grep(/$target/ ,@files) ) {
			system("rm","$target");
		}
		else {say "SMTH WENT WRONG";};
	}

}
sub function_loc_mv {
	my($self) = @_;
	if ( $self->{verbose} == 1 ) 
	{
		print "This command rename the file in current  directory. The first parameter - the name of the old file. The second paramameter - the name of the new file.\n ";
	}
	elsif( $self->{verbose} > 1 ) {
		print "This command rename the file. The first parameter - the name of the old file. The second paramameter - the name of the new file. Rename @{ $self->{arg} }[0] (from directory $self->{currentdir} to @{ $self->{args} }[1]. \n";
	}
	system("mv","@{ $self->{args} }[0]","@{ $self->{args} }[1]");

}

1;

