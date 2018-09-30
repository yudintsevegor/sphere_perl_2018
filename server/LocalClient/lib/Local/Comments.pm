package Comments;

use parent LocalClient::lib::Local::Commands;
use 5.016000;
use strict;
use warnings;
use File::Copy;
use DDP;


sub function_comments {
	
 	my ($self) = @_;
	my $str;
	my $command = $self->{method};
	my $verbose = $self->{verbose};
	
	if ( $command eq 'rmdir' ) {
		
		if ( $verbose == 1) {
			$str = "This command delete a directory. Parameter - the name of the directory.\n ";
		} elsif ( $verbose > 1) {
			$str = "This command delete a directory. Parameter - the name of the directory. Destroying of directory @{$self->{args}}[0] \n";
		}

	} elsif ( $command eq 'cat') {
		
		if ( $verbose == 1 ) {
			$str = "This command get data from file. Parameter - the neme of the file.\n ";
		} elsif ( $verbose > 1) {
			$str = "This command get data from file. Parameter - the name of the file. Getting data from @{$self->{args}}[0] \n"; 
		}

	} elsif ( $command eq 'touch') {
		
		my $full_dir= $self->{dir}.@{ $self->{args} }[0]; 	
		my ($dir) = $full_dir =~ /(.*\/).*/s;
		my ($filename) = $full_dir =~ /([^\/]*)$/s;

		if ( $verbose == 1) {
			$str = "This command make a file. Parameter - the name of the file.\n ";
		} elsif ( $verbose > 1 ) {
			$str = "This command make a file. Parameters - the name of the file and locations of him . Creation of file  $filename in $dir \n";
	 	}

	} elsif ( $command eq 'mkdir') {
		
		if ( $verbose == 1 ) {
			$str = "This command make a directory. Parameter - the name of the directory.\n ";
		} elsif ( $verbose > 1) {
			$str = "This command make a directory. Parameter - the name of the directory. Creation of directory @{$self->{args}}[0] \n"; 
		}

	} elsif ( $command eq 'cp') {
		my $str_1 = "$self->{dir}"."@{ $self->{args}}[0]";
		my $str_2 = "$self->{dir}"."@{ $self->{args}}[1]";
		
		my ($old_dir) = $str_1 =~ /(.*\/).*/s;
		my ($old_file) = $str_1 =~ /\/.*\/(.*)/s;
		
		my ($new_dir) = $str_2 =~ /(.*\/).*/s;
	 	my ($new_file) = $str_2 =~ /\/.*\/(.*)/s; 
		

		if ( $verbose == 1) {
			$str = "This command copy the file. The first parameter - the name of the  file. The second - the name of copied file.\n ";
		} elsif ( $verbose > 1) {
			$str = "This command copy the file. The first parameter - the name of the  file. The second - the name of copied file. Coping '$old_file' from  directory $old_dir to $new_dir the name of the new  file is '$new_file'.\n";
			}
	
	} elsif ( $command eq 'mv' ) {
	
		if ( $verbose == 1 ) {
			$str = "This command rename the file in another directory. The first parameter - the name of the old file. The second paramameter - the name of the new file.\n ";
		}elsif ( $verbose > 1) {
			$str = "This command rename the file. The first parameter - the name of the old file. The second paramameter - the name of the new file. Rename @{$self->{args}}[0] (from directory $self->{dir}) to @{$self->{args}}[1]. \n";
		}
			
	} elsif ( $command eq 'rm' ) {
	
		if ( $verbose == 1) {
			$str = "This command delete the file. Parameter - the name of the  file. \n ";
		} elsif ( $verbose >1 ) {
			$str =  "This command delete the file. Parameter - the name of the  file. Delete @{$self->{args}}[0] from directry $self->{dir}.\n";
		}
	
	} elsif ( $command eq 'ls' ) {
		
		if ( $verbose == 1) {
			 $str =  "This command shows files from directory.\n ";
		} elsif ( $verbose > 1) {
			 $str =  "This command shows files from $self->{dir}. \n";
		}

	} 
}


1;

