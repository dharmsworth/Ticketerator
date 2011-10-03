#!/usr/bin/perl

 use warnings;
 use strict;
 use PDF::API2::Simple;
 use Data::Dumper;
 use Imager::QRCode;
 use Digest::SHA1  qw(sha1 sha1_hex sha1_base64);

 require('include/database.inc.pl');

#my $sql = "SELECT * FROM attendees INNER JOIN tickets ON (attendees.attendee_id = tickets.ticket_attendee_id_fk) WHERE tickets.ticket_event_id_fk = 1;";
my $sql = "SELECT * FROM attendees INNER JOIN tickets ON (attendees.attendee_id = tickets.ticket_attendee_id_fk) WHERE tickets.ticket_event_id_fk = 1 AND attendees.attendee_id = 5;";
my $sth = $main::dbh->prepare($sql);
$sth->execute();
my $attendees = $sth->fetchall_hashref('attendee_id');

$sql = "SELECT * FROM settings;";
$sth = $main::dbh->prepare($sql);
$sth->execute();
my $settings = $sth->fetchrow_hashref();

$sql = "SELECT * FROM events WHERE event_id = 1;";
$sth = $main::dbh->prepare($sql);
$sth->execute();
my $event = $sth->fetchrow_hashref();

$sql = "SELECT * FROM ticket_level;";
$sth = $main::dbh->prepare($sql);
$sth->execute();
my $tlevels = $sth->fetchall_hashref('ticket_level_id');

#print(Dumper($attendees));

my $qrcode = Imager::QRCode->new(
	size          => 8,
	margin        => 0,
	version       => 1,
	level         => 'M',
	casesensitive => 1,
	lightcolor    => Imager::Color->new(255, 255, 255),
	darkcolor     => Imager::Color->new(0, 0, 0),
);


foreach ( keys(%$attendees) )
{
	## Generate the QR code for the ticket.
	my $checksum = sha1_hex($attendees->{$_}{'attendee_givenname'} . $attendees->{$_}{'attendee_surname'} . $settings->{'settings_salt'});
	my $stuff_to_encode = '{"ticketid":"' . $attendees->{$_}{'ticket_id'} . '","givenname":"' . $attendees->{$_}{'attendee_givenname'} . '","surname":"' . $attendees->{$_}{'attendee_surname'} . '","checksum":"' . $checksum . '"}';
	my $img = $qrcode->plot($stuff_to_encode);
	$img->write(file => "/tmp/qrcode.gif");
	my $pdf = PDF::API2::Simple->new( file => '/var/www/localhost/htdocs/ticket.pdf');
	$pdf->add_font('VerdanaBold');
	$pdf->add_font('Verdana');
	$pdf->add_page();
	$pdf->image("/tmp/qrcode.gif", width => 200, height => 200, x => 20, y => $pdf->height - 220 );
	$pdf->text($event->{'event_name'}, x => 240, y => $pdf->height - 40, font_size => 20 );
	$pdf->text("by " . $event->{'event_speaker'}, x => 240, y => $pdf->height - 60, font_size => 15 );
	$pdf->text("Venue", x => 240, y=> $pdf->height -100, font_size => 15 );
	$pdf->text($event->{'event_location'}, x => 240, y => $pdf->height - 120, font_size => 10, autoflow => 1 );
	$pdf->text($event->{'event_instructions'}, x => 240, y => $pdf->height - 150, font_size => 10, autoflow => 1 );

	## Ticketholder Details
	$pdf->text("Ticketholder:", x => 20, y => $pdf->height - 260, font_size => 15 );
	$pdf->text($attendees->{$_}{'attendee_givenname'} . " " . $attendees->{$_}{'attendee_surname'}, x => 150, y => $pdf->height - 260, font_size => 15 );
	$pdf->text("Ticket Type:", x => 20, y => $pdf->height - 280, font_size => 15 );
	$pdf->text($tlevels->{$attendees->{$_}{'ticket_level_id_fk'}}{'ticket_level_name'}, x => 150, y => $pdf->height - 280, font_size => 15);
	$pdf->text("This event is presented by", x => 20, y => $pdf->height - 350, font_size => 15 );
	$pdf->image("plug-logo.png", width => 300, height => 111, x => 10, y => $pdf->height - 470 );
	$pdf->text("Website:", x => 20, y => $pdf->height - 490, font_size => 10 );
	$pdf->link("http://www.plug.org.au","http://www.plug.org.au", x => 80, y => $pdf->height - 490, font_size => 10 );
	$pdf->save();
}
