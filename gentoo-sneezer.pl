#sometimes listening to people go on and on about gentoo and how it
#hung the moon and is the greatest thing since sliced bread just makes
#me a little sick...
#released under the terms of the gpl v2

#use strict;
use Irssi;
use locale;

use vars qw($VERSION %IRSSI @answers);

$VERSION = '0.9';
%IRSSI = (
    author        => 'errr',
    contact       => 'errr(at)errr-online(dot)com',
    name          => 'errr',
    description   =>'sneezes when the word "gentoo" has been said',
    license       => 'gpl v2',
    url           => 'http://errr-online.com/',
    orignal_date  => 'Jan. 14th 2005',
    last_modified => 'Jan. 12th 2006'
);

my @answers = (
	    "hhhhhhhhhaaaaaaaaa cccccchhhhhhhooooooooooo",
	    "bbbbaaaaaaaaawwwwwwwww chhhhhhoooooooooo",
	    "hhhhhhhaaaaaaaaaaaaaaaaaaaaaaa chhhhhhhhhhhhhhhoooooooooooooyy",
	    "hhaaa chooo",
	    "BBBBBBBAAAAAAAAAAAAWWWWWWWWWWWW CCCHHHHHHHHHHOOOOOOOOO",
	    "*cough* *cough*",
	    "hhhaaaa hhhhaaaaa    hhhhhaaaaa  cchooooooooooooooooooooooooooo",
      "haaaa haaa haaa haa ccccoooooooooooooooooooooooooooooooooooo",
      "*sniff* *sniff*, guess Im getting a cold or someting..."
	    );

#words that make me sick      
my @words = qw(gentoo gen2 gent00 gento portage emerge ebuild esearch);
#channels you want this script to be active in
my @channels = qw(#fluxbox #fluxbox-chitchat #pblug #fluxlovers #test0r);
#people you dont want to be able to trigger the script
my @gods = qw(ak|ra car fluxgen rathnor _markt tenner dopey fbot computer meltir lack);
#gotta make sure we can sneeze the first time they say the offending word
my $talk = 1;
my $say_ty = 1;
#here we set this true in the timer so people cant flood this to death
sub set_talk {
    $talk = 1;
}

sub say_thanks {
    $say_ty = 1;
}

sub be_nice {
  my ($server, $msg, $nick, $address, $target) = @_;
  return if $nick eq $server->{nick};
  my @thanks = ("ty", "thanks $nick", "thanks $nick. Man I think I must be getting sick..",
     "thanks, must be something in the air...","man I feel terrible, thanks $nick");      
  $msg =~ s/[\000-\037]//g;
  $msg = lc($msg);
  my $react = 0;
  foreach (@channels) { $react = 1 if lc($target) eq lc($_) }
  return unless $react;
  my $win = $server->channel_find($target);
  if(!$talk && $say_ty) {
      if($msg =~ /\bbless you/) {
          $win->command("/ ".$thanks[int(rand(@thanks))]);
          $say_ty = 0;
          Irssi::timeout_add_once(10000,\&say_thanks,undef);
      }
  }
}
sub sig_public {
    #data coming from the server server_name, chan message, who sent it, whats their mask
    #what room where they in when they said it
    my ($server, $msg, $nick, $address, $target) = @_;
    #return if the nick is the server.. 
    return if $nick eq $server->{nick};
    #strip crap off the message
    $msg =~ s/[\000-\037]//g;
    #convert it to all lower case
    $msg = lc($msg);
    #bad word
    my $nono = 0;
    foreach (@words) { $nono = 1 if $msg =~ /\b$_/ }
    #return unless they have said a word that makes us sick
    return unless $nono;
    #is this channel one from the list.. 
    my $react = 0;
    foreach (@channels) { $react = 1 if lc($target) eq lc($_) }
    return unless $react;
    # god-like person? dont want it to go off when the devs are talking or the bot
    my $c_op = 0;
    foreach (@gods) { $c_op = 1 if lc($nick) =~ /$_/ }
    return if $c_op;
    # voiced or op'd? is it someone who is oped, they can say what they want..
    return if $server->channel_find($target)->nick_find($nick)->{op} || $server->channel_find($target)->nick_find($nick)->{voice};
    #now to send the message to the room who said the word, instead of the active window you have..
    my $win = $server->channel_find($target);
    if ($talk){
        $win->command("/ ".$answers[int(rand(@answers))]); 
        $talk = 0;
        #wait for time in miliseconds 65,000 = 1 min 5 seconds
        #before we will be able to sneeze again
        Irssi::timeout_add_once(95000,\&set_talk,undef);
    }
}
Irssi::signal_add('message public', 'be_nice');     
Irssi::signal_add_last('message public', 'sig_public');
Irssi::print("\0039errr's sneezer script loaded\n\00313get well soon!!!");
