package Commands;

use parent LocalClient::lib::Local::Client;
use LocalClient::lib::Local::Comments;
use 5.016000;
use strict;
use warnings;
use File::Copy;
use DDP;
binmode(STDOUT, ':utf8');



sub function_check {
	my($self) = @_;
	say "CHECK".
	p $self->{args};
	my $dir = $self->{dir}.@{ $self->{args}}[0];
	#my $dir = @{ $self->{args}}[0];
	my ($no_file) = $dir =~ /(.*\/).*/s;
	my @files =  glob(qq{"$no_file*"});
	say "FILES in CHECK: ";
	p @files;
	say "DIR: ".$dir;
	if (my $check = grep(/$dir/, @files) ) {
		my $result = "exist";
		return $result;
	} 
	else {
		my $result = "error";
		return $result;
	}
}
sub function_rmdir {
	my($self) = @_;
	my @answer;
	print $self->Comments::function_comments;
	my $ans = $self->Comments::function_comments;
	my $object = $self->{dir}.@{$self->{args}}[0];
	my $result = function_check(@_);
	say "RESULT: ".$result; 
	if ($result eq "exist") {
		my $expr = !( rmdir("$object") );
		while ( $expr ) {
			my @files = glob(qq{"$object/*"});
			foreach (@files) {say "FILES: ".$_;}
			foreach (@files) {
				if ( unlink("$_") ) {
					if ( !(grep(/^$ans$/, @answer))) {
						push @answer, $ans;
					}
					my $str = "It's OK FOR ".$_."\t File was destroyed.";
					say $str;
					push @answer, $str;
				}
				else {
					my ($no_dir) = $_ =~ /$self->{dir}(.+)/s;
					$self->{args} = [$no_dir];
					p $self; 
					function_rmdir(@_);
				 }
			}
			$expr = !(rmdir("$object"));
		} 
	
	}
	elsif ($result eq "error") {
		my $str = "Directory ".@{ $self->{args}}[0]." doesn't exist!";
		say $str;
		push @answer, $str;
	}
	return @answer;
}

sub function_cat {
	my($self) = @_;
	my @answer;
	print $self->Comments::function_comments;  
	my $dir =  $self->{dir}.@{ $self->{args}}[0];
	my $result = function_check(@_);
	say "RESULT: ".$result; 
	if ($result eq "exist") {
		my $f;
		if ( open($f, '<', "$dir") ) {
			push @answer, $self->Comments::function_comments; 
		} else  {
			push @answer, $!;
			warn $!;
		}
		sysread($f, my $data, 4096);
		close($f) or warn $!;
		push @answer, $!; 
		print $data;
	 	push @answer, $data;	
	}
	elsif ($result eq "error") {
		my $str = "File ".@{ $self->{args}}[0]." doesn't exist!";
		say $str;
		push @answer, $str;
	}
	return @answer;
}


sub function_touch {
	say "TOUCH";
	my($self) = @_;
	my @answer;
	print $self->Comments::function_comments;  
	my $full_dir= $self->{dir}.@{ $self->{args} }[0]; 	
	my ($no_file) = $full_dir =~ /(.*\/).*/s;
	my @check = glob("$no_file*");
	if ( grep(/$full_dir/, @check)) {
		say "The name of the file have already used.";
	} 
	else {
		my $f;
		if ( open( $f, '>', $full_dir) ) {	
			push @answer, $self->Comments::function_comments; 
		} else {
			push @answer, $!; 
			 warn $!;
		}
		close($f) or warn $!;
		push @answer, $!;
	}
	return @answer;
}

sub function_mkdir {
	my($self) = @_;
	my @answer;
	print $self->Comments::function_comments;  
	my (@path) = @{ $self->{args} }[0] =~ /\/([^\/.*]+)/g;
	#my (@path) = @{ $self->{args} }[0] =~ /\/([\w+|\s+])/g;
	my $tmp_dir = $self->{dir};	
	foreach (@path) {
		say "PATH: ".$_;
		my $directory = "$tmp_dir"."$_"."/";
		$self->{args} = [$_];
		$self->{dir} = $tmp_dir;
		my $result = function_check(@_);
		if ($result eq "exist") {
			my $str =  $tmp_dir."have already existed.";
			say $str;
			push @answer, $str;
			$tmp_dir = $directory;
		}
		else {
			my $ans = $self->Comments::function_comments; 
			if ( !(grep( /^$ans$/,@answer )) ) {
				push @answer, $ans;	
			}
			if (mkdir $directory ){ 
			} else {
				push @answer, $!;
				warn $!;
			}
			$tmp_dir = $directory;
		}

	}
	print "RESULT: ".$tmp_dir;
	return @answer;
}


