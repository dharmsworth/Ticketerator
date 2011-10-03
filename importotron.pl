#!/usr/bin/perl
 use strict;
 use warnings;
 use Text::CSV;
 use Data::Dumper;
 use Digest::SHA1  qw(sha1 sha1_hex sha1_base64);

 require('include/database.inc.pl');

my $file = 'rusty_talk_tickets.csv';
my $csv = Text::CSV->new();

open (CSV, "<", $file) or die $!;

while (<CSV>) {
	if ($csv->parse($_)) {
		my @columns = $csv->fields();
		for (my $count=0; $count<$#columns; $count++)
		{
				if ( length(@columns[$count]) <= 0 )
				{
					@columns[$count] = "NULL";
				}
				else
				{
					my $hold = @columns[$count];;
					$hold =~ s/\'//g;
					@columns[$count] = "'" . $hold . "'";
				}
		}
		my $sql = "INSERT INTO attendees VALUES (DEFAULT, " . @columns[1] . ", " . @columns[2] . ", " . @columns[4] . ") RETURNING attendee_id;";
		my $sth = $main::dbh->prepare($sql);
		$sth->execute() || die($!);
		my $attendee_id = $sth->fetch()->[0];
#		my $attendee_id = 3;
		my $key = rand() . time();
		$sql = "INSERT INTO tickets VALUES (DEFAULT, '1', '" . $attendee_id . "', " . @columns[3] . ", '" . sha1_hex($key) . "', " . ( @columns[5] == 0 ? "FALSE" : "TRUE" ) . ", FALSE);";
		print($sql . "\n");
		$sth = $main::dbh->prepare($sql);
		$sth->execute() || die($!);
	} else {
		my $err = $csv->error_input;
		print "Failed to parse line: $err";
	}
#	print(");\n");
}
close CSV;

