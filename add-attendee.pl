#!/usr/bin/perl
 use strict;
 use warnings;
 use Text::CSV;
 use Data::Dumper;
 use Digest::SHA1  qw(sha1 sha1_hex sha1_base64);

 require('include/database.inc.pl');

my $attendee_givenname = "";
my $attendee_surname = "";
my $attendee_email = "";
my $ticket_level = "";

my $sql = "SELECT * FROM ticket_level;";
my $sth = $main::dbh->prepare($sql);
$sth->execute() || die($!);
my $events = $sth->fetchall_hashref('ticket_level_id');;

print("Given Name: ");
$attendee_givenname = <>;
chomp($attendee_givenname);

print("Surname: ");
$attendee_surname = <>;
chomp($attendee_surname);

print("E-Mail Address: ");
$attendee_email = <>;
chomp($attendee_email);

print("\n");
foreach (keys(%$events))
{
	print($_ . "\t" . $events->{$_}{'ticket_level_name'} . "\n");
}
print("Ticket Level: ");
$ticket_level = <>;
chomp($ticket_level);

$sql = "INSERT INTO attendees VALUES (DEFAULT, '" . $attendee_givenname . "', '" . $attendee_surname . "', '" . $attendee_email . "') RETURNING attendee_id;";
print($sql . "\n");
$sth = $main::dbh->prepare($sql);
$sth->execute() || die($!);
my $attendee_id = $sth->fetch()->[0];
$sql = "INSERT INTO tickets VALUES (DEFAULT, '1', '" . $attendee_id . "', '" . $ticket_level . "', FALSE, FALSE);";
print($sql . "\n");
$sth = $main::dbh->prepare($sql);
$sth->execute() || die($!);
