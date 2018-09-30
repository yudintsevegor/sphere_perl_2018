#!/usr/bin/env perl

use 5.016;

use AnyEvent::Socket;
use warnings;
use DDP;
use AnyEvent::Handle;
use AnyEvent::ReadLine::Gnu;
use FindBin;
use lib "$FindBin::Bin/lib",glob("$FindBin::Bin/../libs/*/lib"),;
use Getopt::Long;Getopt::Long::Configure ('bundling');


sub say {
	my $line = "@_";
	$line =~ s{\n*$}{\n};
	AnyEvent::ReadLine::Gnu->print($line);
}

my $verbose = 0;
my $help = 0;

GetOptions(
    "v|verbose+" => \$verbose,
    "h|help"     => \$help,
);

our $help_message = <<'HELP_MESSAGE';
Usage: perl Client.pl host:port
HELP_MESSAGE

if ($help || !@ARGV) {
    say $help_message;
    print
    "This simple program allows you to use the following commands:

    ls          to view files in a directory
    cp          to copy the contents of one file to another
    cat         to view the contents of a file
    rm          to delete file
    mv          to rename file
    q|quit|exit to exit program

    You can also use these flags:

    -h|--help     to show this text
    -v|--verbose  Program will display messages about,
    what actions it performs and with what parameters\n";
    exit(0);
}

my ($host, $port) = $ARGV[0] =~ /^(.+):(\d+)/;
my $dir_to_upload_files = "/home/egor/tmp/exp/";

=head
my $func_to_enter_dir; $func_to_enter_dir = sub {
    say "Entered directory in which You want to upload files:";
    my $stdin = <STDIN>;
    chomp $stdin;
    $dir_to_upload_files = $stdin || "$ENV{HOME}/Downloads";
    if (!(-d $dir_to_upload_files)){
        say "Directory $dir_to_upload_files doesn't exists!";
        $func_to_enter_dir->();
    } else {
        say "Directory to upload: $dir_to_upload_files";
    }
};
$func_to_enter_dir->();
=cut

my $cv = AE::cv;
my $BUFFSIZE = 2**10;
tcp_connect $host, $port, sub {
	my $fh = shift;
	say "Connected to $host:$port";
    my $hl; $hl = AnyEvent::Handle->new(

    	connect => [$host, $port],

    	on_prepare => sub {
    		my $h = shift;
    		warn "Connecting to the host $host on port = $port\n";
    	},

    	on_connect_error => sub {
    		my ($h, $msg) = @_;
    		warn "Error: $msg to the host $host on port $port\n";
    		exit;
    	},

    	on_error => sub {
    		my ($h, $fatal, $msg) = @_;
    		warn "FATAL ERROR! The connection is terminated!";
    		$h->destroy();
    		exit;
    	},

    	on_eof => sub {
    		my $h =shift;
    		warn "Connection was closed!\n";
    		$h->destroy();
    		$cv->send;
    	},

        timeout => 180,
    );

	$hl->push_write("verbose $verbose\n");
	my $BUFFSIZE = 2**10;
    	my $rl; $rl = AnyEvent::ReadLine::Gnu->new(

    	prompt  => '--->',

        # completion_word => [qw(cat cp chseck ls mkdir mv rm touch q quit exit)],

        # completion_entry_function => [qw(cat cp check ls mkdir mv rm touch q quit exit)],

    	on_line => sub {
    		my $command = shift;
    		if ( !($command =~ /exit|get|put\s*.*/) ) {
			$hl->push_write($command."\n");
			$hl->push_read(
				line => sub{
					if( $_[1] =~ /^Answer:\s(\d+)/ ) {
						my $left = $1;
						#$rl->print("SIZE: $left\n");
						my $cb; $cb = sub{
							$hl->unshift_read(
								chunk => $left > $hl->{read_size} ? $hl->{read_size} : $left,
									sub {
										my (undef, $data) = @_;
										say "LEFT BEFORE : ".$left;
										$left -= length $data;
										say "LEFT AFTER: ".$left;
										$rl->print($data);
										if ($left > 0) {
											$cb->();
										} else {
											undef $cb;
										}
									}
							);
						}; $cb->();
					}
				}
			);
		}
		elsif ($command =~ /^\s*exit|q|quit/i) { #//i i-makes regexp case insensitive!
    			say "Bye!";
    			exit(0);

    		} elsif ($command =~ /^\s*!(.+)/) {
    			$rl->hide();
    			#SAY "yOU DId shell escape" if ($verbose > 0);
    			system($1);
    			$rl->show();

    		} elsif ($command =~ /^put\s+([^\s]+)$/) {
    			my $filename = $1;
    			$rl->print("name of file: $filename\n");
                if (-f $filename){
        			my $size = -s $filename;
        			$hl->push_write("put $size $filename\n");

        			open(my $fd, '<:raw', $filename) or $cv->croak("Failed to open file $filename: $!");
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
        							$hl->push_write($name_file_to_send);
        							if ($hl->{wbuf}) {
        								$hl->on_drain(
        									sub {
        										$hl->on_drain(undef);
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
                    $cv->croak("$filename is not a file!");
                }

    		} elsif ($command =~ /^get\s+.+/) {
                $hl->push_write("$command\n") ;
                $hl->push_read(line => \&getfile);
            }

    	}
    );

};

sub getfile{
    my ($h, $line) = @_;
    if ($line =~ /^get\s+(\d+)\s([^\s]+)/) {
        my ($size,$filename) = ($1,$2);
        my ($file_to_create) = $filename =~ /([^\/]+)$/;
        my $left = $size;
        open(my $fd, '>:raw', $dir_to_upload_files."/".$file_to_create) or $cv->croak("Failed to open file: $!");
        my $body; $body = sub {
            $h->unshift_read(
                chunk => $left > $BUFFSIZE ? $BUFFSIZE : $left, sub {
                    my $rd = $_[1];
                    $left -= length $rd;
                    syswrite($fd, $rd);
                    if ($left == 0) {
                        undef $body;
                        close $fd;
                    } else {
                        $body->();
                    }
                }
            );
        }; $body->();

    }
    $h->push_read(line => \&getfile);
}

$cv->recv;
