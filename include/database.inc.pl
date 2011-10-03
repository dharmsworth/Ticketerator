#!/usr/bin/perl
 use warnings;
 use strict;

 use DBI;

### Database Configuration Bit
my $dbname = "ticketerator";
my $host = "localhost";
my $port = "5432";
my $username = "ticketerator";
my $password = "f0ceebdf0a80ef333df842258b35f7bc1cfe87e4";

our $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port;",
			$username,
			$password
#			{AutoCommit => 1, RaiseError => 1, PrintError => 0}
		);

sub get_
