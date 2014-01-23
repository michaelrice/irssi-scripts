#!/usr/bin/perl -w 
#gpl, created by errr.
use LWP::Simple;
use HTML::Entities;
use DBI qw(:sql_types);
use Irssi;
use locale;
use vars qw($VERSION %IRSSI @answers);
use strict;
%IRSSI = (
  author        => 'errr',
  contact       => 'errr(at)errr-online(dot)com',
  name          => 'errr',
  description   => 'the Chuck Norris and Mr T fact scraper',
  license       => 'gpl v2',
  url           => 'http://errr-online.com/',
  last_modified => 'Jan. 19th 2006'
);
my @gods = qw(gaheath gaheath_ gaheath__);
my $fact_path = "/home/errr/.irssi/scripts/facts.db";
sub privmsg_handler {
    my $c_op = 0;
    my ($server, $msg, $nick, $address, $target) = @_; 
    return if $nick eq $server->{nick};
    foreach(@gods) { $c_op = 1 if lc($nick) =~ /$_/ }
    return if $c_op;
    $msg =~ s/[\000-\037]//g;
    $msg = lc($msg);
    my @good_rooms = qw(#pblug #fluxlovers #bassdrive #fluxbox-chitchat);
    my $say_it = 0;
    foreach(@good_rooms){$say_it = 1 if lc($target) eq lc($_) }
    return unless $say_it;
    my $dbh = DBI->connect("DBI:SQLite:$fact_path");
    $msg =~ s/\+//;
    if($msg =~ /\b(chuck|roundhouse|beard|ranger|walker|ninja|karate|kick|texas)/ig) {
      my $sth = $dbh->prepare("select quote from chuck_facts order by random() limit 1");
      $sth->execute();
      my $row = $sth->fetch;
      my $fact = $row->[0];
      my $win = $server->channel_find($target);
      $win->command("/ ".$fact);
    }
    elsif ($msg =~ /\b(sukka|pity|fool|a-team|gold chain|van|gmc|team)/ig) { 
      my $sth = $dbh->prepare("select quot from mr_t_facts order by random() limit 1");
      $sth->execute();
      my $row = $sth->fetch;
      my $fact = $row->[0];
      my $win = $server->channel_find($target);
      $win->command("/ ".$fact);
      
    }
}

sub chuck_fact {
  my $page = get('http://www.4q.cc/chuck/index.php');
  if ($page =~ /<p class="fact">(.+)<\/p>/) {
  # if this is true we need to setup a connection to the db
  # and clean the html shit from the quote
      my $str = decode_entities($1);
      $str =~ s/'/''/g;
      my $dbh = DBI->connect("DBI:SQLite:$fact_path");
      #then we need to set up a query and see if the fact we have is already 
      #in the db
      my $sth = $dbh->prepare("SELECT * FROM chuck_facts WHERE quote = '$str'");
      $sth->execute();
      my $row = $sth->fetch;
      my $fact = $row->[1];
      if ($fact eq $str) {
          #pass on cause we know its already in the db
          Irssi::print("This quote is in the db already");
          $str =~ s/''/'/g;
          Irssi::active_win()->command("/ ".$str);
          return 1;
      }
      #so its not in the db we need to add it
      else {
          my $sth = $dbh->prepare("INSERT INTO chuck_facts (id, quote)  VALUES (NULL, '$str')");
          $sth->execute();
          $str =~ s/''/'/g;
          Irssi::active_win()->command("/ ".$str);
          Irssi::print("This fact was added to the db");
          return 1;
      }
  }
  #ok so it didnt match, ods are we got a server error from the site, try again later
  else {
    Irssi::print("There was an error fetching the page, try again.");
    return 1;
  }
}

sub mr_t_fact {
  my $page = get('http://www.4q.cc/t/index.php');
  if ($page =~ /<p class="fact">(.+)<\/p>/) {
  # if this is true we need to setup a connection to the db
  # and clean the html shit from the quote
      my $str = decode_entities($1);
      $str =~ s/'/''/g;
      my $dbh = DBI->connect("DBI:SQLite:$fact_path");
      #then we need to set up a query and see if the fact we have is already 
      #in the db
      my $sth = $dbh->prepare("SELECT * FROM mr_t_facts WHERE quot = '$str'");
      $sth->execute();
      my $row = $sth->fetch;
      my $fact = $row->[1];
      if ($fact eq $str) {
          #pass on cause we know its already in the db
          Irssi::print("This quote is in the db already");
          $str =~ s/''/'/g;
          Irssi::active_win()->command("/ ".$str);
          return 1;
      }
      #so its not in the db we need to add it
      else {
          my $sth = $dbh->prepare("INSERT INTO mr_t_facts (id, quot)  VALUES (NULL, '$str')");
          $sth->execute();
          $str =~ s/''/'/g;
          Irssi::active_win()->command("/ ".$str);
          Irssi::print("This fact was added to the db");
          return 1;
      }
  }
  #ok so it didnt match, ods are we got a server error from the site, try again later
  else {
    Irssi::print("There was an error fetching the page, try again.");
    return 1;
  }  
}
Irssi::signal_add_last("message public", "privmsg_handler");
Irssi::command_bind( "chuck_fact", "chuck_fact" );
Irssi::command_bind( "mr_t_fact", "mr_t_fact" );
Irssi::print("errr's Chuck Norris and Mr. T fact Script [Loaded]");
Irssi::print("annoy with care :) ");
