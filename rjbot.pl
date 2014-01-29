# Yo dawg. This here is a little bot like script to pull facts
# about R to the J for irssi
#
# enojy

use strict;
use Irssi;
use locale;
use LWP;
use JSON;
use Data::Dumper;


use vars qw($VERSION %IRSSI);

$VERSION = '0.9';
%IRSSI = (
    author        => 'errr',
    contact       => 'code@michaelrice.org',
    name          => 'Michael Rice',
    description   => 'client for rjfacts.pw',
    license       => 'MIT',
    url           => 'https://github.com/michaelrice/irssi-scripts',
    orignal_date  => 'Jan. 28th 2014'
);

sub get_random {
    my @custom_headers = (
        'User-Agent' => 'rjbot 5000',
        'Accept' => 'application/json',
        'X-RJF-Apikey' => 'c25ff106-e7e2-4d82-86b0-e7b530881617'
    );
    my $url = "http://tomcat-demo.mrice.me/api/fact";
    my $browser = LWP::UserAgent->new;
    my $res = $browser->get($url,@custom_headers);

}

sub add_fact {
    my $fact = shift;
    my %foo = (
        class => "com.toastcoders.rjfacts.Fact",
        createdBy => {
            class => "User",
            id => 1,
        },
        factoid => $fact,
    );

    my $json_text;
    $json_text = encode_json(\%foo);

    my $url = "http://tomcat-demo.mrice.me/api/fact";
    my $browser = LWP::UserAgent->new;
    my $req = HTTP::Request->new(POST => $url);
    $req->content_type('application/json');
    $req->content($json_text);
    $req->header( 'Content-Type' => 'application/json' );
    $req->header( 'Accept' => 'application/json' );
    $req->header( 'X-RJF-Apikey' => 'c25ff106-e7e2-4d82-86b0-e7b530881617' );
    my $res = $browser->request($req);
}

sub get_specific {
    my $factid = shift;
    my @custom_headers = (
        'User-Agent' => 'rjbot 5000',
        'Accept' => 'application/json',
        'X-RJF-Apikey' => 'c25ff106-e7e2-4d82-86b0-e7b530881617'
    );
    my $url = "http://tomcat-demo.mrice.me/api/fact/$factid";
    my $browser = LWP::UserAgent->new;
    my $res = $browser->get($url,@custom_headers);
}

sub sig_public {
    my ($server, $msg, $nick, $address, $target) = @_;
    return if $nick eq $server->{nick};

    $msg =~ s/[\000-\037]//g;
    chomp($msg);
    my $win = $server->channel_find($target);
    my $fact;

    if($msg =~ m/!rjfact$/) {
        #RUN a sub to get random fact
        $fact = get_random();
        if($fact->code != 200) {
            return;
        }

        my $json = decode_json($fact->content);
        $fact = $json->{'factoid'} . " -- Fact: #" . $json->{'id'};
    }

    elsif($msg =~ /!rjfact (\d+)$/) {
        #RUN sub to get specific rjfact 
        $fact = get_specific($1);
        if($fact->code != 200) {
            $fact = "Unable to find fact matching id: $1";
        }
        else {
            my $json = decode_json($fact->content);
            $fact = $json->{'factoid'};
        }
    }

    elsif($msg =~ /!rjfact add (.+)$/) {
        # RUN sub to add new fact
        $fact = add_fact($1);
        if($fact->code != 201) {
            $fact = "Unable to create fact.";
        }
        else {
            my $json = decode_json($fact->content);
            $fact = "Created new Fact with id: " . $json->{'id'};
        }
    }

    elsif($msg =~ /!rjfact remove (\d+)$/) {
        #RUN sub to delete a rjfact
        $fact = "I would remove $1 from the db if I had code to do so..";
    }

    elsif($msg =~ /!rjfact help$/) {
        $fact = "!rjfact <command> <params> c[add|remove] p[factoid|factId]";
    }

    return unless $fact;
    $win->command("/ ". $fact);
}

Irssi::signal_add_last('message public', 'sig_public');
Irssi::print("\0039errr's RJ Fact script loaded\n\00313RJ Approves!");
