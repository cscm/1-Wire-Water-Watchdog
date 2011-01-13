#!/usr/bin/perl 
=head1 NOM

water_watchdog.pl - Water flow monitoring script for monit

=head1 VERSION

Documentation for water_watchdog.pl version $Rev$

=head1 RÉSUMÉ

Edit your monit configuration :

check process water_watchdog.pl with pidfile water_watchdog.pid
    	start program  = water_watchdog

check file water_watchdog.status with path water_watchdog.status
	ignore match OK
        if match ^KO then alert


=head1 DESCRIPTION

Watch the content of OW-SERVER 1-Wire to Ethernet Server's details.xml file.
You should change the HOSTNAME, FLOW_ALERT_LOWER_LIMIT and RATE according 
to your needs.

=head1 AUTEUR

Christophe Nowicki (cscm at csquad.org)

=head1 LICENCE ET COPYRIGHT

Copyright (c) 2010 Christophe Nowicki (cscm at csquad.org)
WTFPL - Do What The Fuck You Want To Public License 

=head1 MODIFICATIONS

Last change : $Date$ par $Author$.

=cut


use XML::Smart;
use IO::Handle;
use Readonly;
use Data::Types qw(:int); 
use strict;

Readonly my $HOSTNAME => 'http://glouglou';
Readonly my $LOGFILE => 'water_watchdog.status';
Readonly my $FLOW_ALERT_LOWER_LIMIT => 1;
Readonly my $RATE => 60;


my $LOG;
open($LOG, ">>", $LOGFILE) or die("Could not open file $LOGFILE: $!");
$LOG->autoflush(1);

my $last_value = 0;

while (42) {
	my $xml = XML::Smart->new( $HOSTNAME . '/details.xml');
	my $flow = $xml->{'Devices-Detail-Response'}{'owd_DS2423'}{'Counter_A'};

	die ("device not found") unless (is_int($flow));
	unless ($last_value) { 
		$last_value = $flow; 
		sleep $RATE;
		next; 
	}

	if (($flow - $last_value) < $FLOW_ALERT_LOWER_LIMIT) {
		$LOG->print("OK\n");
	}
	else {
		$LOG->print("KO\n");
	}
	$last_value = $flow;
	sleep $RATE;
}
$LOG->close();
