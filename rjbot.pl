use strict;
use Irssi;
use locale;
use LWP;
use JSON;


use vars qw($VERSION %IRSSI);

$VERSION = '0.9';
%IRSSI = (
    author        => 'errr',
    contact       => 'code@michaelrice.org',
    name          => 'Michael Rice',
    description   => 'client for rjfacts.pw'
    license       => 'MIT',
    url           => 'https://github.com/michaelrice/irssi-scripts'
    orignal_date  => 'Jan. 28th 2014'
);

sub sig_public {
    my ($server, $msg, $nick, $address, $target) = @_;
    return if $nick eq $server->{nick};
    
    $msg =~ s/[\000-\037]//g;
    $msg = lc($msg);
    chomp($msg);
    my $win = $server->channel_find($target);
    my $fact;

    if($msg =~ /\b!rjfact$/) {
        #RUN a sub to get random fact
        $fact = get_random();
        my $json = decode_json($fact->content);
        $fact = $json->{'factoid'};
    }
    elsif($msg =~ /\b!rjfact \d+/) {
        #RUN sub to get specific rjfact 
    }
    elsif($msg =~ /\b!rjfact add (.+)/) {
        # RUN sub to add new fact
    }
    elsif($msg =~ /\b!rjfact (remove|del) \d+/) {
        #RUN sub to delete a rjfact
    }
    return unless $fact;
    $win->command("/ ". $fact);
}

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

Irssi::signal_add_last('message public', 'sig_public');
Irssi::print("\0039errr's RJ Fact script loaded\n\00313RJ Approves!");
