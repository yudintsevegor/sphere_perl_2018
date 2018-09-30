#! /usr/bin/perl
use 5.016;
use Socket ':all';

use File::Spec;
use File::Basename;
use File::Copy;
use Cwd;
use FindBin;
use Getopt::Long;
use lib "$FindBin::Bin/lib",glob("$FindBin::Bin/../libs/*/lib"),;
use LocalProcessingInput
binmode(STDOUT, ':utf8');

my $dir = @ARGV[0];
my $address = '127.0.0.1';

my $port = @ARGV[1];
socket my $srv , AF_INET, SOCK_STREAM, IPPROTO_TCP or die $!;
setsockopt $srv , SOL_SOCKET, SO_REUSEADDR, 1 or die $!;
bind $srv , sockaddr_in( $port , inet_aton( $address )) or die $!;
listen $srv , SOMAXCONN or die $!;
my ($port, $addr) = sockaddr_in(getsockname($srv));
say "Listining on ".inet_ntoa( $addr ).":".$port;

$SIG{CHLD} = sub {};

while (){
    while ( accept my $cln , $srv ) {
        defined ( my $chld  = fork ()) or die "fork: $! ";
        if  ( $chld ) { close $cln; }
        else {
            close $srv;
            say "Connected";
            my $root  = "$dir";
            my $read  = sysread($cln, my $buf, 4096);
            if ($read){
                my $req = $buf;
                say $req;
                my  ( $method , $path ) = $req  =~ /^([A-Z]+)\s\/([^\s]+)\sHTTP/;
                say $method;
                say $root."/".$path;
                # --------------------------------------
                if  ( $method ne 'GET' ) {
                    say "neget";
                    syswrite $cln , "HTTP/1.1 415 Not allowed\n" . "Content-Length: 0\n\n";
                    last;
                }
                open ( my $fh , '<:raw' , $root ."/". $path ) or do  {
                    say "ERROR: $!";
                    my $err  = "Could not open file ' $root"."$path ' $! ";
                    syswrite $cln , "HTTP/1.1 404 Not Found\nContent-Length: " . length ( $err ). "\n\n $err \n";
                    exit;
                };
                my $data;
                while (my $input = <$fh>) {
                    say "Output ".$input;
                    $data .=$input;
                }

                # $data  .= $_ for (<$fh>);
                print $data;
                syswrite $cln , "HTTP/1.1 200 OK\nContent-Length: " . length ( $data ). "\n\n$data \n";
                exit;
            }elsif (defined $read) {
                warn "EOF from client";
                last;
            }else {
                warn "Error from client: $!";
                last;
            }
        }
    }
    last unless $!{EINTR};
}
