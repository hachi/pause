# -*- Mode: cperl; coding: utf-8 -*-
package pause_1999::message;
use base 'Class::Singleton';
use pause_1999::main;
use strict;
use utf8;
our $VERSION = sprintf "%d", q$Rev: 235 $ =~ /(\d+)/;

sub as_string {
  my pause_1999::message $self = shift;
  my pause_1999::main $mgr = shift;
  my $r = $mgr->{R};
  my $user = $r->connection->user;
  my @m;
  my $dbh = $mgr->connect;
  my $sth = $dbh->prepare("select * from messages where mto=?");
  $sth->execute($user);
  if ($sth->rows > 0) {
    push @m, qq{<div align="left">};
    push @m, qq{<p>Messages to user $user:</p>};
    push @m, qq{<dl>};
    while (my $rec = $sth->fetchrow_hashref) {
      push @m, qq{<dt>$rec->{created} by $rec->{mfrom}</dt>};
      push @m, qq{<dd>$rec->{what}</dd>};
    }
    push @m, qq{</dl>};
    push @m, qq{<p>Please answer the sender so that they can delete the messages.</p>};
    push @m, qq{</div>\n};
  }
  @m;
}

1;
