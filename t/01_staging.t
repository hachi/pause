
use LWP::UserAgent;
use Sys::Hostname qw(hostname);
use utf8;

{
    my $ua;
    sub _ua {
        return $ua if $ua;
        $ua = LWP::UserAgent->new
            (
             keep_alive => 1,
            );
        $ua->parse_head(0);
        $ua;
    }
}
my $root;
$|=1;
BEGIN {
    unshift @INC, './lib', './t';

    my $exit_message;
    my $hostname = hostname;
    if ($hostname =~ /^k(75|81)/) {
        my $h = $1;
        $root = "http://andk:ddd\@$hostname:8406";
        my $resp = _ua->get("$root/pause/query");
        unless ($resp->is_success) {
            my $apache;
            for $path ("/home/src/apache/apachebin/1.3.41/bin/httpd",
                       "/home/src/www/apache/apachebin/1.3.37/bin/httpd") {
                if ( -f $path ) {
                    $apache = $path;
                    last;
                }
            }
            $exit_message = sprintf "local staging host not running, maybe try 'sudo %s -f  `pwd`/apache-conf/httpd.conf.pause.atk%s' (watch error log '...')", $apache, $h;
        }
    } else {
        $exit_message = sprintf "unknown staging host[%s]", hostname;
    }
    if ($exit_message) {
        $|=1;
        print "1..0 # SKIP $exit_message\n";
        eval "require POSIX; 1" and POSIX::_exit(0);
    }
}
my $tests;
BEGIN { $tests = 0 }
use Test::More;

{
    BEGIN { $tests+=2 }
    my $resp = _ua->get("$root/pause/authenquery");
    ok $resp->is_success, "Got root[$root]";
    like $resp->decoded_content, qr/Hi Andreas J. König,/, "Saw name of Andreas Koenig";
}

{
    BEGIN { $tests+=1 }
    my $resp = _ua->get("$root/pause/authenquery?HIDDENNAME=ANDK&pause99_apply_mod_modid=Test%3A%3APlease%3A%3AIgnore&pause99_apply_mod_chapterid=15&pause99_apply_mod_statd=i&pause99_apply_mod_stats=n&pause99_apply_mod_statl=p&pause99_apply_mod_stati=p&pause99_apply_mod_statp=o&pause99_apply_mod_description=Test%2C+please+ignore&pause99_apply_mod_communities=Registration+links&pause99_apply_mod_similar=Registration+links&pause99_apply_mod_rationale=Have+you+had+your+pill+today%3F&SUBMIT_pause99_apply_mod_send=+Submit+to+modules%40perl.org+");
    my($url,$sid) = $resp->decoded_content =~ /(https:.*USERID=([[:xdigit:]]+)_\S+?)"/;
    $sid =~ s/0+$//;
    my $rsid = scalar reverse $sid;
    ok $rsid gt 0, "Found a (reversed) session ID of '$rsid' in '$url'";
}

{
    BEGIN { $tests+=1 }
    my $resp = _ua->get("$root/pause/query?ACTION=who_pumpkin;OF=YAML");
    like $resp->decoded_content, qr/\bJHI\b/, "found the 5.8++ pumpkin";
}

BEGIN { plan tests => $tests }

# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# End:
