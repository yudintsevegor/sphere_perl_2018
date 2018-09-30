# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Local-Client.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Test::More;
#BEGIN { use_ok('lib::Local::Client') };

#is(Method(),'' ,"MDA");
BEGIN { my @methods = ('Method', 'new', 'function_mv', 'function_rm', 'function_cp', 'function_ls', 'function_loc_rm', 'function_loc_mv', 'function_loc_ls');
	foreach my $meth (@methods) {
  	can_ok('Local::Client', $meth);
	 };
}
=head1
$got		=	{
		Method() => 	{
			 => 	
			 =>	
				}
	 		
			};

$expected	= 	{
		

			};
=cut
#is_deeply($got, $expected, 'MDA' );




done_testing();
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

