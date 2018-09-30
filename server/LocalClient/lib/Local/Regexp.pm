package Regexp;

use parent LocalClient::lib::Local::Client;
use 5.016000;
use strict;
no warnings;
use utf8;
use DDP;
binmode(STDOUT, ':utf8');

sub parsing {
	my($self)=@_;
	say "REGEXP";
	my @o_args = @{$self->{args}};
	#foreach (@o_args) { say "TEST1". $; };
	my @n_args = @o_args;
	my $symbol = $self->{symbol};
	say "SYMBOL: ".$symbol; 
	if ($self->{symbol} eq "0") {
		@n_args = ();
		foreach my $file (@o_args) {
			if ($file =~ /\'/) {
				$file =~ s/\'//g;
			}
		push @n_args, $file;
		}
		#foreach (@n_args) { say "TEST2". $; };
		$self->{args} = [@n_args];
	}
	elsif ($symbol eq "!") {
		say "OOOOPS";
		$self->{args} = [@n_args];
	}
	p $self->{args};
	my $parsing_str = $n_args[0];
	my ($el) = $parsing_str =~ /(\[|\*|\{|\?)/;
	say "ELEMENT: ".$el;	
	given( $el ) {
		when("?")	{say "QUESTIONS";  function_question(@_)};
		when("[")	{say "СКО|БКА"; function_braket(@_)};
		when("*")	{say "STAR"; function_star(@_)};
		when("{")	{say "FIGURE"; function_figure(@_)};
		default		{ return $self; }
	}

}
sub function_question {
	my($self)=@_;
	my @o_args = @{$self->{args}};
	my $parsing_str = $o_args[0];
	my $com;
	if ($self->{symbol} eq "!"){
		$com = $self->{currentdir}.$parsing_str;

	}
	else {
		$com = $self->{dir}.$parsing_str;
	}
	
	my ($left) = $com =~ /([^\?]+)\//;
	my @files = glob("$left/*");
		
	say "FILES IN DIR: ";
	foreach (@files) {
		say $_;
	}
	
	my @num;
	while ($com =~ /(\?)/gc) {
		push @num, pos($com);
	}
	my $num_len = @num;

	my @n_args;
	foreach my $f (@files) {
		if ($self->{symbol} eq "!"){
			$com = $self->{currentdir}.$parsing_str;

		}
		else {
			$com = $self->{dir}.$parsing_str;
		}
	
		my ($loc) = $f =~ /$left(.*)/s;
		my (@el_near_quest) = $com =~ /\?+(\w+)/g;
		my $el = $el_near_quest[0];
		my ($fst) = $f =~ /$left([^\?])$el/;
		unshift @el_near_quest, $fst;
		if ($el_near_quest[0] eq "") {shift @el_near_quest; unshift @el_near_quest, "/";};
		
		my $j = 0;
		my $len =  @el_near_quest;
		our @el_quest;
		while ($j < $len )
		{	
			($el_quest[$j]) = $loc =~ /$el_near_quest[$j](.*)$el_near_quest[$j+1]/s;
			$j++		
		}
		my @ch = ();
		my @sym = split('', $f);
		foreach (@num) {
			push @ch, $sym[$_-1];
		}
		
		my $j = 0;
		while ($j < $num_len) {
			$com =~ s{\?}{@ch[$j]};
			$j++;
		}
		say "END: ".$com;
		if ( my $check = grep(/$com/ ,@files) )  
		{
		my ($file) = $com =~ /$self->{dir}(.*)/;
		push @n_args, $file;
		}
		
	}
	$self->{args} = [@n_args];
	return $self;
}

sub function_figure {
	my($self)=@_;
	my @o_args = @{$self->{args}};

	my $parsing_str = $o_args[0];
	my $com;
	if ($self->{symbol} eq "!"){
		$com = $self->{currentdir}.$parsing_str;

	}
	else {
		$com = $self->{dir}.$parsing_str;
	}
	#say "COMMAND: ".$com;
	my ($left) = $com =~ /(\/.*)\{/;
	#say "LEFT: ".$left;
	my ($right) = $com =~ /\}(.*)/;
	#say "RIGHT: ".$right;
	my ($inter) = $com =~ /\{(.*)\}/;
	#say "INTER: ".$right;
	say "\n";
	my (@str) = $inter =~ /(\w+|\d+)/g;
	my $len = @str;
	my @arr;
	my @n_args;
	foreach my $k (0..$len-1) {
		push @arr, $left.$str[$k].$right;
		say "FILE". $left.$str[$k].$right;
		my ($file) = $arr[$k] =~ /$self->{dir}(.*)/;
		push @n_args, $file; 
	}	
	$self->{args} = [@n_args];
	return $self;
}

sub function_braket {

	my($self)=@_;
	my @o_args = @{$self->{args}};

	my $parsing_str = $o_args[0];
	my $com;
	if ($self->{symbol} eq "!"){
		$com = $self->{currentdir}.$parsing_str;

	}
	else {
		$com = $self->{dir}.$parsing_str;
	}

	my ($left) = $com =~ /(\/.*)\[/;
	my ($inter) = $com =~ /\[(.+)\]/;
	my ($right) = $com =~ /\](.*)/;
	my (@sym) = $inter =~ /(.)/g;

	my $len = @sym;
	my @arr;
	my @n_args;
	foreach my $i (0..$len-1){
		push @arr, $left.$sym[$i].$right;
		my ($file) = $arr[$i] =~ /$self->{dir}(.*)/;
		push @n_args, $file;
	}
	$self->{args} = [@n_args];
	return $self;

}

sub function_star {

	my($self)=@_;
	my @o_args = @{$self->{args}};
	say "SYMBOL: ".$self->{symbol};	
		my $parsing_str = $o_args[0];
		
		my  $com;
		if ($self->{symbol} eq "!"){
			$com = $self->{currentdir}.$parsing_str;
		}
		else {
			$com = $self->{dir}.$parsing_str;
		}
		my @files = glob("$com");
		my @n_args;	
		foreach (@files) {
			my ($file) = $_ =~ /$self->{dir}(.*)/; 
			push @n_args, $file;
		}
		
		foreach (@n_args) {
			say $_;	
		};
		
	$self->{args} = [@n_args];
	return $self;	
}


=head1
sub function_star {

	my($self)=@_;
	my @o_args = @{$self->{args}};
	say "SYMBOL: ".$self->{symbol};	
	my %args = (0 => [@o_args],);
	foreach (0..@o_args-1) {
		my $parsing_str = $o_args[$_];
		
		my  $com;
i		if ($self->{symbol} eq "!"){
			$com = $self->{currentdir}.$parsing_str;
		}
		else {
			$com = $self->{dir}.$parsing_str;
		}
		my @files = glob("$com");
		my @n_args;	
		foreach (@files) {
			my ($file) = $_ =~ /$self->{dir}(.*)/; 
			push @n_args, $file;
		}
		
		foreach (@n_args) {
			say $_;	
		};
		my $k = $_ + 1;
		%args->{ $k } = [@n_args];
		
	}
	$self->{args} = [%args];
	return $self;	
}

=cut

1;
