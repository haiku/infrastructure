#!/usr/bin/perl -w
#
# Tool to send git commit notifications
#
# Copyright 2005 Alexandre Julliard
# Copyright 2011 Oliver Tappe
# Copyright 2017 Alexander von Gluck IV
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
#
# This script is meant to be called from .git/hooks/post-receive.
#
# Usage: git-notify [options] [--] old-sha1 new-sha1 refname
#
#   -d        Debug mode, do not send any notifications, just print them to stdout
#   -m addr   Send mail notifications to specified address
#   -n max    Set max number of individual notices to send
#   -r name   Set the git repository name
#   -s bytes  Set the maximum diff size in bytes (-1 for no limit)
#   -u url    Set the URL to the cgit browser
#   -i branch If at least one -i is given, report only for specified branches
#   -x branch Exclude changes to the specified branch from reports
#   -X        Exclude merge commits
#

use strict;
use warnings;
use open ':utf8';
use Cwd 'realpath';
use Encode qw(decode);

use LWP::UserAgent;

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';

sub git_config($);
sub get_repos_name();

# some parameters you may want to change

# debug mode
my $debug = 0;

# length of short git shas (in characters)
my $shortGitObjLength = 12;

# configuration parameters

# base URL of the cgit repository browser (can be set with the -u option)
my $cgit_url = git_config( "notify.baseurl" );

# irc channels to notify
my $irc_channels = git_config( "notify.irc" ) || "#haiku-dev";

# default repository name (can be changed with the -r option)
my $repos_name = git_config( "notify.repository" ) || get_repos_name();

# max size of diffs in lines (can be changed with the -l option)
my $max_diff_lines = git_config( "notify.maxdifflines" ) || 1000;

# max size of stats in lines (can be changed with the -s option)
my $max_stats_lines = git_config( "notify.maxstatslines" ) || 250;

# address for mail notices (can be set with -m option)
my $commitlist_address = git_config( "notify.mail" );

# max number of individual notices before falling back to a single global notice (can be set with -n option)
# [zooey]: we always use global notices
my $max_notices = git_config( "notify.maxnotices" ) || 0;

# base name of revision tag
my $revision_tag = git_config( "notify.revisionTag" );

# branches to include
my @include_list = split /\s+/, git_config( "notify.include" ) || "";

# branches to exclude
my @exclude_list = split /\s+/, git_config( "notify.exclude" ) || "";

# Extra options to git rev-list
my @revlist_options;

# maps objects to their info
my %objectInfoMap;

sub usage()
{
    print "Usage: $0 [options] [--] old-sha1 new-sha1 refname\n";
    print "   -d        Debug mode, do not send any notifications, just print them to stdout\n";
    print "   -l lines  Set the maximum diff size in lines (-1 for no limit)\n";
    print "   -m addr   Send mail notifications to specified address\n";
    print "   -n max    Set max number of individual mails to send\n";
    print "   -r name   Set the git repository name\n";
    print "   -s lines  Set the maximum stats size in lines (-1 for no limit)\n";
    print "   -u url    Set the URL to the cgit browser\n";
    print "   -i branch If at least one -i is given, report only for specified branches\n";
    print "   -x branch Exclude changes to the specified branch from reports\n";
    print "   -X        Exclude merge commits\n";
    exit 1;
}

sub xml_escape($)
{
    my $str = shift;
    $str =~ s/&/&amp;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    my @chars = unpack "U*", $str;
    $str = join "", map { ($_ > 127) ? sprintf "&#%u;", $_ : chr($_); } @chars;
    return $str;
}

# format an integer date + timezone as string
# algorithm taken from git's date.c
sub format_date($$)
{
    my ($time,$tz) = @_;

    return gmtime($time) . ' UTC';

#    if ($tz < 0)
#    {
#        my $minutes = (-$tz / 100) * 60 + (-$tz % 100);
#        $time -= $minutes * 60;
#    }
#    else
#    {
#        my $minutes = ($tz / 100) * 60 + ($tz % 100);
#        $time += $minutes * 60;
#    }
#    return gmtime($time) . sprintf " %+05d", $tz;
}

