#!/usr/local/bin/perl
use strict;
use warnings;

use Encode ();
use IO::Socket ();
use IO::Select ();
#use Time::HiRes ();
use utf8;

################################################################################
# Usage: Edit the values in the section below, run the script, read the screen #
################################################################################

# "client" -- Imitate a client (i.e., send request, get response)
# "server" -- Imitate a server (i.e., listen on port for requests)
use constant ROLE => "client";
use constant PORT => "7600";

## Client Settings #############################################################
use constant HOST => "web639ac2.ysm.ac2.yahoo.com";
use constant DIAGNOSTICS => 0;      # "0" = Normal, "1" = Diagnostics
use constant MESSAGE_VERSION => 0;  # "0" = UDPv1, "1" = UDPv2
use constant MARKET_ID => "0";      # "0" for us, "1" for uk, etc.


################################################################################
## Sanity Checking! ############################################################
################################################################################
die unless (ROLE eq "client" || ROLE eq "server");
die unless (DIAGNOSTICS == 0 || DIAGNOSTICS == 1);
die unless (MESSAGE_VERSION == 0 || MESSAGE_VERSION == 1);


################################################################################
## Implementation! #############################################################
################################################################################

use constant UNIQUE_ID => pack("h8", "deadbeef");  # The 32-bit unique id field.

# Generate the MD request buffer, filling its fields with all the above values.
sub generate_request {
    my ($raw_terms_ref, $market_version) = @_;

    # First write out the header string:
    my $request_buffer = (DIAGNOSTICS ? "Diagnostic" : "MatchDrive");
	my $version;
	# Parse and clean arguments...
	  if ( $market_version !=-1 ) {
	    $version= $market_version*10;
	  } else {
	    $version=-1;
	  }

    # Next write out the header:
    $request_buffer .= pack("ccc", MESSAGE_VERSION, $version, MARKET_ID);
    $request_buffer .= UNIQUE_ID;

    # Encode the raw term list into UTF-8:
    my @raw_terms = map { Encode::encode_utf8($_) } @$raw_terms_ref;

    # Depending on the version requested, add the raw terms:
    if (MESSAGE_VERSION == 0) {
        $request_buffer .= $raw_terms[0];
        print "(Note: UDPv1 chosen. Ignoring superfluous raw terms.)\n\n"
            if (@raw_terms > 1);
    } elsif (MESSAGE_VERSION == 1) {
        $request_buffer .= pack("c", scalar(@raw_terms));
        foreach my $term (@raw_terms) {
            $request_buffer .= pack("s", bytes::length($term)) . $term;
        }
    } else { die; }

    return $request_buffer;
}

# Print out debug information on the given response buffer.
sub dump_response {
    my $response_buffer = shift;

    if (MESSAGE_VERSION == 0) {
        my $term_bytes = unpack("x19h*", $response_buffer);
        my $result = pack("h*", $term_bytes) . "\n";
        return $result;
    } else { die; }
}

my $socket = new IO::Socket::INET(PeerAddr => HOST,
                                  PeerPort => PORT,
                                  Type     => IO::Socket::SOCK_DGRAM,
                                  Proto    => "udp");
die "Failed to initialize socket: $@" unless $socket;

sub send_request {
    my $request = shift;

    eval { $socket->send($request); };
    if ($@) { die $@; }

    my $poll = new IO::Select($socket);
    my @ready = $poll->can_read(1);  # 2s timeout value.
    die "Request timed out" if (scalar(@ready) == 0);

    my $response;
    die "Error reading response: $!"
        unless defined $socket->recv($response, 65507);

    return $response;
}

sub try_sending_request {
    my $request = shift;

    my $response;
    foreach (1..10) {
        eval { $response = send_request($request); };
        if ($@) { print STDERR "$@... Trying again ($_).\n"; }
    }

    if ($@){ die "giving up."; }

    return $response;
}


################################################################################
## Enough of this nonsense... Mock client! #####################################
################################################################################


my $total = 0;
while (my $line = <>) {
    print STDERR "$total\n" unless ($total % 50000);
    $total++;

    eval {
        chomp $line;
        my $exact_request = generate_request([$line], -1);
        my $phrase_request = generate_request([$line], 0.5);

        my @printables = ($line);

        foreach my $form (.5, -1) {
            my $response = try_sending_request(generate_request([$line], $form));
            my $result = dump_response($response);
            chomp $result;
            push(@printables, $result);
        }

        print join("\t", @printables) . "\n";
    }
}
