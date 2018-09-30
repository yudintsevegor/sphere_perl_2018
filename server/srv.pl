#!/usr/bin/env perl

use 5.016;

use AnyEvent;
use AnyEvent::Handle;
use AnyEvent::Socket;
use DDP;
use FindBin;
use lib "$FindBin::Bin/../lib", glob("$FindBin::Bin/../*/lib*"),;
use LocalClient::lib::Local::Client;

my $cv = AE::cv;

my $root = '/home/egor/tmp/exp/';
#my ($host, $port) = $ARGV[1] =~ /\s*(.+):(\d+)\s*/;
my $host = '127.0.0.1';
my $port = '1234';
my $verbose = 0;
my $BUFFSIZE = 2**10;
tcp_server($host, $port,
		sub {
		my $fh = shift or die "Cannot accept client: $!";
		my $hl; $hl = AnyEvent::Handle->new(
			fh       => $fh,
			
			on_error => sub {
				shift;
				my ($fatal, $msg) = @_;
				warn "Error: [$msg]\n";
				$cv->send;
			},

			on_eof => sub {
				warn "Reached EOF\n";
				$hl->destroy();
				$cv->send;
			}

		);
		
		$hl->push_read( 
			line => sub{
				if ($_[1] =~ /^verbose\s+(\d+)/){
					$verbose = $1;
 				}
			}
		);
		
		$hl->push_read(line => \&listener);
		}
);


sub listener {
	my ($h, $line) = @_;
	my @answer_to_client;
	say "CommandLine: ".$line;
	if ( !($line =~ /get|put\.*/s) ) {
		say "Line for storage Commands: ".$line;
		my ($method) = $line=~ /(\w+)\s*/;
		my (@args) = $line =~ /\s([^\'\s]+\'[^\']+\'[^\s]*|[\w+|\/|\?+|\[|\]|\{|\}|\,|\*|\.]+)/g;
		my $object = Client->new(
					method		=>	$method,
					dir		=>	$root, 
					verbose		=>	$verbose,
					args		=>	[@args],
					);
						
		@answer_to_client = $object->Method;
		p @answer_to_client;
		#say "ANSWER: ";
		#say join "\n", @answer_to_client;
		my $data_to_client =  join "\n", @answer_to_client;
		my $size = length ($data_to_client) + 1;
		say "SIZE: ".$size;
		say "DATA: ".$data_to_client;
		$h->push_write("Answer: $size\n");
		$h->push_write("$data_to_client\n");

	} elsif ($line =~ /^put\s+(\d+)\s([^\s]+)/) {
		say $line;
		say $1, " ", $2;
		my ($size, $name) = ($1, $2);
		$name =~ s/.+\/([^\/]+)/$1/;
		my $left = $size;
		say "$root"."$name";
		open(my $fh, '>:raw', "$root"."$name") or $cv->croak("Failed to open file: $!");
		my $body; $body = sub {
			$h->unshift_read(
					chunk => $left > $BUFFSIZE ? $BUFFSIZE : $left, sub {
						my $rd = $_[1];
						$left -= length $rd;
						syswrite($fh, $rd);
						if ($left == 0) {
							undef $body;
							close $fh;
						} else {
							$body->();
						}
					}
			);
		}; $body->();
	}elsif ($line =~ /^get\s+([^\s]+)$/) {
		my $filename = $1;
		say $line;
		say $1;
		say "name of file: $filename\n";
#if (-f "$root".$filename){
	my $size = -s "$root/".$filename;
	say "SIZE: ".$size;
	$h->push_write("get $size $filename\n");

	open(my $fd, '<:raw', "$root".$filename) or $cv->croak("Failed to open file $root/$filename: $!");
	my $file_to_read; $file_to_read = AnyEvent::Handle->new(
			fh => $fd,
			max_read_size => $BUFFSIZE,
			read_size => $BUFFSIZE
			);

	my $left = $size;
	my $do_writting; $do_writting = sub {
		if ($left > 0) {
			$file_to_read->push_read(chunk => $left > $BUFFSIZE ? $BUFFSIZE : $left,
					sub {
					my $name_file_to_send = $_[1];
					$left -= length $name_file_to_send;
					$h->push_write($name_file_to_send);
					if ($h->{wbuf}) {
					$h->on_drain(
						sub {
						$h->on_drain(undef);
						$do_writting->();
						}
						);

					} else {
#successfully send chunk
					$do_writting->();
					}

					}

					);

		} else {
			$file_to_read->destroy();
		}
	}; $do_writting->();
=head1
}elsif(-d "$root".$filename){
# my $size = -s "$root/".$filename;
# print "size\t$size";
	opendir (my $dh,  "$root".$filename) or $cv->croak("Failed to open file $filename: $!");
	my $data;
	my $file_to_read; $file_to_read = AnyEvent::Handle->new(
			fh => $dh,
			max_read_size => $BUFFSIZE,
			read_size => $BUFFSIZE
			);
	$h->push_write("get ".length ($data)." $filename\n");
	my $left = length ($data);
	my $do_writting; $do_writting = sub {
		if ($left > 0) {
			$file_to_read->push_read(chunk => $left > $BUFFSIZE ? $BUFFSIZE : $left,
					sub {
					my $name_file_to_send = $_[1];
					$left -= length $name_file_to_send;
					$h->push_write($name_file_to_send);
					if ($h->{wbuf}) {
					$h->on_drain(
						sub {
						$h->on_drain(undef);
						$do_writting->();
						}
						);

					} else {
#successfully send chunk
					$do_writting->();
					}

					}

					);

		} else {
			$file_to_read->destroy();
		}
	}; $do_writting->();
}else{
	$cv->croak("There is no such file as: $root/$filename");
}
=cut
}else{
	say "unknown command: $line";
}
$h->push_read(line => \&listener);
}

AE::cv->recv;
