#!/usr/bin/perl

 use warnings;
 use strict;
 use PDF::API2::Simple;
 use Data::Dumper;
 use Imager::QRCode;
 use Digest::SHA1  qw(sha1 sha1_hex sha1_base64);
 use Date::Parse;
 use MIME::Lite;

 require('include/database.inc.pl');

my $event_id = 1;

## Read in the body text for the email in which the ticket will be sent.
open(MESSAGE, "./include/email/with-ticket.txt");
my $msgbody = do { local $/; <MESSAGE> };
close(MESSAGE);

#my $sql = "SELECT * FROM attendees INNER JOIN tickets ON (attendees.attendee_id = tickets.ticket_attendee_id_fk) WHERE tickets.ticket_event_id_fk = " . $event_id . " AND tickets.ticket_paid = TRUE AND tickets.ticket_sent = FALSE;";
my $sql = "SELECT * FROM attendees INNER JOIN tickets ON (attendees.attendee_id = tickets.ticket_attendee_id_fk) WHERE tickets.ticket_event_id_fk = 1 AND attendees.attendee_id = 5;";
my $sth = $main::dbh->prepare($sql);
$sth->execute();
my $attendees = $sth->fetchall_hashref('attendee_id');

$sql = "SELECT * FROM settings;";
$sth = $main::dbh->prepare($sql);
$sth->execute();
my $settings = $sth->fetchrow_hashref();

$sql = "SELECT * FROM events WHERE event_id = " . $event_id . ";";
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

my @months = ("January","February","March","April","May","June","July","August","September","October","November","December");
my ($ss,$mm,$hh,$day,$month,$year,$zone)  = strptime($event->{'event_date'} . " " . $event->{'event_starttime'});

foreach ( keys(%$attendees) )
{
	## Generate the QR code for the ticket.
	my $checksum = sha1_hex($attendees->{$_}{'attendee_givenname'} . $attendees->{$_}{'attendee_surname'} . $settings->{'settings_salt'});
	my $stuff_to_encode = '{"ticketid":"' . $attendees->{$_}{'ticket_id'} . '","givenname":"' . $attendees->{$_}{'attendee_givenname'} . '","surname":"' . $attendees->{$_}{'attendee_surname'} . '","checksum":"' . $checksum . '"}';
	my $img = $qrcode->plot($stuff_to_encode);
	$img->write(file => "/tmp/qrcode.gif");
	my $pdf = PDF::API2::Simple->new( file => '/tmp/ticket' . $_ . '.pdf');
	$pdf->add_font('VerdanaBold');
	$pdf->add_font('Verdana');
	$pdf->add_page();
	$pdf->image("/tmp/qrcode.gif", width => 200, height => 200, x => 20, y => $pdf->height - 220 );
	$pdf->text($event->{'event_name'}, x => 240, y => $pdf->height - 40, font_size => 20 );
	$pdf->text("by " . $event->{'event_speaker'}, x => 240, y => $pdf->height - 60, font_size => 15 );

	my $datetime_offset = $pdf->height - 100;
	$pdf->text("Date:", x => 240, y=> $datetime_offset, font_size => 15 );
	$pdf->text($day . " " . $months[$month] . " " . ( 1900 + $year ), x => 300, y=> $datetime_offset, font_size => 15 );
	$pdf->text("Start:", x => 240, y=> $datetime_offset - 20, font_size => 15 );	
	$pdf->text($hh . ":" . $mm, x => 300, y=> $datetime_offset - 20, font_size => 15 );	

	my $venue_info_offset = $pdf->height - 160;
	$pdf->text("Venue", x => 240, y=> $venue_info_offset, font_size => 15 );
	$pdf->text($event->{'event_location'}, x => 240, y => $venue_info_offset - 20, font_size => 10, autoflow => 1 );
	$pdf->text($event->{'event_instructions'}, x => 240, y => $venue_info_offset - 40, font_size => 10, autoflow => 1 );

	my $line_height = $pdf->height - 235;
	$pdf->line( x => 20, y => $line_height, to_x => $pdf->width - 20, to_y => $line_height );
	$pdf->line( x => 20, y => $line_height + 2, to_x => $pdf->width - 20, to_y => $line_height + 2 );

	## Ticketholder Details
	my $ticketholder_info_offset = $pdf->height - 260;
	$pdf->text("Ticketholder:", x => 20, y => $ticketholder_info_offset, font_size => 15 );
	$pdf->text($attendees->{$_}{'attendee_givenname'} . " " . $attendees->{$_}{'attendee_surname'}, x => 150, y => $ticketholder_info_offset, font_size => 15 );
	$pdf->text("Ticket Type:", x => 20, y => $ticketholder_info_offset - 20, font_size => 15 );
	$pdf->text($tlevels->{$attendees->{$_}{'ticket_level_id_fk'}}{'ticket_level_name'}, x => 150, y => $ticketholder_info_offset - 20, font_size => 15);
	$pdf->text("This event is presented by", x => 20, y => $pdf->height - 350, font_size => 15 );
	$pdf->image("plug-logo.png", width => 300, height => 111, x => 10, y => $pdf->height - 470 );
	$pdf->text("Website:", x => 20, y => $pdf->height - 490, font_size => 10 );
	$pdf->link("http://www.plug.org.au","http://www.plug.org.au", x => 80, y => $pdf->height - 490, font_size => 10 );
	$pdf->save();

	## Do the emailing and mark the ticket as sent
	my $msg = MIME::Lite->new(
		From    => 'tickets@plug.org.au',
		To      => $attendees->{$_}{'attendee_email'},
		Subject => 'Ticket for ' . $event->{'event_name'} . ' by ' . $event->{'event_speaker'},
		Type    => 'multipart/mixed',
	);

	## Replace markers in the message with database fields
	my $msgbody_personal = $msgbody;

	$msgbody_personal =~ s/\[givenname\]/$attendees->{$_}{'attendee_givenname'}/g;
	$msgbody_personal =~ s/\[surname\]/$attendees->{$_}{'attendee_surname'}/g;

	$msg->attach(
		Type     => 'TEXT',
		Data     => $msgbody_personal,
	);

	$msg->attach(
		Type     => 'application/pdf',
		Path     => '/tmp/ticket' . $_ . '.pdf',
		Filename => 'ticket-' . $_ . '.pdf',
	);
	print("Sending ticket to " . $attendees->{$_}{'attendee_email'} . "... ");
	$msg->send;
	print("Sent!\n");

#	$msg->print(\*STDOUT);
	$sql = "UPDATE tickets SET ticket_sent = TRUE  WHERE ticket_id = '" . $attendees->{$_}{'ticket_id'} . "';";
	$sth = $main::dbh->prepare($sql);
	$sth->execute();
}
