package PAUSE::MailAddress;
use PAUSE ();
use strict;

# use fields qw(address is_secret)

sub new {
  my($class,$hashref) = @_;
  bless $hashref, $class;
}

sub new_from_userid {
  my($class,$userid,$opt) = @_;
  my $dbh = $opt->{dbh} ||
      DBI->connect(
                   $PAUSE::Config->{MOD_DATA_SOURCE_NAME},
                   $PAUSE::Config->{MOD_DATA_SOURCE_USER},
                   $PAUSE::Config->{MOD_DATA_SOURCE_PW},
                   { RaiseError => 1 }
                  )
          or Carp::croak(qq{Can't DBI->connect(): $DBI::errstr});
  my $dsn = $PAUSE::Config->{AUTHEN_DATA_SOURCE_NAME};
  my(undef,undef,$dbname) = split /:/, $dsn;
  if ($dbname =~ /;/) {
      ($dbname) = $dsn =~ /database=(\w+)/;
  }
  my $sth = $dbh->prepare("SELECT secretemail
                             FROM $dbname.$PAUSE::Config->{AUTHEN_USER_TABLE}
                             WHERE $PAUSE::Config->{AUTHEN_USER_FLD}=?");
  $sth->execute($userid);
  my $me = {};
  my $addr;
  if ($sth->rows > 0) {
    ($addr) = $sth->fetchrow_array;
  }
  if ($addr) {
    $me->{address} = $addr;
    $me->{is_secret} = 1;
  } else {
    $sth = $dbh->prepare("SELECT email FROM users WHERE userid=?");
    $sth->execute($userid);
    if ($sth->rows >= 0){
      ($me->{address}) = $sth->fetchrow_array;
    }
    $me->{address} ||= "$userid\@cpan.org";
  }
  bless $me, $class;
}

sub address { shift->{address} }
sub is_secret { shift->{is_secret} }

1;
