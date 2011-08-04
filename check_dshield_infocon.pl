#!/usr/bin/perl -w
#-----------------------------------------------------------------------------
#Author: John Lowry <johnlowry@gmail.com>
#Date: August 4, 2011
#Version: 0.01
#Description: This is a nagios command for checking the status of the DSheild 
#Infocon. 
#License: GPLv3
#-----------------------------------------------------------------------------

use strict;
use Getopt::Long;
use REST::Client;
use lib "/usr/lib/nagios/plugins";
use utils qw($TIMEOUT %ERRORS &print_revision &support &usage);
use vars qw($opt_V $opt_h $PROGNAME $VERSION);

$PROGNAME   = 'check_dshield_infoconf.pl';
$VERSION    = '0.01';

sub print_help ();
sub print_usage ();

$ENV{'PATH'}='';
$ENV{'BASH_ENV'}='';
$ENV{'ENV'}='';

Getopt::Long::Configure('bundling');
GetOptions
        ("V"   => \$opt_V, "version"            => \$opt_V,
         "h"   => \$opt_h, "help"               => \$opt_h);

if ($opt_V){
        print_revision($PROGNAME, $VERSION); 
        exit $ERRORS{'OK'};
}

if ($opt_h){
        print_help();
        exit $ERRORS{'OK'};
}

my $client = REST::Client->new({
        host    => 'http://isc.sans.edu',
        timeout =>  $TIMEOUT,
        });

$client->GET('/api/infocon');

my $xpc=$client->responseXpath();

my $status=$xpc->find('/infocon/status');

#Remove a possible empty line
$status=~s/^\n//;

if ($status =~ m/green/i){
    print "Infocon is: $status";
    exit $ERRORS{'OK'};
}
elsif ($status =~ m/yellow|orange/i){
    print "Infocon is: $status";
    exit $ERRORS{'WARNING'};
}
elsif ($status =~ m/red/i){
    print "Infocon is: $status";
    exit $ERRORS{'CRITICAL'};
}
else{
    print "Unkown error! Response: $status";
    exit $ERRORS{'UNKNOWN'};
}

sub print_usage() {
    print "Usage: $PROGNAME\n";
}    

sub print_help() {
    print_revision($PROGNAME, $VERSION);
    print "Copyright (c) 2011 John Lowry.
This plugin reports the status of the DSheild Infocon.
Green will return \'OK\'
Yellow and Orange will return \'Warning\'
Red will return \'Critical\'\n\n";
    print_usage();
    support();
};