# fetch a parameter from the git config file
sub git_config($)
{
    my ($param) = @_;

    open CONFIG, "-|" or exec "git", "config", $param;
    my $ret = <CONFIG>;
    chomp $ret if $ret;
    close CONFIG or $ret = undef;
    return $ret;
}

# parse command line options
sub parse_options()
{
    while (@ARGV && $ARGV[0] =~ /^-/)
    {
        my $arg = shift @ARGV;

        if ($arg eq '--') { last; }
        elsif ($arg eq '-l') { $max_diff_lines = shift @ARGV; }
        elsif ($arg eq '-m') { $commitlist_address = shift @ARGV; }
        elsif ($arg eq '-n') { $max_notices = shift @ARGV; }
        elsif ($arg eq '-r') { $repos_name = shift @ARGV; }
        elsif ($arg eq '-s') { $max_stats_lines = shift @ARGV; }
        elsif ($arg eq '-u') { $cgit_url = shift @ARGV; }
        elsif ($arg eq '-i') { push @include_list, shift @ARGV; }
        elsif ($arg eq '-x') { push @exclude_list, shift @ARGV; }
        elsif ($arg eq '-X') { push @revlist_options, "--no-merges"; }
        elsif ($arg eq '-d') { $debug++; }
        else { usage(); }
    }
    if (@ARGV && $#ARGV != 2) { usage(); }
    @exclude_list = map { "^$_"; } @exclude_list;
}

# send IRC notification via irccat
sub irc_notification
{
    my ($message) = @_;

    return unless $message;

    if ($debug)
    {
        print "IrcCat: \n$message\n";
        return;
    }

    open my $fh, '<', "/run/secrets/irccat/password"
      or die "Could not open /run/secrets/irccat/password for reading: $!";
    my $password = do { local $/; <$fh> };

    #my @lines = split /\n/, $message, 15
    foreach ( split /\n/, $message, 15 ) {
      my $ua = LWP::UserAgent->new;
      my $req = HTTP::Request->new(POST => "http://irccat/send");
      $req->header('Authorization' => "Bearer $password");
      $req->header('Content-Type' => 'application/x-www-form-urlencoded');
      $req->content("$irc_channels $_");
      $ua->request($req);
    }
}

# send an email notification
sub mail_notification($$$@)
{
    my ($target, $subject, $content_type, @body) = @_;

    my $committer = decode('UTF-8', $ENV{USER}, Encode::FB_CROAK | Encode::LEAVE_SRC);
    my $mail_from = decode('UTF-8', $ENV{USER_EMAIL}, Encode::FB_CROAK | Encode::LEAVE_SRC);
    if (!length($mail_from))
    {
        $mail_from = "$committer\@git.haiku-os.org";
    }

    my @head;
    push(@head, "To: $target\n");
    push(@head, "From: $mail_from\n");
    push(@head, "Subject: $subject\n");

    push(@head, "Content-Type: $content_type\n");
    push(@head, "Content-Transfer-Encoding: 8bit\n");

    push(@head, "\n");

    if ($debug)
    {
        print "---------------------\n";
        print @head, join("\n", @body), "\n";
    }
    else
    {
        # Open a pipe to sendmail.
        my $command = "/usr/sbin/sendmail -S smtp:25 -oi '$target' -f '$mail_from'";
        if (open(SENDMAIL, "| $command"))
        {
            print SENDMAIL @head, map { "$_\n" } @body;
            close SENDMAIL
              or warn "$0: error in closing `$command' for writing: $!\n";
        }
        else
        {
            warn "$0: cannot open `| $command' for writing: $!\n";
        }
    }
}

# get the default repository name
sub get_repos_name()
{
    my $dir = `git rev-parse --git-dir`;
    chomp $dir;
    my $repos = realpath($dir);
    $repos =~ s/(.*?)((\.git\/)?\.git)$/$1/;
    $repos =~ s/(.*)\/([^\/]+)\/?$/$2/;
    return $repos;
}

# extract the information from a commit or tag object and return a hash containing the various fields
sub get_object_info($)
{
    my $obj = shift;
    my %info = ();
    my @log = ();
    my $do_log = 0;

    open TYPE, "-|" or exec "git", "cat-file", "-t", $obj or die "cannot run git-cat-file";
    my $type = <TYPE>;
    chomp $type;
    close TYPE;

    open OBJ, "-|" or exec "git", "cat-file", $type, $obj or die "cannot run git-cat-file";
    while (<OBJ>)
    {
        chomp;
        if ($do_log)
        {
            last if /^-----BEGIN PGP SIGNATURE-----/;
            push @log, $_;
        }
        elsif (/^(author|committer|tagger) ((.*)(<.*>)) (\d+) ([+-]\d+)$/)
        {
            $info{$1} = $2;
            $info{$1 . "_name"} = $3;
            $info{$1 . "_email"} = $4;
            $info{$1 . "_date"} = $5;
            $info{$1 . "_tz"} = $6;
        }
        elsif (/^tag (.*)$/)
        {
            $info{"tag"} = $1;
        }
        elsif (/^$/) { $do_log = 1; }
    }
    close OBJ;

    $info{"type"} = $type;
    $info{"log"} = \@log;

    return \%info;
}

# add revision tag to commit and return it
sub add_revision_tag_to_commit($$)
{
    my ($obj, $ref) = @_;

    if (!$revision_tag) {
        return '';
    }


    # add branch name to 'hrev' unless we're dealing with 'master':
    my $tagBase = $ref eq 'master' ? $revision_tag : "$revision_tag$ref";

    my $gitDir = `git rev-parse --git-dir`;
    chomp $gitDir;

    open(my $revFH, "<", "$gitDir/$tagBase") or die "cannot open '$gitDir/$tagBase' for reading ($!)";
    my $r = <$revFH>;
    close $revFH;
    $r++;
    my $revision = $ref eq 'master' ? "$tagBase$r" : "$tagBase-$r";

    return $revision if $debug;

    if (system(qq{echo "$obj" "refs/tags/$revision" >>"$gitDir/packed-refs"}) != 0)
    {
        die "unable to add tag '$revision' to commit '$obj'!";
    }

    open($revFH, ">", "$gitDir/$tagBase") or die "cannot open '$gitDir/$tagBase' for writing ($!)";
    print $revFH "$r\n";
    close $revFH;

    return $revision;
}

#
sub summarize_changed_dirs($)
{
    my ($objRange) = @_;

    my @dirschanged = map {
        m{(\S+)/$} ? ($1) : ();
    } qx{git diff-tree --no-commit-id --dirstat $objRange | sort -r -n | head -n 5};

    # Collapse the list of changed directories
    my $commondir;
    if (@dirschanged > 1)
    {
        my $firstline = shift @dirschanged;
        my @commonpieces = split('/', $firstline);
        foreach my $line (@dirschanged)
        {
            my @pieces = split('/', $line);
            my $i = 0;
            while ($i < @pieces and $i < @commonpieces)
            {
                if ($pieces[$i] ne $commonpieces[$i])
                {
                    splice(@commonpieces, $i, @commonpieces - $i);
                    last;
                }
                $i++;
            }
        }
        unshift(@dirschanged, $firstline);
        if (@commonpieces)
        {
            $commondir = join('/', @commonpieces);
            my @new_dirschanged;
            foreach my $dir (@dirschanged)
            {
                if ($dir eq $commondir)
                {
                    $dir = '.';
                }
                else
                {
                    $dir =~ s#^$commondir/##;
                }
                push(@new_dirschanged, $dir);
            }
            @dirschanged = @new_dirschanged;
        }
    }
    elsif (!@dirschanged)
    {
        push @dirschanged, '/';
    }

    my $changedDirsString = $commondir ? "in $commondir: " : '';
    $changedDirsString .= join(' ', @dirschanged);

    return $changedDirsString;
}

sub do_stats($$)
{
    my ($objRange, $flags) = @_;

    my @stats = map {
        s{^\s*(.*?)\s*$}{$1}; $_
    } qx{git diff-tree --stat=76 -M --no-commit-id $objRange};

    if (@stats)
    {
        unshift @stats, pop @stats;
            # bring summary line to front
    }

    if ($flags->{max_lines} >= 0 && @stats > $flags->{max_lines})
    {
        my $stats_lines = @stats;
        $#stats = $flags->{max_lines} - 1;
        if (@stats)
        {
            my $dropped_lines = $stats_lines - @stats;
            push @stats, "[ *** stats truncated: $dropped_lines lines dropped *** ]";
        }
    }

    return @stats;
}

# prepare text of a commit notice
sub prepare_commit_notice($$$$)
{
    my ($refInfo, $obj, $revision, $flags) = @_;

    my %info = %{$objectInfoMap{$obj}};
    my @notice = ();
    my $subject;

    my $shortObj = substr($obj, 0, $shortGitObjLength); # abbreviated SHA1 hash
    my $logStr = join "\n", @{$info{log}};

    my @committerInfo = ();
    if ($info{committer} ne $info{author})
    {
        push @committerInfo, qq{Committer:   $info{committer}};
        push @committerInfo, 'Commit-Date: ' . format_date($info{"committer_date"},$info{"committer_tz"});
    }

    my @ticketInfo = ();
    my %seenTicket;
    while($logStr =~ m[#(\d+)]g)
    {
        $seenTicket{$1} = 1;
    }
    foreach my $ticketNr (sort { $a <=> $b } keys %seenTicket)
    {
        push @ticketInfo, "Ticket:      https://dev.haiku-os.org/ticket/$ticketNr";
    }
    push @ticketInfo, '' if @ticketInfo;

    if ($info{"type"} eq "tag")
    {
        push @notice,
        "Tag:    $obj",
        $cgit_url ? "URL:    $cgit_url/tag/?id=$shortObj" : "",
        "Tagger: " . $info{"tagger"},
        "Date:   " . format_date($info{"tagger_date"},$info{"tagger_tz"}),
        '',
        @ticketInfo,
        $logStr;
        my $firstLogLine = ${$info{log}}[0];
        $subject = qq{$repos_name.$info{tag}: $firstLogLine};
    }
    else
    {
        push(@notice, "Revision:    $revision") if defined $revision && length($revision) > 0;
        push @notice,
        "Commit:      $obj",
        $cgit_url ? "URL:         $cgit_url/commit/?id=$shortObj" : "",
        "Author:      " . $info{"author"},
        "Date:        " . format_date($info{"author_date"},$info{"author_tz"}),
        @committerInfo,
        "",
        @ticketInfo,
        $flags->{suppressLog} ? () : ($logStr, ''),
        '-' x 76,
        '';

        if ($flags->{doStats})
        {
            my @stats = do_stats($obj, { max_lines => $max_stats_lines });
            if (@stats)
            {
                push @notice, @stats, '', '-' x 76, '';
            }
        }

        if ($flags->{doDiff} && ($max_diff_lines <= 0 || $refInfo->{diff_lines} < $max_diff_lines))
        {
            open DIFF, "-|" or exec "git", "diff-tree", "-p", "-M", "--no-commit-id", $obj or die "cannot exec git-diff-tree";
            my @diff;
            my $diff_lines;
            if ($max_diff_lines <= 0) {
                @diff = map { chomp; $_ } <DIFF>;
                $diff_lines = @diff;
            }
            else {
                # read only the number of lines we need and count (but otherwise ignore) the rest
                my $lineLimit = $max_diff_lines - $refInfo->{diff_lines};
                $#diff = $lineLimit - 1;
                $diff_lines = 0;
                my $line;
                while ($diff_lines < $lineLimit && ($line = <DIFF>)) {
                    chomp $line;
                    $diff[$diff_lines++] = $line;
                }
                $#diff = $diff_lines - 1;
                while (<DIFF>) {
                    ++$diff_lines;
                }
            }
            close DIFF;

            if ($refInfo->{diff_lines} + $diff_lines > $max_diff_lines)
            {
                my $dropped_lines = $diff_lines - @diff;
                push @diff, "\n[ *** diff truncated: $dropped_lines lines dropped *** ]\n";
            }
            $refInfo->{diff_lines} += @diff;
            if (@diff)
            {
                push @notice, @diff, '';
            }
        }

        if ($flags->{doDirs})
        {
            my $changedDirsString = summarize_changed_dirs($obj);

            my $branchSpec = $refInfo->{branch} eq 'master' ? '' : ".$refInfo->{branch}";
            $subject = qq{$repos_name$branchSpec: $revision - $changedDirsString};
        }

        if ($flags->{doOverview})
        {
            $refInfo->{overview} ||= [];
            push @{$refInfo->{overview}}, {
                shortObj => $shortObj,
                log      => $info{log},
                author   => $info{author},
            };
        }
    }

    return (\@notice, $subject, $revision);
}

# send a commit notice to a mailing list
sub send_commit_notice($$$)
{
    my ($refInfo, $obj, $revision) = @_;

    my ($notice, $subject) = prepare_commit_notice($refInfo, $obj, $revision, { doStats => 1, doDiff => 1, doDirs => 1 });

    mail_notification($commitlist_address, $subject, "text/plain; charset=UTF-8", @$notice);
}

# create and return a commit notice for Irker
sub prepare_irc_notice($$)
{
    my ($refInfo, $commits) = @_;

    my $revision = $refInfo->{revision};
    my $shortFrom = substr($refInfo->{oldSha1}, 0, $shortGitObjLength);
    my $shortTo = substr($refInfo->{newSha1}, 0, $shortGitObjLength);
    my $commitCount = @$commits;
    my $commitCountString = $commitCount == 1 ? '%GREEN1%NORMAL commit' : "%GREEN$commitCount%NORMAL commits";
    my @irc_text = ( "[%BLUEhaiku/$repos_name%NORMAL] %ORANGE$ENV{USER}%NORMAL pushed $commitCountString to %GREEN$refInfo->{branch}%NORMAL [$revision] - $cgit_url/log/?qt=range&q=$shortTo+%5E$shortFrom" );

    foreach my $commit (@$commits) {
        my $info = $objectInfoMap{$commit};
        my $shortObj = substr($commit, 0, $shortGitObjLength);

        push @irc_text, "[%BLUEhaiku/$repos_name%NORMAL]    %GREEN$shortObj%NORMAL - " . $info->{"log"}->[0];

        if (@irc_text == 10) {
            push @irc_text, '    ...';
            last;
        }
    }

    return join "\n", @irc_text;
}

# send a global commit notice when there are too many commits for individual mails
sub send_global_notice($$)
{
    my ($refInfo, $commits) = @_;

    my $objRange = "$refInfo->{oldSha1}..$refInfo->{newSha1}";
    my $changedDirsString = summarize_changed_dirs($objRange);

    my @allNotices;
    foreach my $commit (@$commits)
    {
        my ($notice, $subject) = prepare_commit_notice(
            $refInfo, $commit,
            $commit eq $refInfo->{newSha1} ? $refInfo->{revision} : '',
            { doDiff => 1, doOverview => 1, doStats => @$commits == 1 ? 1 : 0, suppressLog => @$commits == 1 ? 1 : 0 }
        );

        push (@allNotices, '#' x 76, '') if @allNotices;
        push @allNotices, @$notice;
    }

    # prepare overview
    my $shortFrom = substr($refInfo->{oldSha1}, 0, $shortGitObjLength);
    my $shortTo = substr($refInfo->{newSha1}, 0, $shortGitObjLength);
    my @overview = (
        "$refInfo->{revision} adds " . @$commits . (@$commits > 1 ? ' changesets' : ' changeset' ) . " to branch '$refInfo->{branch}'",
        "old head: $refInfo->{oldSha1}",
        "new head: $refInfo->{newSha1}",
        "overview: $cgit_url/log/?qt=range&q=$shortTo+%5E$shortFrom",
        '',
        '-' x 76,
        '',
    );

    my %authors = map { ($_->{author}, 1) } @{$refInfo->{overview}};
    if (keys %authors > 1) {
        push @overview, map {
            my $author = "[ $_->{author} ]";
            (
                "$_->{shortObj}: " . join("\n  ", @{$_->{log}}),
                '',
                ' ' x (76 - length($author)) . $author,
                ''
            )
        } @{$refInfo->{overview}};
    }
    else {
        push @overview, map {
            (
                "$_->{shortObj}: " . join("\n  ", @{$_->{log}}),
                ''
            )
        } @{$refInfo->{overview}};
        my ($author) = map { "[ $_ ]" } keys %authors;
        push @overview, ' ' x (76 - length($author)) . $author, '';
    }
    push @overview, '-' x 76, '';

    if (@$commits > 1) {
        push @overview, (
            do_stats($objRange, { max_lines => $max_stats_lines }),
            '',
            '#' x 76,
            '',
        );
    }

    unshift(@allNotices, @overview);

    my $branchSpec = $refInfo->{branch} eq 'master' ? '' : ".$refInfo->{branch}";
    my $subject = qq{$repos_name$branchSpec: $refInfo->{revision} - $changedDirsString};
    mail_notification($commitlist_address, $subject, "text/plain; charset=UTF-8", @allNotices);

    my $ircNotice = prepare_irc_notice( $refInfo, $commits);
    irc_notification($ircNotice);
}

sub find_branch_for_ref($)
{
    my ($ref) = @_;
    my $branch = "";

    if ($ref =~ m/refs\/heads\//) {
        print "Detected direct commit to branch.\n";
        $branch = $ref;
        $branch =~ s/refs\/heads\///;
    }
    die "unable to determine '$ref' to branch linkage!\n" unless $branch ne "";
    $branch =~ s/^\s+|\s+$//g;
    print "Determined that branch is '$branch' from '$ref'!\n";
    return $branch;
}

# gather all commits that have been pushed for given ref
sub gather_commits_for_ref($$$)
{
    my ($old_sha1, $new_sha1, $ref) = @_;

    return if (@include_list && !grep {$_ eq $ref} @include_list);

    # fetch heads from all other branches in order to limit the list of commits to the ones that are not referred to
    # by any other ref yet (as opposed to all commits not known in current ref, which can yield a huge number
    # of commits for a new ref!)
    my $otherBranches = join ' ', map { chomp; $_ } qx{git for-each-ref --format='%(refname)' refs/heads/ | grep -F -v $ref };
    my @oldCommits = map { chomp; $_ } qx{git rev-parse --not $otherBranches};
    my @revlist_args = ('--topo-order', '--reverse', @revlist_options);
    push @revlist_args, "^$old_sha1" unless $old_sha1 eq '0' x 40;  # new ref
    push @revlist_args, "$new_sha1", @oldCommits, @exclude_list;

    open LIST, "-|" or exec "git", "rev-list", @revlist_args or die "cannot exec git-rev-list";
    my @commits = map
    {
        chomp;
        die "invalid commit $_" unless /^[0-9a-f]{40}$/;
        $_;
    } <LIST>;
    close LIST;

    return \@commits;
}

# send the notices for given ref
sub send_notices_for_ref($$)
{
    my ($refInfo, $commits) = @_;

    if (@$commits > $max_notices)
    {
        send_global_notice( $refInfo, $commits ) if $commitlist_address;
        return;
    }

    foreach my $commit (@$commits)
    {
        send_commit_notice( $refInfo, $commit, $commit eq $refInfo->{newSha1} ? $refInfo->{revision} : '' ) if $commitlist_address;
    }
}

parse_options();

my @refInfos;

if (@ARGV)
{
    push @refInfos,
    {
        'oldSha1' => $ARGV[0],
        'newSha1' => $ARGV[1],
        'ref'     => $ARGV[2]
    };
}
else  # read them from stdin
{
    while (<>)
    {
        chomp;
        next unless /^([0-9a-f]{40}) ([0-9a-f]{40}) (.*)$/;

        push @refInfos,
        {
            'oldSha1' => $1,
            'newSha1' => $2,
            'ref'     => $3
        };
    }
}

my @allCommits;
foreach my $refInfo (@refInfos)
{
    print "Processing '$refInfo->{ref}'...";
    $refInfo->{diff_lines} = 0;
    $refInfo->{branch} = find_branch_for_ref($refInfo->{ref});
    $refInfo->{commits} = gather_commits_for_ref($refInfo->{oldSha1}, $refInfo->{newSha1}, $refInfo->{branch});
    $refInfo->{revision} = add_revision_tag_to_commit($refInfo->{newSha1}, $refInfo->{branch});

    print "$refInfo->{ref} -> $refInfo->{revision} on $refInfo->{branch}\n";

    push @allCommits, @{$refInfo->{commits}};
}

foreach my $commit (@allCommits)
{
    $objectInfoMap{$commit} = get_object_info($commit);
}

foreach my $refInfo (@refInfos)
{
    send_notices_for_ref($refInfo, $refInfo->{commits});
}

exit 0;