sub function_cp {
	my($self) = @_;
	my @answer;	
	print $self->Comments::function_comments;
	my $result = function_check(@_);
	if ($result eq 'exist' ){  
		if ( copy($self->{dir}.@{$self->{args}}[0],$self->{dir}.@{$self->{args}}[1]) ){
			push @answer, $self->Comments::function_comments; 
		} else {  
			warn $!;
		}
	} elsif ( $result eq "error") {
		my $str =  "FILE ".@{ $self->{args}}[0]." doesn't exist! You can't to copy him";
		say $str;
		push @answer, $str;
	}
	return @answer;

}

sub function_mv {
	my($self) = @_;
	my @answer;
	print $self->Comments::function_comments;  
	my $result = function_check(@_);
	say "RESULT: ".$result; 
	if ($result eq "exist") {
		if ( rename("$self->{dir}"."@{$self->{args}}[0]", "$self->{dir}"."@{$self->{args}}[1]" ) ) {
			push @answer, $self->Comments::function_comments; 
		} else {
			push @answer, $!;
			warn $!;
		}
	} elsif ($result eq "error") {
		my $str = "FILE ".@{ $self->{args}}[0]." doesn't exist! You can't to rename him";
		say $str;
		push @answer, $str;
	}
	return @answer;

}

sub function_ls {
	my($self) = @_;
	my @answer;
	p  $self;
	opendir DIR, $self->{dir} or die $!;
	print $self->Comments::function_comments;
 	my $arg = @{ $self->{args} }[0] || "";  
	if ( $arg ne "")
	{   
		foreach my $a ( @{ $self->{args} } ) {
			my ($reg) = $a =~ /(.*\/).*/s; #Нужно что-то сделать с ковычками при пробелах
			my $minidir = $reg || "";
			my ($file) = $a =~ /$minidir(.*)/s;
			my $glob_dir = $self->{dir}.$minidir;
			my @files = glob("$glob_dir*");
			my $grep_dir = $self->{dir}.$a;
			#foreach (@files) {say $_."MMM"};
			if ( my $check = grep(/^$grep_dir$/ ,@files) ) {
				if (-d "$self->{dir}"."$a" ) {
					if ( opendir DIR, "$self->{dir}"."$a" ) {
						print "Directory $self->{dir}"."$a :"."\n";
						push @answer, $self->Comments::function_comments;
						push @answer,  "Directory $self->{dir}"."$a :"."\n"; 
						while (my $fname = readdir DIR) {	
							next if $fname=~/^\.\.?$/;
							print "$fname  ";
							push @answer, $fname;
						}
						print "\n\n";
						closedir(DIR);
					} else {
					 	push @answer, $!;
						warn $!;
					}
				} else {
					my $ans =  $self->Comments::function_comments;
					if ( !( grep(/^$ans$/,@answer) )) {
						push @answer, $self->Comments::function_comments;
					}
					my $dir = "Directory: "."$self->{dir}"."$minidir :";
					if ( !(grep( /^$dir$/, @answer)) ){
						print $dir;
						push @answer, $dir;
					}
					print $file;
					push @answer, $file;
				} 
			} else { 
				my $str =  "Something went WRONG for $grep_dir!";
				say $str;
				push @answer, $str;
			 };
		}
	}
	else {
			
		push @answer, $self->Comments::function_comments;
		while (my $fname = readdir DIR) {	
			next if $fname=~/^\.\.?$/;
			print "$fname  ";
			push @answer, $fname;
		}
		print "\n";
		closedir(DIR);
	}

	return @answer;
 
}

sub function_rm {
	my($self) = @_;
	my @answer;
	print $self->Comments::function_comments;  
	my $result = function_check(@_);
	say "RESULT: ".$result; 
	if ($result eq "exist") {
		if ( unlink ("$self->{dir}"."@{ $self->{args}}[0]") ) {
			push @answer, $self->Comments::function_comments; 
		} else {
			push @answer, $!;
			warn $!;
		}
	}
	elsif ($result eq "error") {
		my $str = "FILE ".@{ $self->{args}}[0]." doesn't exist!";
		say $str;
		push @answer, $str;
	}
	return @answer;
}

1;
