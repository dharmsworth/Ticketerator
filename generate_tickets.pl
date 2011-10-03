#!/usr/bin/perl

 use warnings;
 use strict;
 use PDF::API2::Simple;
 use Data::Dumper;
 use Imager::QRCode;

 require('include/database.inc.pl');

#my $sql = "SELECT * FROM attendees INNER JOIN tickets ON (attendees.attendee_id = tickets.ticket_attendee_id_fk) WHERE tickets.ticket_event_id_fk = 1;";
my $sql = "SELECT * FROM attendees INNER JOIN tickets ON (attendees.attendee_id = tickets.ticket_attendee_id_fk) WHERE tickets.ticket_event_id_fk = 1 AND attendees.attendee_id = 1;";
my $sth = $main::dbh->prepare($sql);
$sth->execute();
my $attendees = $sth->fetchall_hashref('attendee_id');

$sql = "SELECT * FROM events WHERE event_id = 1;";
$sth = $main::dbh->prepare($sql);
$sth->execute();
my $event = $sth->fetchrow_hashref();

#print(Dumper($attendees));

my $qrcode = Imager::QRCode->new(
	size          => 8,
	margin        => 2,
	version       => 1,
	level         => 'M',
	casesensitive => 1,
	lightcolor    => Imager::Color->new(255, 255, 255),
	darkcolor     => Imager::Color->new(0, 0, 0),
);


foreach ( keys(%$attendees) )
{
	## Generate the QR code for the ticket.
	my $img = $qrcode->plot($attendees->{$_}{'ticket_key'});
	$img->write(file => "/tmp/qrcode.gif");

	my $pdf = PDF::API2::Simple->new(-file => '/var/www/localhost/htdocs/ticket.pdf');
	my $page = $pdf->page();
	my $qrgif = $pdf->image_gif("/tmp/qrcode.gif");

	my $content = $page->gfx();
	$content->image($qrgif, 0, 530);
	$content->save();

	$content = $page->text();
	$content->translate(260, 760);	
	my $font = $pdf->corefont('Helvetica');
	
	$content->font($font, 25);
	$content->text($event->{'event_name'});
	
	$content->cr('-25');

	$content->font($font, 15);
	$content->text("by " . $event->{'event_speaker'});

	$content->translate(0,500);

	$content->font($font, 12);
	$content->text($event->{'event_instructions'});
	$pdf->save();
}
