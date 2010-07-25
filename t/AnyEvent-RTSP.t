#!/usr/bin/env perl

use Test::More tests => 8;
BEGIN { use_ok('AnyEvent::RTSP') };
use AnyEvent;

# to test, pass url of an RTSP server in $ENV{ANYEVENT_RTSP_TEST_URI}
# e.g.   ANYEVENT_RTSP_TEST_URI="rtsp://foo:bar@10.0.1.105:554/mpeg4/media.amp" perl -Ilib t/AnyEvent-RTSP.t
my $uri = $ENV{ANYEVENT_RTSP_TEST_URI};

SKIP: {
    skip "No RTSP server URI provided for testing", 7 unless $uri;
    
    # parse uri
    my $client = AnyEvent::RTSP->new_from_uri(uri => $uri, client_port_range => '6970-6971');
    skip "Invalid RTSP server URI provided for testing", 7 unless $client;

    $client->open or die $!;
    pass("opened connection to RTSP server");
    
    $client->options_public(sub {
        my ($ok, @public_options) = @_;
        ok($ok, @public_options, "got public allowed methods: " . join(', ', @public_options));
    });
    
    $client = AnyEvent::RTSP->new_from_uri(uri => $uri, client_port_range => '6970-6971');

    my $cv = AnyEvent->condvar;

    # test describe
    $client->describe(sub {
        my ($desc_ok, $sdp) = @_;
        ok($desc_ok && $sdp, "got SDP info");

        $client->reset;

        # test setup
        $client->setup(sub {
            my ($setup_ok) = @_;
            ok($setup_ok, "setup");

            # test play
            $client->play(sub {
                my ($play_ok) = @_;
                ok($play_ok, "play");

                # test pause
                $client->pause(sub {
                    my ($pause_ok) = @_;
                    ok($pause_ok, "pause");

                    # it's ok if these return 405 (method not allowed)
                    $status = $client->status;
                    ok(($status == 200 || $status == 405), "pause status");

                    # test teardown
                    $client->teardown(sub {
                        my ($td_ok) = @_;
                        ok($td_ok, "teardown");

                        $cv->send;
                    });
                });
            });
        });
    });
    
    $cv->recv;
};

