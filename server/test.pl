use 5.016;
use DDP;
use LocalClient::lib::Local::Client;


my $str_1 = "/home/egor/tmp/exp/lox";
my $str_2 = "/home/egor/tmp/exp/KEK/lox";
		
my ($old_dir) = $str_1 =~ /(.*\/).*/s;
my ($old_file) = $str_1 =~ /\/.*\/(.*)/s;
		
my ($new_dir) = $str_2 =~ /(.*\/).*/s;
my ($new_file) = $str_2 =~ /\/.*\/(.*)/s; 
		
say $new_dir;
say $new_file;

say $old_file;
say $old_dir;
