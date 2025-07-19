package DB;

# Debugger for Perl 5.00x; perl5db.pl patch level:

$VERSION = 1.07;
$header = "perl5db.pl version $VERSION";

#
# This file is automatically included if you do perl -d.
# It's probably not useful to include this yourself.
#
# Perl supplies the values for %sub.  It effectively inserts
# a &DB'DB(); in front of every place that can have a
# breakpoint. Instead of a subroutine call it calls &DB::sub with
# $DB::sub being the called subroutine. It also inserts a BEGIN
# {require 'perl5db.pl'} before the first line.
#
# After each `require'd file is compiled, but before it is executed, a
# call to DB::postponed($main::{'_<'.$filename}) is emulated. Here the
# $filename is the expanded name of the `require'd file (as found as
# value of %INC).
#
# Additional services from Perl interpreter:
#
# if caller() is called from the package DB, it provides some
# additional data.
#
# The array @{$main::{'_<'.$filename}} is the line-by-line contents of
# $filename.
#
# The hash %{'_<'.$filename} contains breakpoints and action (it is
# keyed by line number), and individual entries are settable (as
# opposed to the whole hash). Only true/false is important to the
# interpreter, though the values used by perl5db.pl have the form
# "$break_condition\0$action". Values are magical in numeric context.
#
# The scalar ${'_<'.$filename} contains $filename.
#
# Note that no subroutine call is possible until &DB::sub is defined
# (for subroutines defined outside of the package DB). In fact the same is
# true if $deep is not defined.
#

#
# At start reads $rcfile that may set important options.  This file
# may define a subroutine &afterinit that will be executed after the
# debugger is initialized.
#
# After $rcfile is read reads environment variable PERLDB_OPTS and parses
# it as a rest of `O ...' line in debugger prompt.
#
# The options that can be specified only at startup:
# [To set in $rcfile, call &parse_options("optionName=new_value").]
#
# TTY  - the TTY to use for debugging i/o.
#
# noTTY - if set, goes in NonStop mode.  On interrupt if TTY is not set
# uses the value of noTTY or "/tmp/perldbtty$$" to find TTY using
# Term::Rendezvous.  Current variant is to have the name of TTY in this
# file.
#
# ReadLine - If false, dummy ReadLine is used, so you can debug
# ReadLine applications.
#
# NonStop - if true, no i/o is performed until interrupt.
#
# LineInfo - file or pipe to print line number info to.  If it is a
# pipe, a short "emacs like" message is used.
#
# RemotePort - host:port to connect to on remote host for remote debugging.
#
# Example $rcfile: (delete leading hashes!)
#
# &parse_options("NonStop=1 LineInfo=db.out");
# sub afterinit { $trace = 1; }
#
# The script will run without human intervention, putting trace
# information into db.out.  (If you interrupt it, you would better
# reset LineInfo to something "interactive"!)
#
##################################################################

# Enhanced by ilya@math.ohio-state.edu (Ilya Zakharevich)
# Latest version available: ftp://ftp.math.ohio-state.edu/pub/users/ilya/perl

# modified Perl debugger, to be run from Emacs in perldb-mode
# Ray Lischner (uunet!mntgfx!lisch) as of 5 Nov 1990
# Johan Vromans -- upgrade to 4.0 pl 10
# Ilya Zakharevich -- patches after 5.001 (and some before ;-)

# Changelog:

# A lot of things changed after 0.94. First of all, core now informs
# debugger about entry into XSUBs, overloaded operators, tied operations,
# BEGIN and END. Handy with `O f=2'.

# This can make debugger a little bit too verbose, please be patient
# and report your problems promptly.

# Now the option frame has 3 values: 0,1,2.

# Note that if DESTROY returns a reference to the object (or object),
# the deletion of data may be postponed until the next function call,
# due to the need to examine the return value.

# Changes: 0.95: `v' command shows versions.
# Changes: 0.96: `v' command shows version of readline.
#	primitive completion works (dynamic variables, subs for `b' and `l',
#		options). Can `p %var'
#	Better help (`h <' now works). New commands <<, >>, {, {{.
#	{dump|print}_trace() coded (to be able to do it from <<cmd).
#	`c sub' documented.
#	At last enough magic combined to stop after the end of debuggee.
#	!! should work now (thanks to Emacs bracket matching an extra
#	`]' in a regexp is caught).
#	`L', `D' and `A' span files now (as documented).
#	Breakpoints in `require'd code are possible (used in `R').
#	Some additional words on internal work of debugger.
#	`b load filename' implemented.
#	`b postpone subr' implemented.
#	now only `q' exits debugger (overwriteable on $inhibit_exit).
#	When restarting debugger breakpoints/actions persist.
#     Buglet: When restarting debugger only one breakpoint/action per 
#		autoloaded function persists.
# Changes: 0.97: NonStop will not stop in at_exit().
#	Option AutoTrace implemented.
#	Trace printed differently if frames are printed too.
#	new `inhibitExit' option.
#	printing of a very long statement interruptible.
# Changes: 0.98: New command `m' for printing possible methods
#	'l -' is a synonim for `-'.
#	Cosmetic bugs in printing stack trace.
#	`frame' & 8 to print "expanded args" in stack trace.
#	Can list/break in imported subs.
#	new `maxTraceLen' option.
#	frame & 4 and frame & 8 granted.
#	new command `m'
#	nonstoppable lines do not have `:' near the line number.
#	`b compile subname' implemented.
#	Will not use $` any more.
#	`-' behaves sane now.
# Changes: 0.99: Completion for `f', `m'.
#	`m' will remove duplicate names instead of duplicate functions.
#	`b load' strips trailing whitespace.
#	completion ignores leading `|'; takes into account current package
#	when completing a subroutine name (same for `l').
# Changes: 1.07: Many fixed by tchrist 13-March-2000
#   BUG FIXES:
#   + Added bare mimimal security checks on perldb rc files, plus
#     comments on what else is needed.
#   + Fixed the ornaments that made "|h" completely unusable.
#     They are not used in print_help if they will hurt.  Strip pod
#     if we're paging to less.
#   + Fixed mis-formatting of help messages caused by ornaments
#     to restore Larry's original formatting.  
#   + Fixed many other formatting errors.  The code is still suboptimal, 
#     and needs a lot of work at restructuing. It's also misindented
#     in many places.
#   + Fixed bug where trying to look at an option like your pager
#     shows "1".  
#   + Fixed some $? processing.  Note: if you use csh or tcsh, you will
#     lose.  You should consider shell escapes not using their shell,
#     or else not caring about detailed status.  This should really be
#     unified into one place, too.
#   + Fixed bug where invisible trailing whitespace on commands hoses you,
#     tricking Perl into thinking you wern't calling a debugger command!
#   + Fixed bug where leading whitespace on commands hoses you.  (One
#     suggests a leading semicolon or any other irrelevant non-whitespace
#     to indicate literal Perl code.)
#   + Fixed bugs that ate warnings due to wrong selected handle.
#   + Fixed a precedence bug on signal stuff.
#   + Fixed some unseemly wording.
#   + Fixed bug in help command trying to call perl method code.
#   + Fixed to call dumpvar from exception handler.  SIGPIPE killed us.
#   ENHANCEMENTS:
#   + Added some comments.  This code is still nasty spaghetti.
#   + Added message if you clear your pre/post command stacks which was
#     very easy to do if you just typed a bare >, <, or {.  (A command
#     without an argument should *never* be a destructive action; this
#     API is fundamentally screwed up; likewise option setting, which
#     is equally buggered.)
#   + Added command stack dump on argument of "?" for >, <, or {.
#   + Added a semi-built-in doc viewer command that calls man with the
#     proper %Config::Config path (and thus gets caching, man -k, etc),
#     or else perldoc on obstreperous platforms.
#   + Added to and rearranged the help information.
#   + Detected apparent misuse of { ... } to declare a block; this used
#     to work but now is a command, and mysteriously gave no complaint.

####################################################################

# Needed for the statement after exec():

BEGIN { $ini_warn = $^W; $^W = 0 } # Switch compilation warnings off until another BEGIN.
local($^W) = 0;			# Switch run-time warnings off during init.
warn (			# Do not ;-)
      $dumpvar::hashDepth,     
      $dumpvar::arrayDepth,    
      $dumpvar::dumpDBFiles,   
      $dumpvar::dumpPackages,  
      $dumpvar::quoteHighBit,  
      $dumpvar::printUndef,    
      $dumpvar::globPrint,     
      $dumpvar::usageOnly,
      @ARGS,
      $Carp::CarpLevel,
      $panic,
      $second_time,
     ) if 0;

# Command-line + PERLLIB:
@ini_INC = @INC;

# $prevwarn = $prevdie = $prevbus = $prevsegv = ''; # Does not help?!

$trace = $signal = $single = 0;	# Uninitialized warning suppression
                                # (local $^W cannot help - other packages!).
$inhibit_exit = $option{PrintRet} = 1;

@options     = qw(hashDepth arrayDepth DumpDBFiles DumpPackages DumpReused
		  compactDump veryCompact quote HighBit undefPrint
		  globPrint PrintRet UsageOnly frame AutoTrace
		  TTY noTTY ReadLine NonStop LineInfo maxTraceLen
		  recallCommand ShellBang pager tkRunning ornaments
		  signalLevel warnLevel dieLevel inhibit_exit
		  ImmediateStop bareStringify
		  RemotePort);

%optionVars    = (
		 hashDepth	=> \$dumpvar::hashDepth,
		 arrayDepth	=> \$dumpvar::arrayDepth,
		 DumpDBFiles	=> \$dumpvar::dumpDBFiles,
		 DumpPackages	=> \$dumpvar::dumpPackages,
		 DumpReused	=> \$dumpvar::dumpReused,
		 HighBit	=> \$dumpvar::quoteHighBit,
		 undefPrint	=> \$dumpvar::printUndef,
		 globPrint	=> \$dumpvar::globPrint,
		 UsageOnly	=> \$dumpvar::usageOnly,     
		 bareStringify	=> \$dumpvar::bareStringify,
		 frame          => \$frame,
		 AutoTrace      => \$trace,
		 inhibit_exit   => \$inhibit_exit,
		 maxTraceLen	=> \$maxtrace,
		 ImmediateStop	=> \$ImmediateStop,
		 RemotePort	=> \$remoteport,
);

%optionAction  = (
		  compactDump	=> \&dumpvar::compactDump,
		  veryCompact	=> \&dumpvar::veryCompact,
		  quote		=> \&dumpvar::quote,
		  TTY		=> \&TTY,
		  noTTY		=> \&noTTY,
		  ReadLine	=> \&ReadLine,
		  NonStop	=> \&NonStop,
		  LineInfo	=> \&LineInfo,
		  recallCommand	=> \&recallCommand,
		  ShellBang	=> \&shellBang,
		  pager		=> \&pager,
		  signalLevel	=> \&signalLevel,
		  warnLevel	=> \&warnLevel,
		  dieLevel	=> \&dieLevel,
		  tkRunning	=> \&tkRunning,
		  ornaments	=> \&ornaments,
		  RemotePort	=> \&RemotePort,
		 );

%optionRequire = (
		  compactDump	=> 'dumpvar.pl',
		  veryCompact	=> 'dumpvar.pl',
		  quote		=> 'dumpvar.pl',
		 );

# These guys may be defined in $ENV{PERL5DB} :
$rl		= 1	unless defined $rl;
$warnLevel	= 0	unless defined $warnLevel;
$dieLevel	= 0	unless defined $dieLevel;
$signalLevel	= 1	unless defined $signalLevel;
$pre		= []	unless defined $pre;
$post		= []	unless defined $post;
$pretype	= []	unless defined $pretype;

warnLevel($warnLevel);
dieLevel($dieLevel);
signalLevel($signalLevel);

&pager(
    (defined($ENV{PAGER}) 
	? $ENV{PAGER}
	: ($^O eq 'os2' 
	   ? 'cmd /c more' 
	   : 'more'))) unless defined $pager;
setman();
&recallCommand("!") unless defined $prc;
&shellBang("!") unless defined $psh;
$maxtrace = 400 unless defined $maxtrace;

if (-e "/dev/tty") {  # this is the wrong metric!
  $rcfile=".perldb";
} else {
  $rcfile="perldb.ini";
}

# This isn't really safe, because there's a race
# between checking and opening.  The solution is to
# open and fstat the handle, but then you have to read and
# eval the contents.  But then the silly thing gets
# your lexical scope, which is unfortunately at best.
sub safe_do { 
    my $file = shift;

    # Just exactly what part of the word "CORE::" don't you understand?
    local $SIG{__WARN__};  
    local $SIG{__DIE__};    

    unless (is_safe_file($file)) {
	CORE::warn <<EO_GRIPE;
perldb: Must not source insecure rcfile $file.
        You or the superuser must be the owner, and it must not 
	be writable by anyone but its owner.
EO_GRIPE
	return;
    } 

    do $file;
    CORE::warn("perldb: couldn't parse $file: $@") if $@;
}


# Verifies that owner is either real user or superuser and that no
# one but owner may write to it.  This function is of limited use
# when called on a path instead of upon a handle, because there are
# no guarantees that filename (by dirent) whose file (by ino) is
# eventually accessed is the same as the one tested. 
# Assumes that the file's existence is not in doubt.
sub is_safe_file {
    my $path = shift;
    stat($path) || return;	# mysteriously vaporized
    my($dev,$ino,$mode,$nlink,$uid,$gid) = stat(_);

    return 0 if $uid != 0 && $uid != $<;
    return 0 if $mode & 022;
    return 1;
}

if (-f $rcfile) {
    safe_do("./$rcfile");
} 
elsif (defined $ENV{HOME} && -f "$ENV{HOME}/$rcfile") {
    safe_do("$ENV{HOME}/$rcfile");
}
elsif (defined $ENV{LOGDIR} && -f "$ENV{LOGDIR}/$rcfile") {
    safe_do("$ENV{LOGDIR}/$rcfile");
}

if (defined $ENV{PERLDB_OPTS}) {
  parse_options($ENV{PERLDB_OPTS});
}

# Here begin the unreadable code.  It needs fixing.

if (exists $ENV{PERLDB_RESTART}) {
  delete $ENV{PERLDB_RESTART};
  # $restart = 1;
  @hist = get_list('PERLDB_HIST');
  %break_on_load = get_list("PERLDB_ON_LOAD");
  %postponed = get_list("PERLDB_POSTPONE");
  my @had_breakpoints= get_list("PERLDB_VISITED");
  for (0 .. $#had_breakpoints) {
    my %pf = get_list("PERLDB_FILE_$_");
    $postponed_file{$had_breakpoints[$_]} = \%pf if %pf;
  }
  my %opt = get_list("PERLDB_OPT");
  my ($opt,$val);
  while (($opt,$val) = each %opt) {
    $val =~ s/[\\\']/\\$1/g;
    parse_options("$opt'$val'");
  }
  @INC = get_list("PERLDB_INC");
  @ini_INC = @INC;
  $pretype = [get_list("PERLDB_PRETYPE")];
  $pre = [get_list("PERLDB_PRE")];
  $post = [get_list("PERLDB_POST")];
  @typeahead = get_list("PERLDB_TYPEAHEAD", @typeahead);
}

if ($notty) {
  $runnonstop = 1;
} else {
  # Is Perl being run from a slave editor or graphical debugger?
  $slave_editor = ((defined $main::ARGV[0]) and ($main::ARGV[0] eq '-emacs'));
  $rl = 0, shift(@main::ARGV) if $slave_editor;

  #require Term::ReadLine;

  if ($^O eq 'cygwin') {
    # /dev/tty is binary. use stdin for textmode
    undef $console;
  } elsif (-e "/dev/tty") {
    $console = "/dev/tty";
  } elsif ($^O eq 'dos' or -e "con" or $^O eq 'MSWin32') {
    $console = "con";
  } elsif ($^O eq 'MacOS') {
    if ($MacPerl::Version !~ /MPW/) {
      $console = "Dev:Console:Perl Debug"; # Separate window for application
    } else {
      $console = "Dev:Console";
    }
  } else {
    $console = "sys\$command";
  }

  if (($^O eq 'MSWin32') and ($slave_editor or defined $ENV{EMACS})) {
    $console = undef;
  }

  # Around a bug:
  if (defined $ENV{OS2_SHELL} and ($slave_editor or $ENV{WINDOWID})) { # In OS/2
    $console = undef;
  }

  if ($^O eq 'epoc') {
    $console = undef;
  }

  $console = $tty if defined $tty;

  if (defined $remoteport) {
    require IO::Socket;
    $OUT = new IO::Socket::INET( Timeout  => '10',
                                 PeerAddr => $remoteport,
                                 Proto    => 'tcp',
                               );
    if (!$OUT) { die "Unable to connect to remote host: $remoteport\n"; }
    $IN = $OUT;
  }
  else {
    if (defined $console) {
      open(IN,"+<$console") || open(IN,"<$console") || open(IN,"<&STDIN");
      open(OUT,"+>$console") || open(OUT,">$console") || open(OUT,">&STDERR")
        || open(OUT,">&STDOUT");	# so we don't dongle stdout
    } else {
      open(IN,"<&STDIN");
      open(OUT,">&STDERR") || open(OUT,">&STDOUT"); # so we don't dongle stdout
      $console = 'STDIN/OUT';
    }
    # so open("|more") can read from STDOUT and so we don't dingle stdin
    $IN = \*IN;

    $OUT = \*OUT;
  }
  select($OUT);
  $| = 1;			# for DB::OUT
  select(STDOUT);

  $LINEINFO = $OUT unless defined $LINEINFO;
  $lineinfo = $console unless defined $lineinfo;

  $| = 1;			# for real STDOUT

  $header =~ s/.Header: ([^,]+),v(\s+\S+\s+\S+).*$/$1$2/;
  unless ($runnonstop) {
    print $OUT "\nLoading DB routines from $header\n";
    print $OUT ("Editor support ",
		$slave_editor ? "enabled" : "available",
		".\n");
    print $OUT "\nEnter h or `h h' for help, or `$doccmd perldebug' for more help.\n\n";
  }
}

@ARGS = @ARGV;
for (@args) {
    s/\'/\\\'/g;
    s/(.*)/'$1'/ unless /^-?[\d.]+$/;
}

if (defined &afterinit) {	# May be defined in $rcfile
  &afterinit();
}

$I_m_init = 1;

############################################################ Subroutines

sub DB {
    # _After_ the perl program is compiled, $single is set to 1:
    if ($single and not $second_time++) {
      if ($runnonstop) {	# Disable until signal
	for ($i=0; $i <= $stack_depth; ) {
	    $stack[$i++] &= ~1;
	}
	$single = 0;
	# return;			# Would not print trace!
      } elsif ($ImmediateStop) {
	$ImmediateStop = 0;
	$signal = 1;
      }
    }
    $runnonstop = 0 if $single or $signal; # Disable it if interactive.
    &save;
    ($package, $filename, $line) = caller;
    $filename_ini = $filename;
    $usercontext = '($@, $!, $^E, $,, $/, $\, $^W) = @saved;' .
      "package $package;";	# this won't let them modify, alas
    local(*dbline) = $main::{'_<' . $filename};
    $max = $#dbline;
    if (($stop,$action) = split(/\0/,$dbline{$line})) {
	if ($stop eq '1') {
	    $signal |= 1;
	} elsif ($stop) {
	    $evalarg = "\$DB::signal |= 1 if do {$stop}"; &eval;
	    $dbline{$line} =~ s/;9($|\0)/$1/;
	}
    }
    my $was_signal = $signal;
    if ($trace & 2) {
      for (my $n = 0; $n <= $#to_watch; $n++) {
	$evalarg = $to_watch[$n];
	local $onetimeDump;	# Do not output results
	my ($val) = &eval;	# Fix context (&eval is doing array)?
	$val = ( (defined $val) ? "'$val'" : 'undef' );
	if ($val ne $old_watch[$n]) {
	  $signal = 1;
	  print $OUT <<EOP;
Watchpoint $n:\t$to_watch[$n] changed:
    old value:\t$old_watch[$n]
    new value:\t$val
EOP
	  $old_watch[$n] = $val;
	}
      }
    }
    if ($trace & 4) {		# User-installed watch
      return if watchfunction($package, $filename, $line) 
	and not $single and not $was_signal and not ($trace & ~4);
    }
    $was_signal = $signal;
    $signal = 0;
    if ($single || ($trace & 1) || $was_signal) {
	if ($slave_editor) {
	    $position = "\032\032$filename:$line:0\n";
	    print $LINEINFO $position;
	} elsif ($package eq 'DB::fake') {
	  $term || &setterm;
	  print_help(<<EOP);
Debugged program terminated.  Use B<q> to quit or B<R> to restart,
  use B<O> I<inhibit_exit> to avoid stopping after program termination,
  B<h q>, B<h R> or B<h O> to get additional info.  
EOP
	  $package = 'main';
	  $usercontext = '($@, $!, $^E, $,, $/, $\, $^W) = @saved;' .
	    "package $package;";	# this won't let them modify, alas
	} else {
	    $sub =~ s/\'/::/;
	    $prefix = $sub =~ /::/ ? "" : "${'package'}::";
	    $prefix .= "$sub($filename:";
	    $after = ($dbline[$line] =~ /\n$/ ? '' : "\n");
	    if (length($prefix) > 30) {
	        $position = "$prefix$line):\n$line:\t$dbline[$line]$after";
		$prefix = "";
		$infix = ":\t";
	    } else {
		$infix = "):\t";
		$position = "$prefix$line$infix$dbline[$line]$after";
	    }
	    if ($frame) {
		print $LINEINFO ' ' x $stack_depth, "$line:\t$dbline[$line]$after";
	    } else {
		print $LINEINFO $position;
	    }
	    for ($i = $line + 1; $i <= $max && $dbline[$i] == 0; ++$i) { #{ vi
		last if $dbline[$i] =~ /^\s*[\;\}\#\n]/;
		last if $signal;
		$after = ($dbline[$i] =~ /\n$/ ? '' : "\n");
		$incr_pos = "$prefix$i$infix$dbline[$i]$after";
		$position .= $incr_pos;
		if ($frame) {
		    print $LINEINFO ' ' x $stack_depth, "$i:\t$dbline[$i]$after";
		} else {
		    print $LINEINFO $incr_pos;
		}
	    }
	}
    }
    $evalarg = $action, &eval if $action;
    if ($single || $was_signal) {
	local $level = $level + 1;
	foreach $evalarg (@$pre) {
	  &eval;
	}
	print $OUT $stack_depth . " levels deep in subroutine calls!\n"
	  if $single & 4;
	$start = $line;
	$incr = -1;		# for backward motion.
	@typeahead = (@$pretype, @typeahead);
      CMD:
	while (($term || &setterm),
	       ($term_pid == $$ or &resetterm),
	       defined ($cmd=&readline("  DB" . ('<' x $level) .
				       ($#hist+1) . ('>' x $level) .
				       " "))) 
        {
		$single = 0;
		$signal = 0;
		$cmd =~ s/\\$/\n/ && do {
		    $cmd .= &readline("  cont: ");
		    redo CMD;
		};
		$cmd =~ /^$/ && ($cmd = $laststep);
		push(@hist,$cmd) if length($cmd) > 1;
	      PIPE: {
		    $cmd =~ s/^\s+//s;   # trim annoying leading whitespace
		    $cmd =~ s/\s+$//s;   # trim annoying trailing whitespace
		    ($i) = split(/\s+/,$cmd);
		    if ($alias{$i}) { 
			# squelch the sigmangler
			local $SIG{__DIE__};
			local $SIG{__WARN__};
			eval "\$cmd =~ $alias{$i}";
			if ($@) {
			    print $OUT "Couldn't evaluate `$i' alias: $@";
			    next CMD;
			} 
		    }
                   $cmd =~ /^q$/ && ($fall_off_end = 1) && exit $?;
		    $cmd =~ /^h$/ && do {
			print_help($help);
			next CMD; };
		    $cmd =~ /^h\s+h$/ && do {
			print_help($summary);
			next CMD; };
		    # support long commands; otherwise bogus errors
		    # happen when you ask for h on <CR> for example
		    $cmd =~ /^h\s+(\S.*)$/ && do {      
			my $asked = $1;			# for proper errmsg
			my $qasked = quotemeta($asked); # for searching
			# XXX: finds CR but not <CR>
			if ($help =~ /^<?(?:[IB]<)$qasked/m) {
			  while ($help =~ /^(<?(?:[IB]<)$qasked([\s\S]*?)\n)(?!\s)/mg) {
			    print_help($1);
			  }
			} else {
			    print_help("B<$asked> is not a debugger command.\n");
			}
			next CMD; };
		    $cmd =~ /^t$/ && do {
			$trace ^= 1;
			print $OUT "Trace = " .
			    (($trace & 1) ? "on" : "off" ) . "\n";
			next CMD; };
		    $cmd =~ /^S(\s+(!)?(.+))?$/ && do {
			$Srev = defined $2; $Spatt = $3; $Snocheck = ! defined $1;
			foreach $subname (sort(keys %sub)) {
			    if ($Snocheck or $Srev^($subname =~ /$Spatt/)) {
				print $OUT $subname,"\n";
			    }
			}
			next CMD; };
		    $cmd =~ /^v$/ && do {
			list_versions(); next CMD};
		    $cmd =~ s/^X\b/V $package/;
		    $cmd =~ /^V$/ && do {
			$cmd = "V $package"; };
		    $cmd =~ /^V\b\s*(\S+)\s*(.*)/ && do {
			local ($savout) = select($OUT);
			$packname = $1;
			@vars = split(' ',$2);
			do 'dumpvar.pl' unless defined &main::dumpvar;
			if (defined &main::dumpvar) {
			    local $frame = 0;
			    local $doret = -2;
			    # must detect sigpipe failures
			    eval { &main::dumpvar($packname,@vars) };
			    if ($@) {
				die unless $@ =~ /dumpvar print failed/;
			    } 
			} else {
			    print $OUT "dumpvar.pl not available.\n";
			}
			select ($savout);
			next CMD; };
		    $cmd =~ s/^x\b/ / && do { # So that will be evaled
			$onetimeDump = 'dump'; };
		    $cmd =~ s/^m\s+([\w:]+)\s*$/ / && do {
			methods($1); next CMD};
		    $cmd =~ s/^m\b/ / && do { # So this will be evaled
			$onetimeDump = 'methods'; };
		    $cmd =~ /^f\b\s*(.*)/ && do {
			$file = $1;
			$file =~ s/\s+$//;
			if (!$file) {
			    print $OUT "The old f command is now the r command.\n";
			    print $OUT "The new f command switches filenames.\n";
			    next CMD;
			}
			if (!defined $main::{'_<' . $file}) {
			    if (($try) = grep(m#^_<.*$file#, keys %main::)) {{
					      $try = substr($try,2);
					      print $OUT "Choosing $try matching `$file':\n";
					      $file = $try;
					  }}
			}
			if (!defined $main::{'_<' . $file}) {
			    print $OUT "No file matching `$file' is loaded.\n";
			    next CMD;
			} elsif ($file ne $filename) {
			    *dbline = $main::{'_<' . $file};
			    $max = $#dbline;
			    $filename = $file;
			    $start = 1;
			    $cmd = "l";
			  } else {
			    print $OUT "Already in $file.\n";
			    next CMD;
			  }
		      };
		    $cmd =~ s/^l\s+-\s*$/-/;
		    $cmd =~ /^([lb])\b\s*(\$.*)/s && do {
			$evalarg = $2;
			my ($s) = &eval;
			print($OUT "Error: $@\n"), next CMD if $@;
			$s = CvGV_name($s);
			print($OUT "Interpreted as: $1 $s\n");
			$cmd = "$1 $s";
		    };
		    $cmd =~ /^l\b\s*([\':A-Za-z_][\':\w]*(\[.*\])?)/s && do {
			$subname = $1;
			$subname =~ s/\'/::/;
			$subname = $package."::".$subname 
			  unless $subname =~ /::/;
			$subname = "main".$subname if substr($subname,0,2) eq "::";
			@pieces = split(/:/,find_sub($subname) || $sub{$subname});
			$subrange = pop @pieces;
			$file = join(':', @pieces);
			if ($file ne $filename) {
			    print $OUT "Switching to file '$file'.\n"
				unless $slave_editor;
			    *dbline = $main::{'_<' . $file};
			    $max = $#dbline;
			    $filename = $file;
			}
			if ($subrange) {
			    if (eval($subrange) < -$window) {
				$subrange =~ s/-.*/+/;
			    }
			    $cmd = "l $subrange";
			} else {
			    print $OUT "Subroutine $subname not found.\n";
			    next CMD;
			} };
		    $cmd =~ /^\.$/ && do {
			$incr = -1;		# for backward motion.
			$start = $line;
			$filename = $filename_ini;
			*dbline = $main::{'_<' . $filename};
			$max = $#dbline;
			print $LINEINFO $position;
			next CMD };
		    $cmd =~ /^w\b\s*(\d*)$/ && do {
			$incr = $window - 1;
			$start = $1 if $1;
			$start -= $preview;
			#print $OUT 'l ' . $start . '-' . ($start + $incr);
			$cmd = 'l ' . $start . '-' . ($start + $incr); };
		    $cmd =~ /^-$/ && do {
			$start -= $incr + $window + 1;
			$start = 1 if $start <= 0;
			$incr = $window - 1;
			$cmd = 'l ' . ($start) . '+'; };
		    $cmd =~ /^l$/ && do {
			$incr = $window - 1;
			$cmd = 'l ' . $start . '-' . ($start + $incr); };
		    $cmd =~ /^l\b\s*(\d*)\+(\d*)$/ && do {
			$start = $1 if $1;
			$incr = $2;
			$incr = $window - 1 unless $incr;
			$cmd = 'l ' . $start . '-' . ($start + $incr); };
		    $cmd =~ /^l\b\s*((-?[\d\$\.]+)([-,]([\d\$\.]+))?)?/ && do {
			$end = (!defined $2) ? $max : ($4 ? $4 : $2);
			$end = $max if $end > $max;
			$i = $2;
			$i = $line if $i eq '.';
			$i = 1 if $i < 1;
			$incr = $end - $i;
			if ($slave_editor) {
			    print $OUT "\032\032$filename:$i:0\n";
			    $i = $end;
			} else {
			    for (; $i <= $end; $i++) {
			        ($stop,$action) = split(/\0/, $dbline{$i});
			        $arrow = ($i==$line 
					  and $filename eq $filename_ini) 
				  ?  '==>' 
				    : ($dbline[$i]+0 ? ':' : ' ') ;
				$arrow .= 'b' if $stop;
				$arrow .= 'a' if $action;
				print $OUT "$i$arrow\t", $dbline[$i];
				$i++, last if $signal;
			    }
			    print $OUT "\n" unless $dbline[$i-1] =~ /\n$/;
			}
			$start = $i; # remember in case they want more
			$start = $max if $start > $max;
			next CMD; };
		    $cmd =~ /^D$/ && do {
		      print $OUT "Deleting all breakpoints...\n";
		      my $file;
		      for $file (keys %had_breakpoints) {
			local *dbline = $main::{'_<' . $file};
			my $max = $#dbline;
			my $was;
			
			for ($i = 1; $i <= $max ; $i++) {
			    if (defined $dbline{$i}) {
				$dbline{$i} =~ s/^[^\0]+//;
				if ($dbline{$i} =~ s/^\0?$//) {
				    delete $dbline{$i};
				}
			    }
			}
			
			if (not $had_breakpoints{$file} &= ~1) {
			    delete $had_breakpoints{$file};
			}
		      }
		      undef %postponed;
		      undef %postponed_file;
		      undef %break_on_load;
		      next CMD; };
		    $cmd =~ /^L$/ && do {
		      my $file;
		      for $file (keys %had_breakpoints) {
			local *dbline = $main::{'_<' . $file};
			my $max = $#dbline;
			my $was;
			
			for ($i = 1; $i <= $max; $i++) {
			    if (defined $dbline{$i}) {
			        print $OUT "$file:\n" unless $was++;
				print $OUT " $i:\t", $dbline[$i];
				($stop,$action) = split(/\0/, $dbline{$i});
				print $OUT "   break if (", $stop, ")\n"
				  if $stop;
				print $OUT "   action:  ", $action, "\n"
				  if $action;
				last if $signal;
			    }
			}
		      }
		      if (%postponed) {
			print $OUT "Postponed breakpoints in subroutines:\n";
			my $subname;
			for $subname (keys %postponed) {
			  print $OUT " $subname\t$postponed{$subname}\n";
			  last if $signal;
			}
		      }
		      my @have = map { # Combined keys
			keys %{$postponed_file{$_}}
		      } keys %postponed_file;
		      if (@have) {
			print $OUT "Postponed breakpoints in files:\n";
			my ($file, $line);
			for $file (keys %postponed_file) {
			  my $db = $postponed_file{$file};
			  print $OUT " $file:\n";
			  for $line (sort {$a <=> $b} keys %$db) {
				print $OUT "  $line:\n";
				my ($stop,$action) = split(/\0/, $$db{$line});
				print $OUT "    break if (", $stop, ")\n"
				  if $stop;
				print $OUT "    action:  ", $action, "\n"
				  if $action;
				last if $signal;
			  }
			  last if $signal;
			}
		      }
		      if (%break_on_load) {
			print $OUT "Breakpoints on load:\n";
			my $file;
			for $file (keys %break_on_load) {
			  print $OUT " $file\n";
			  last if $signal;
			}
		      }
		      if ($trace & 2) {
			print $OUT "Watch-expressions:\n";
			my $expr;
			for $expr (@to_watch) {
			  print $OUT " $expr\n";
			  last if $signal;
			}
		      }
		      next CMD; };
		    $cmd =~ /^b\b\s*load\b\s*(.*)/ && do {
			my $file = $1; $file =~ s/\s+$//;
			{
			  $break_on_load{$file} = 1;
			  $break_on_load{$::INC{$file}} = 1 if $::INC{$file};
			  $file .= '.pm', redo unless $file =~ /\./;
			}
			$had_breakpoints{$file} |= 1;
			print $OUT "Will stop on load of `@{[join '\', `', sort keys %break_on_load]}'.\n";
			next CMD; };
		    $cmd =~ /^b\b\s*(postpone|compile)\b\s*([':A-Za-z_][':\w]*)\s*(.*)/ && do {
			my $cond = length $3 ? $3 : '1';
			my ($subname, $break) = ($2, $1 eq 'postpone');
			$subname =~ s/\'/::/g;
			$subname = "${'package'}::" . $subname
			  unless $subname =~ /::/;
			$subname = "main".$subname if substr($subname,0,2) eq "::";
			$postponed{$subname} = $break 
			  ? "break +0 if $cond" : "compile";
			next CMD; };
		    $cmd =~ /^b\b\s*([':A-Za-z_][':\w]*(?:\[.*\])?)\s*(.*)/ && do {
			$subname = $1;
			$cond = length $2 ? $2 : '1';
			$subname =~ s/\'/::/g;
			$subname = "${'package'}::" . $subname
			  unless $subname =~ /::/;
			$subname = "main".$subname if substr($subname,0,2) eq "::";
			# Filename below can contain ':'
			($file,$i) = (find_sub($subname) =~ /^(.*):(.*)$/);
			$i += 0;
			if ($i) {
			    local $filename = $file;
			    local *dbline = $main::{'_<' . $filename};
			    $had_breakpoints{$filename} |= 1;
			    $max = $#dbline;
			    ++$i while $dbline[$i] == 0 && $i < $max;
			    $dbline{$i} =~ s/^[^\0]*/$cond/;
			} else {
			    print $OUT "Subroutine $subname not found.\n";
			}
			next CMD; };
		    $cmd =~ /^b\b\s*(\d*)\s*(.*)/ && do {
			$i = $1 || $line;
			$cond = length $2 ? $2 : '1';
			if ($dbline[$i] == 0) {
			    print $OUT "Line $i not breakable.\n";
			} else {
			    $had_breakpoints{$filename} |= 1;
			    $dbline{$i} =~ s/^[^\0]*/$cond/;
			}
			next CMD; };
		    $cmd =~ /^d\b\s*(\d*)/ && do {
			$i = $1 || $line;
                        if ($dbline[$i] == 0) {
                            print $OUT "Line $i not breakable.\n";
                        } else {
			    $dbline{$i} =~ s/^[^\0]*//;
			    delete $dbline{$i} if $dbline{$i} eq '';
                        }
			next CMD; };
		    $cmd =~ /^A$/ && do {
		      print $OUT "Deleting all actions...\n";
		      my $file;
		      for $file (keys %had_breakpoints) {
			local *dbline = $main::{'_<' . $file};
			my $max = $#dbline;
			my $was;
			
			for ($i = 1; $i <= $max ; $i++) {
			    if (defined $dbline{$i}) {
				$dbline{$i} =~ s/\0[^\0]*//;
				delete $dbline{$i} if $dbline{$i} eq '';
			    }
			}
			
			unless ($had_breakpoints{$file} &= ~2) {
			    delete $had_breakpoints{$file};
			}
		      }
		      next CMD; };
		    $cmd =~ /^O\s*$/ && do {
			for (@options) {
			    &dump_option($_);
			}
			next CMD; };
		    $cmd =~ /^O\s*(\S.*)/ && do {
			parse_options($1);
			next CMD; };
		    $cmd =~ /^\<\<\s*(.*)/ && do { # \<\< for CPerl sake: not HERE
			push @$pre, action($1);
			next CMD; };
		    $cmd =~ /^>>\s*(.*)/ && do {
			push @$post, action($1);
			next CMD; };
		    $cmd =~ /^<\s*(.*)/ && do {
			unless ($1) {
			    print $OUT "All < actions cleared.\n";
			    $pre = [];
			    next CMD;
			} 
			if ($1 eq '?') {
			    unless (@$pre) {
				print $OUT "No pre-prompt Perl actions.\n";
				next CMD;
			    } 
			    print $OUT "Perl commands run before each prompt:\n";
			    for my $action ( @$pre ) {
				print $OUT "\t< -- $action\n";
			    } 
			    next CMD;
			} 
			$pre = [action($1)];
			next CMD; };
		    $cmd =~ /^>\s*(.*)/ && do {
			unless ($1) {
			    print $OUT "All > actions cleared.\n";
			    $post = [];
			    next CMD;
			}
			if ($1 eq '?') {
			    unless (@$post) {
				print $OUT "No post-prompt Perl actions.\n";
				next CMD;
			    } 
			    print $OUT "Perl commands run after each prompt:\n";
			    for my $action ( @$post ) {
				print $OUT "\t> -- $action\n";
			    } 
			    next CMD;
			} 
			$post = [action($1)];
			next CMD; };
		    $cmd =~ /^\{\{\s*(.*)/ && do {
			if ($cmd =~ /^\{.*\}$/ && unbalanced(substr($cmd,2))) { 
			    print $OUT "{{ is now a debugger command\n",
				"use `;{{' if you mean Perl code\n";
			    $cmd = "h {{";
			    redo CMD;
			} 
			push @$pretype, $1;
			next CMD; };
		    $cmd =~ /^\{\s*(.*)/ && do {
			unless ($1) {
			    print $OUT "All { actions cleared.\n";
			    $pretype = [];
			    next CMD;
			}
			if ($1 eq '?') {
			    unless (@$pretype) {
				print $OUT "No pre-prompt debugger actions.\n";
				next CMD;
			    } 
			    print $OUT "Debugger commands run before each prompt:\n";
			    for my $action ( @$pretype ) {
				print $OUT "\t{ -- $action\n";
			    } 
			    next CMD;
			} 
			if ($cmd =~ /^\{.*\}$/ && unbalanced(substr($cmd,1))) { 
			    print $OUT "{ is now a debugger command\n",
				"use `;{' if you mean Perl code\n";
			    $cmd = "h {";
			    redo CMD;
			} 
			$pretype = [$1];
			next CMD; };
		    $cmd =~ /^a\b\s*(\d*)\s*(.*)/ && do {
			$i = $1 || $line; $j = $2;
			if (length $j) {
			    if ($dbline[$i] == 0) {
				print $OUT "Line $i may not have an action.\n";
			    } else {
				$had_breakpoints{$filename} |= 2;
				$dbline{$i} =~ s/\0[^\0]*//;
				$dbline{$i} .= "\0" . action($j);
			    }
			} else {
			    $dbline{$i} =~ s/\0[^\0]*//;
			    delete $dbline{$i} if $dbline{$i} eq '';
			}
			next CMD; };
		    $cmd =~ /^n$/ && do {
		        end_report(), next CMD if $finished and $level <= 1;
			$single = 2;
			$laststep = $cmd;
			last CMD; };
		    $cmd =~ /^s$/ && do {
		        end_report(), next CMD if $finished and $level <= 1;
			$single = 1;
			$laststep = $cmd;
			last CMD; };
		    $cmd =~ /^c\b\s*([\w:]*)\s*$/ && do {
		        end_report(), next CMD if $finished and $level <= 1;
			$subname = $i = $1;
			#  Probably not needed, since we finish an interactive
			#  sub-session anyway...
			# local $filename = $filename;
			# local *dbline = *dbline;	# XXX Would this work?!
			if ($i =~ /\D/) { # subroutine name
			    $subname = $package."::".$subname 
			        unless $subname =~ /::/;
			    ($file,$i) = (find_sub($subname) =~ /^(.*):(.*)$/);
			    $i += 0;
			    if ($i) {
			        $filename = $file;
				*dbline = $main::{'_<' . $filename};
				$had_breakpoints{$filename} |= 1;
				$max = $#dbline;
				++$i while $dbline[$i] == 0 && $i < $max;
			    } else {
				print $OUT "Subroutine $subname not found.\n";
				next CMD; 
			    }
			}
			if ($i) {
			    if ($dbline[$i] == 0) {
				print $OUT "Line $i not breakable.\n";
				next CMD;
			    }
			    $dbline{$i} =~ s/($|\0)/;9$1/; # add one-time-only b.p.
			}
			for ($i=0; $i <= $stack_depth; ) {
			    $stack[$i++] &= ~1;
			}
			last CMD; };
		    $cmd =~ /^r$/ && do {
		        end_report(), next CMD if $finished and $level <= 1;
			$stack[$stack_depth] |= 1;
			$doret = $option{PrintRet} ? $stack_depth - 1 : -2;
			last CMD; };
		    $cmd =~ /^R$/ && do {
		        print $OUT "Warning: some settings and command-line options may be lost!\n";
			my (@script, @flags, $cl);
			push @flags, '-w' if $ini_warn;
			# Put all the old includes at the start to get
			# the same debugger.
			for (@ini_INC) {
			  push @flags, '-I', $_;
			}
			# Arrange for setting the old INC:
			set_list("PERLDB_INC", @ini_INC);
			if ($0 eq '-e') {
			  for (1..$#{'::_<-e'}) { # The first line is PERL5DB
			        chomp ($cl =  ${'::_<-e'}[$_]);
			    push @script, '-e', $cl;
			  }
			} else {
			  @script = $0;
			}
			set_list("PERLDB_HIST", 
				 $term->Features->{getHistory} 
				 ? $term->GetHistory : @hist);
			my @had_breakpoints = keys %had_breakpoints;
			set_list("PERLDB_VISITED", @had_breakpoints);
			set_list("PERLDB_OPT", %option);
			set_list("PERLDB_ON_LOAD", %break_on_load);
			my @hard;
			for (0 .. $#had_breakpoints) {
			  my $file = $had_breakpoints[$_];
			  *dbline = $main::{'_<' . $file};
			  next unless %dbline or $postponed_file{$file};
			  (push @hard, $file), next 
			    if $file =~ /^\(eval \d+\)$/;
			  my @add;
			  @add = %{$postponed_file{$file}}
			    if $postponed_file{$file};
			  set_list("PERLDB_FILE_$_", %dbline, @add);
			}
			for (@hard) { # Yes, really-really...
			  # Find the subroutines in this eval
			  *dbline = $main::{'_<' . $_};
			  my ($quoted, $sub, %subs, $line) = quotemeta $_;
			  for $sub (keys %sub) {
			    next unless $sub{$sub} =~ /^$quoted:(\d+)-(\d+)$/;
			    $subs{$sub} = [$1, $2];
			  }
			  unless (%subs) {
			    print $OUT
			      "No subroutines in $_, ignoring breakpoints.\n";
			    next;
			  }
			LINES: for $line (keys %dbline) {
			    # One breakpoint per sub only:
			    my ($offset, $sub, $found);
			  SUBS: for $sub (keys %subs) {
			      if ($subs{$sub}->[1] >= $line # Not after the subroutine
				  and (not defined $offset # Not caught
				       or $offset < 0 )) { # or badly caught
				$found = $sub;
				$offset = $line - $subs{$sub}->[0];
				$offset = "+$offset", last SUBS if $offset >= 0;
			      }
			    }
			    if (defined $offset) {
			      $postponed{$found} =
				"break $offset if $dbline{$line}";
			    } else {
			      print $OUT "Breakpoint in $_:$line ignored: after all the subroutines.\n";
			    }
			  }
			}
			set_list("PERLDB_POSTPONE", %postponed);
			set_list("PERLDB_PRETYPE", @$pretype);
			set_list("PERLDB_PRE", @$pre);
			set_list("PERLDB_POST", @$post);
			set_list("PERLDB_TYPEAHEAD", @typeahead);
			$ENV{PERLDB_RESTART} = 1;
			#print "$^X, '-d', @flags, @script, ($slave_editor ? '-emacs' : ()), @ARGS";
			exec $^X, '-d', @flags, @script, ($slave_editor ? '-emacs' : ()), @ARGS;
			print $OUT "exec failed: $!\n";
			last CMD; };
		    $cmd =~ /^T$/ && do {
			print_trace($OUT, 1); # skip DB
			next CMD; };
		    $cmd =~ /^W\s*$/ && do {
			$trace &= ~2;
			@to_watch = @old_watch = ();
			next CMD; };
		    $cmd =~ /^W\b\s*(.*)/s && do {
			push @to_watch, $1;
			$evalarg = $1;
			my ($val) = &eval;
			$val = (defined $val) ? "'$val'" : 'undef' ;
			push @old_watch, $val;
			$trace |= 2;
			next CMD; };
		    $cmd =~ /^\/(.*)$/ && do {
			$inpat = $1;
			$inpat =~ s:([^\\])/$:$1:;
			if ($inpat ne "") {
			    # squelch the sigmangler
			    local $SIG{__DIE__};
			    local $SIG{__WARN__};
			    eval '$inpat =~ m'."\a$inpat\a";	
			    if ($@ ne "") {
				print $OUT "$@";
				next CMD;
			    }
			    $pat = $inpat;
			}
			$end = $start;
			$incr = -1;
			eval '
			    for (;;) {
				++$start;
				$start = 1 if ($start > $max);
				last if ($start == $end);
				if ($dbline[$start] =~ m' . "\a$pat\a" . 'i) {
				    if ($slave_editor) {
					print $OUT "\032\032$filename:$start:0\n";
				    } else {
					print $OUT "$start:\t", $dbline[$start], "\n";
				    }
				    last;
				}
			    } ';
			print $OUT "/$pat/: not found\n" if ($start == $end);
			next CMD; };
		    $cmd =~ /^\?(.*)$/ && do {
			$inpat = $1;
			$inpat =~ s:([^\\])\?$:$1:;
			if ($inpat ne "") {
			    # squelch the sigmangler
			    local $SIG{__DIE__};
			    local $SIG{__WARN__};
			    eval '$inpat =~ m'."\a$inpat\a";	
			    if ($@ ne "") {
				print $OUT $@;
				next CMD;
			    }
			    $pat = $inpat;
			}
			$end = $start;
			$incr = -1;
			eval '
			    for (;;) {
				--$start;
				$start = $max if ($start <= 0);
				last if ($start == $end);
				if ($dbline[$start] =~ m' . "\a$pat\a" . 'i) {
				    if ($slave_editor) {
					print $OUT "\032\032$filename:$start:0\n";
				    } else {
					print $OUT "$start:\t", $dbline[$start], "\n";
				    }
				    last;
				}
			    } ';
			print $OUT "?$pat?: not found\n" if ($start == $end);
			next CMD; };
		    $cmd =~ /^$rc+\s*(-)?(\d+)?$/ && do {
			pop(@hist) if length($cmd) > 1;
			$i = $1 ? ($#hist-($2||1)) : ($2||$#hist);
			$cmd = $hist[$i];
			print $OUT $cmd, "\n";
			redo CMD; };
		    $cmd =~ /^$sh$sh\s*([\x00-\xff]*)/ && do {
			&system($1);
			next CMD; };
		    $cmd =~ /^$rc([^$rc].*)$/ && do {
			$pat = "^$1";
			pop(@hist) if length($cmd) > 1;
			for ($i = $#hist; $i; --$i) {
			    last if $hist[$i] =~ /$pat/;
			}
			if (!$i) {
			    print $OUT "No such command!\n\n";
			    next CMD;
			}
			$cmd = $hist[$i];
			print $OUT $cmd, "\n";
			redo CMD; };
		    $cmd =~ /^$sh$/ && do {
			&system($ENV{SHELL}||"/bin/sh");
			next CMD; };
		    $cmd =~ /^$sh\s*([\x00-\xff]*)/ && do {
			# XXX: using csh or tcsh destroys sigint retvals!
			#&system($1);  # use this instead
			&system($ENV{SHELL}||"/bin/sh","-c",$1);
			next CMD; };
		    $cmd =~ /^H\b\s*(-(\d+))?/ && do {
			$end = $2 ? ($#hist-$2) : 0;
			$hist = 0 if $hist < 0;
			for ($i=$#hist; $i>$end; $i--) {
			    print $OUT "$i: ",$hist[$i],"\n"
			      unless $hist[$i] =~ /^.?$/;
			};
			next CMD; };
		    $cmd =~ /^(?:man|(?:perl)?doc)\b(?:\s+([^(]*))?$/ && do {
			runman($1);
			next CMD; };
		    $cmd =~ s/^p$/print {\$DB::OUT} \$_/;
		    $cmd =~ s/^p\b/print {\$DB::OUT} /;
		    $cmd =~ s/^=\s*// && do {
			my @keys;
			if (length $cmd == 0) {
			    @keys = sort keys %alias;
			} 
                        elsif (my($k,$v) = ($cmd =~ /^(\S+)\s+(\S.*)/)) {
			    # can't use $_ or kill //g state
			    for my $x ($k, $v) { $x =~ s/\a/\\a/g }
			    $alias{$k} = "s\a$k\a$v\a";
			    # squelch the sigmangler
			    local $SIG{__DIE__};
			    local $SIG{__WARN__};
			    unless (eval "sub { s\a$k\a$v\a }; 1") {
				print $OUT "Can't alias $k to $v: $@\n"; 
				delete $alias{$k};
				next CMD;
			    } 
			    @keys = ($k);
			} 
			else {
			    @keys = ($cmd);
			} 
			for my $k (@keys) {
			    if ((my $v = $alias{$k}) =~ ss\a$k\a(.*)\a$1) {
				print $OUT "$k\t= $1\n";
			    } 
			    elsif (defined $alias{$k}) {
				    print $OUT "$k\t$alias{$k}\n";
			    } 
			    else {
				print "No alias for $k\n";
			    } 
			}
			next CMD; };
		    $cmd =~ /^\|\|?\s*[^|]/ && do {
			if ($pager =~ /^\|/) {
			    open(SAVEOUT,">&STDOUT") || &warn("Can't save STDOUT");
			    open(STDOUT,">&OUT") || &warn("Can't redirect STDOUT");
			} else {
			    open(SAVEOUT,">&OUT") || &warn("Can't save DB::OUT");
			}
			fix_less();
			unless ($piped=open(OUT,$pager)) {
			    &warn("Can't pipe output to `$pager'");
			    if ($pager =~ /^\|/) {
				open(OUT,">&STDOUT") # XXX: lost message
				    || &warn("Can't restore DB::OUT");
				open(STDOUT,">&SAVEOUT")
				  || &warn("Can't restore STDOUT");
				close(SAVEOUT);
			    } else {
				open(OUT,">&STDOUT") # XXX: lost message
				    || &warn("Can't restore DB::OUT");
			    }
			    next CMD;
			}
			$SIG{PIPE}= \&DB::catch if $pager =~ /^\|/
			    && ("" eq $SIG{PIPE}  ||  "DEFAULT" eq $SIG{PIPE});
			$selected= select(OUT);
			$|= 1;
			select( $selected ), $selected= "" unless $cmd =~ /^\|\|/;
			$cmd =~ s/^\|+\s*//;
			redo PIPE; 
		    };
		    # XXX Local variants do not work!
		    $cmd =~ s/^t\s/\$DB::trace |= 1;\n/;
		    $cmd =~ s/^s\s/\$DB::single = 1;\n/ && do {$laststep = 's'};
		    $cmd =~ s/^n\s/\$DB::single = 2;\n/ && do {$laststep = 'n'};
		}		# PIPE:
	    $evalarg = "\$^D = \$^D | \$DB::db_stop;\n$cmd"; &eval;
	    if ($onetimeDump) {
		$onetimeDump = undef;
	    } elsif ($term_pid == $$) {
		print $OUT "\n";
	    }
	} continue {		# CMD:
	    if ($piped) {
		if ($pager =~ /^\|/) {
		    $? = 0;  
		    # we cannot warn here: the handle is missing --tchrist
		    close(OUT) || print SAVEOUT "\nCan't close DB::OUT\n";

		    # most of the $? crud was coping with broken cshisms
		    if ($?) {
			print SAVEOUT "Pager `$pager' failed: ";
			if ($? == -1) {
			    print SAVEOUT "shell returned -1\n";
			} elsif ($? >> 8) {
			    print SAVEOUT 
			      ( $? & 127 ) ? " (SIG#".($?&127).")" : "", 
			      ( $? & 128 ) ? " -- core dumped" : "", "\n";
			} else {
			    print SAVEOUT "status ", ($? >> 8), "\n";
			} 
		    } 

		    open(OUT,">&STDOUT") || &warn("Can't restore DB::OUT");
		    open(STDOUT,">&SAVEOUT") || &warn("Can't restore STDOUT");
		    $SIG{PIPE} = "DEFAULT" if $SIG{PIPE} eq \&DB::catch;
		    # Will stop ignoring SIGPIPE if done like nohup(1)
		    # does SIGINT but Perl doesn't give us a choice.
		} else {
		    open(OUT,">&SAVEOUT") || &warn("Can't restore DB::OUT");
		}
		close(SAVEOUT);
		select($selected), $selected= "" unless $selected eq "";
		$piped= "";
	    }
	}			# CMD:
       $fall_off_end = 1 unless defined $cmd; # Emulate `q' on EOF
	foreach $evalarg (@$post) {
	  &eval;
	}
    }				# if ($single || $signal)
    ($@, $!, $^E, $,, $/, $\, $^W) = @saved;
    ();
}

# The following code may be executed now:
# BEGIN {warn 4}

sub sub {
    my ($al, $ret, @ret) = "";
    if (length($sub) > 10 && substr($sub, -10, 10) eq '::AUTOLOAD') {
	$al = " for $$sub";
    }
    local $stack_depth = $stack_depth + 1; # Protect from non-local exits
    $#stack = $stack_depth;
    $stack[-1] = $single;
    $single &= 1;
    $single |= 4 if $stack_depth == $deep;
    ($frame & 4 
     ? ( (print $LINEINFO ' ' x ($stack_depth - 1), "in  "), 
	 # Why -1? But it works! :-(
	 print_trace($LINEINFO, -1, 1, 1, "$sub$al") )
     : print $LINEINFO ' ' x ($stack_depth - 1), "entering $sub$al\n") if $frame;
    if (wantarray) {
	@ret = &$sub;
	$single |= $stack[$stack_depth--];
	($frame & 4 
	 ? ( (print $LINEINFO ' ' x $stack_depth, "out "), 
	     print_trace($LINEINFO, -1, 1, 1, "$sub$al") )
	 : print $LINEINFO ' ' x $stack_depth, "exited $sub$al\n") if $frame & 2;
	if ($doret eq $stack_depth or $frame & 16) {
            my $fh = ($doret eq $stack_depth ? $OUT : $LINEINFO);
	    print $fh ' ' x $stack_depth if $frame & 16;
	    print $fh "list context return from $sub:\n"; 
	    dumpit($fh, \@ret );
	    $doret = -2;
	}
	@ret;
    } else {
        if (defined wantarray) {
	    $ret = &$sub;
        } else {
            &$sub; undef $ret;
        };
	$single |= $stack[$stack_depth--];
	($frame & 4 
	 ? ( (print $LINEINFO ' ' x $stack_depth, "out "), 
	      print_trace($LINEINFO, -1, 1, 1, "$sub$al") )
	 : print $LINEINFO ' ' x $stack_depth, "exited $sub$al\n") if $frame & 2;
	if ($doret eq $stack_depth or $frame & 16 and defined wantarray) {
            my $fh = ($doret eq $stack_depth ? $OUT : $LINEINFO);
	    print $fh (' ' x $stack_depth) if $frame & 16;
	    print $fh (defined wantarray 
			 ? "scalar context return from $sub: " 
			 : "void context return from $sub\n");
	    dumpit( $fh, $ret ) if defined wantarray;
	    $doret = -2;
	}
	$ret;
    }
}

sub save {
    @saved = ($@, $!, $^E, $,, $/, $\, $^W);
    $, = ""; $/ = "\n"; $\ = ""; $^W = 0;
}

# The following takes its argument via $evalarg to preserve current @_

sub eval {
    # 'my' would make it visible from user code
    #    but so does local! --tchrist  
    local @res;			
    {
	local $otrace = $trace;
	local $osingle = $single;
	local $od = $^D;
	{ ($evalarg) = $evalarg =~ /(.*)/s; }
	@res = eval "$usercontext $evalarg;\n"; # '\n' for nice recursive debug
	$trace = $otrace;
	$single = $osingle;
	$^D = $od;
    }
    my $at = $@;
    local $saved[0];		# Preserve the old value of $@
    eval { &DB::save };
    if ($at) {
	print $OUT $at;
    } elsif ($onetimeDump eq 'dump') {
	dumpit($OUT, \@res);
    } elsif ($onetimeDump eq 'methods') {
	methods($res[0]);
    }
    @res;
}

sub postponed_sub {
  my $subname = shift;
  if ($postponed{$subname} =~ s/^break\s([+-]?\d+)\s+if\s//) {
    my $offset = $1 || 0;
    # Filename below can contain ':'
    my ($file,$i) = (find_sub($subname) =~ /^(.*):(\d+)-.*$/);
    if ($i) {
      $i += $offset;
      local *dbline = $main::{'_<' . $file};
      local $^W = 0;		# != 0 is magical below
      $had_breakpoints{$file} |= 1;
      my $max = $#dbline;
      ++$i until $dbline[$i] != 0 or $i >= $max;
      $dbline{$i} = delete $postponed{$subname};
    } else {
      print $OUT "Subroutine $subname not found.\n";
    }
    return;
  }
  elsif ($postponed{$subname} eq 'compile') { $signal = 1 }
  #print $OUT "In postponed_sub for `$subname'.\n";
}

sub postponed {
  if ($ImmediateStop) {
    $ImmediateStop = 0;
    $signal = 1;
  }
  return &postponed_sub
    unless ref \$_[0] eq 'GLOB'; # A subroutine is compiled.
  # Cannot be done before the file is compiled
  local *dbline = shift;
  my $filename = $dbline;
  $filename =~ s/^_<//;
  $signal = 1, print $OUT "'$filename' loaded...\n"
    if $break_on_load{$filename};
  print $LINEINFO ' ' x $stack_depth, "Package $filename.\n" if $frame;
  return unless $postponed_file{$filename};
  $had_breakpoints{$filename} |= 1;
  #%dbline = %{$postponed_file{$filename}}; # Cannot be done: unsufficient magic
  my $key;
  for $key (keys %{$postponed_file{$filename}}) {
    $dbline{$key} = ${$postponed_file{$filename}}{$key};
  }
  delete $postponed_file{$filename};
}

sub dumpit {
    local ($savout) = select(shift);
    my $osingle = $single;
    my $otrace = $trace;
    $single = $trace = 0;
    local $frame = 0;
    local $doret = -2;
    unless (defined &main::dumpValue) {
	do 'dumpvar.pl';
    }
    if (defined &main::dumpValue) {
	&main::dumpValue(shift);
    } else {
	print $OUT "dumpvar.pl not available.\n";
    }
    $single = $osingle;
    $trace = $otrace;
    select ($savout);    
}

# Tied method do not create a context, so may get wrong message:

sub print_trace {
  my $fh = shift;
  my @sub = dump_trace($_[0] + 1, $_[1]);
  my $short = $_[2];		# Print short report, next one for sub name
  my $s;
  for ($i=0; $i <= $#sub; $i++) {
    last if $signal;
    local $" = ', ';
    my $args = defined $sub[$i]{args} 
    ? "(@{ $sub[$i]{args} })"
      : '' ;
    $args = (substr $args, 0, $maxtrace - 3) . '...' 
      if length $args > $maxtrace;
    my $file = $sub[$i]{file};
    $file = $file eq '-e' ? $file : "file `$file'" unless $short;
    $s = $sub[$i]{sub};
    $s = (substr $s, 0, $maxtrace - 3) . '...' if length $s > $maxtrace;    
    if ($short) {
      my $sub = @_ >= 4 ? $_[3] : $s;
      print $fh "$sub[$i]{context}=$sub$args from $file:$sub[$i]{line}\n";
    } else {
      print $fh "$sub[$i]{context} = $s$args" .
	" called from $file" . 
	  " line $sub[$i]{line}\n";
    }
  }
}

sub dump_trace {
  my $skip = shift;
  my $count = shift || 1e9;
  $skip++;
  $count += $skip;
  my ($p,$file,$line,$sub,$h,$args,$e,$r,@a,@sub,$context);
  my $nothard = not $frame & 8;
  local $frame = 0;		# Do not want to trace this.
  my $otrace = $trace;
  $trace = 0;
  for ($i = $skip; 
       $i < $count and ($p,$file,$line,$sub,$h,$context,$e,$r) = caller($i); 
       $i++) {
    @a = ();
    for $arg (@args) {
      my $type;
      if (not defined $arg) {
	push @a, "undef";
      } elsif ($nothard and tied $arg) {
	push @a, "tied";
      } elsif ($nothard and $type = ref $arg) {
	push @a, "ref($type)";
      } else {
	local $_ = "$arg";	# Safe to stringify now - should not call f().
	s/([\'\\])/\\$1/g;
	s/(.*)/'$1'/s
	  unless /^(?: -?[\d.]+ | \*[\w:]* )$/x;
	s/([\200-\377])/sprintf("M-%c",ord($1)&0177)/eg;
	s/([\0-\37\177])/sprintf("^%c",ord($1)^64)/eg;
	push(@a, $_);
      }
    }
    $context = $context ? '@' : (defined $context ? "\$" : '.');
    $args = $h ? [@a] : undef;
    $e =~ s/\n\s*\;\s*\Z// if $e;
    $e =~ s/([\\\'])/\\$1/g if $e;
    if ($r) {
      $sub = "require '$e'";
    } elsif (defined $r) {
      $sub = "eval '$e'";
    } elsif ($sub eq '(eval)') {
      $sub = "eval {...}";
    }
    push(@sub, {context => $context, sub => $sub, args => $args,
		file => $file, line => $line});
    last if $signal;
  }
  $trace = $otrace;
  @sub;
}

sub action {
    my $action = shift;
    while ($action =~ s/\\$//) {
	#print $OUT "+ ";
	#$action .= "\n";
	$action .= &gets;
    }
    $action;
}

sub unbalanced { 
    # i hate using globals!
    $balanced_brace_re ||= qr{ 
	^ \{
	      (?:
		 (?> [^{}] + )    	    # Non-parens without backtracking
	       |
		 (??{ $balanced_brace_re }) # Group with matching parens
	      ) *
	  \} $
   }x;
   return $_[0] !~ m/$balanced_brace_re/;
}

sub gets {
    &readline("cont: ");
}

sub system {
    # We save, change, then restore STDIN and STDOUT to avoid fork() since
    # some non-Unix systems can do system() but have problems with fork().
    open(SAVEIN,"<&STDIN") || &warn("Can't save STDIN");
    open(SAVEOUT,">&STDOUT") || &warn("Can't save STDOUT");
    open(STDIN,"<&IN") || &warn("Can't redirect STDIN");
    open(STDOUT,">&OUT") || &warn("Can't redirect STDOUT");

    # XXX: using csh or tcsh destroys sigint retvals!
    system(@_);
    open(STDIN,"<&SAVEIN") || &warn("Can't restore STDIN");
    open(STDOUT,">&SAVEOUT") || &warn("Can't restore STDOUT");
    close(SAVEIN); 
    close(SAVEOUT);


    # most of the $? crud was coping with broken cshisms
    if ($? >> 8) {
	&warn("(Command exited ", ($? >> 8), ")\n");
    } elsif ($?) { 
	&warn( "(Command died of SIG#",  ($? & 127),
	    (($? & 128) ? " -- core dumped" : "") , ")", "\n");
    } 

    return $?;

}

sub setterm {
    local $frame = 0;
    local $doret = -2;
    eval { require Term::ReadLine } or die $@;
    if ($notty) {
	if ($tty) {
	    open(IN,"<$tty") or die "Cannot open TTY `$TTY' for read: $!";
	    open(OUT,">$tty") or die "Cannot open TTY `$TTY' for write: $!";
	    $IN = \*IN;
	    $OUT = \*OUT;
	    my $sel = select($OUT);
	    $| = 1;
	    select($sel);
	} else {
	    eval "require Term::Rendezvous;" or die;
	    my $rv = $ENV{PERLDB_NOTTY} || "/tmp/perldbtty$$";
	    my $term_rv = new Term::Rendezvous $rv;
	    $IN = $term_rv->IN;
	    $OUT = $term_rv->OUT;
	}
    }
    if (!$rl) {
	$term = new Term::ReadLine::Stub 'perldb', $IN, $OUT;
    } else {
	$term = new Term::ReadLine 'perldb', $IN, $OUT;

	$rl_attribs = $term->Attribs;
	$rl_attribs->{basic_word_break_characters} .= '-:+/*,[])}' 
	  if defined $rl_attribs->{basic_word_break_characters} 
	    and index($rl_attribs->{basic_word_break_characters}, ":") == -1;
	$rl_attribs->{special_prefixes} = '$@&%';
	$rl_attribs->{completer_word_break_characters} .= '$@&%';
	$rl_attribs->{completion_function} = \&db_complete; 
    }
    $LINEINFO = $OUT unless defined $LINEINFO;
    $lineinfo = $console unless defined $lineinfo;
    $term->MinLine(2);
    if ($term->Features->{setHistory} and "@hist" ne "?") {
      $term->SetHistory(@hist);
    }
    ornaments($ornaments) if defined $ornaments;
    $term_pid = $$;
}

sub resetterm {			# We forked, so we need a different TTY
    $term_pid = $$;
    if (defined &get_fork_TTY) {
      &get_fork_TTY;
    } elsif (not defined $fork_TTY 
	     and defined $ENV{TERM} and $ENV{TERM} eq 'xterm' 
	     and defined $ENV{WINDOWID} and defined $ENV{DISPLAY}) { 
        # Possibly _inside_ XTERM
        open XT, q[3>&1 xterm -title 'Forked Perl debugger' -e sh -c 'tty 1>&3;\
 sleep 10000000' |];
        $fork_TTY = <XT>;
        chomp $fork_TTY;
    }
    if (defined $fork_TTY) {
      TTY($fork_TTY);
      undef $fork_TTY;
    } else {
      print_help(<<EOP);
I<#########> Forked, but do not know how to change a B<TTY>. I<#########>
  Define B<\$DB::fork_TTY> 
       - or a function B<DB::get_fork_TTY()> which will set B<\$DB::fork_TTY>.
  The value of B<\$DB::fork_TTY> should be the name of I<TTY> to use.
  On I<UNIX>-like systems one can get the name of a I<TTY> for the given window
  by typing B<tty>, and disconnect the I<shell> from I<TTY> by B<sleep 1000000>.
EOP
    }
}

sub readline {
  local $.;
  if (@typeahead) {
    my $left = @typeahead;
    my $got = shift @typeahead;
    print $OUT "auto(-$left)", shift, $got, "\n";
    $term->AddHistory($got) 
      if length($got) > 1 and defined $term->Features->{addHistory};
    return $got;
  }
  local $frame = 0;
  local $doret = -2;
  if (ref $OUT and UNIVERSAL::isa($OUT, 'IO::Socket::INET')) {
    $OUT->write(join('', @_));
    my $stuff;
    $IN->recv( $stuff, 2048 );  # XXX: what's wrong with sysread?
    $stuff;
  }
  else {
    $term->readline(@_);
  }
}

sub dump_option {
    my ($opt, $val)= @_;
    $val = option_val($opt,'N/A');
    $val =~ s/([\\\'])/\\$1/g;
    printf $OUT "%20s = '%s'\n", $opt, $val;
}

sub option_val {
    my ($opt, $default)= @_;
    my $val;
    if (defined $optionVars{$opt}
	and defined ${$optionVars{$opt}}) {
	$val = ${$optionVars{$opt}};
    } elsif (defined $optionAction{$opt}
	and defined &{$optionAction{$opt}}) {
	$val = &{$optionAction{$opt}}();
    } elsif (defined $optionAction{$opt}
	     and not defined $option{$opt}
	     or defined $optionVars{$opt}
	     and not defined ${$optionVars{$opt}}) {
	$val = $default;
    } else {
	$val = $option{$opt};
    }
    $val
}

sub parse_options {
    local($_)= @_;
    # too dangerous to let intuitive usage overwrite important things
    # defaultion should never be the default
    my %opt_needs_val = map { ( $_ => 1 ) } qw{
        arrayDepth hashDepth LineInfo maxTraceLen ornaments
        pager quote ReadLine recallCommand RemotePort ShellBang TTY
    };
    while (length) {
	my $val_defaulted;
	s/^\s+// && next;
	s/^(\w+)(\W?)// or print($OUT "Invalid option `$_'\n"), last;
	my ($opt,$sep) = ($1,$2);
	my $val;
	if ("?" eq $sep) {
	    print($OUT "Option query `$opt?' followed by non-space `$_'\n"), last
	      if /^\S/;
	    #&dump_option($opt);
	} elsif ($sep !~ /\S/) {
	    $val_defaulted = 1;
	    $val = "1";  #  this is an evil default; make 'em set it!
	} elsif ($sep eq "=") {

            if (s/ (["']) ( (?: \\. | (?! \1 ) [^\\] )* ) \1 //x) { 
                my $quote = $1;
                ($val = $2) =~ s/\\([$quote\\])/$1/g;
	    } else { 
		s/^(\S*)//;
	    $val = $1;
		print OUT qq(Option better cleared using $opt=""\n)
		    unless length $val;
	    }

	} else { #{ to "let some poor schmuck bounce on the % key in B<vi>."
	    my ($end) = "\\" . substr( ")]>}$sep", index("([<{",$sep), 1 ); #}
	    s/^(([^\\$end]|\\[\\$end])*)$end($|\s+)// or
	      print($OUT "Unclosed option value `$opt$sep$_'\n"), last;
	    ($val = $1) =~ s/\\([\\$end])/$1/g;
	}

	my $option;
	my $matches = grep( /^\Q$opt/  && ($option = $_),  @options  )
		   || grep( /^\Q$opt/i && ($option = $_),  @options  );

	print($OUT "Unknown option `$opt'\n"), next 	unless $matches;
	print($OUT "Ambiguous option `$opt'\n"), next 	if $matches > 1;

       if ($opt_needs_val{$option} && $val_defaulted) {
	    print $OUT "Option `$opt' is non-boolean.  Use `O $option=VAL' to set, `O $option?' to query\n";
	    next;
	} 

	$option{$option} = $val if defined $val;

	eval qq{
		local \$frame = 0; 
		local \$doret = -2; 
	        require '$optionRequire{$option}';
		1;
	 } || die  # XXX: shouldn't happen
	    if  defined $optionRequire{$option}	    &&
	        defined $val;

	${$optionVars{$option}} = $val 	    
	    if  defined $optionVars{$option}        &&
		defined $val;

	&{$optionAction{$option}} ($val)    
	    if defined $optionAction{$option}	    &&
               defined &{$optionAction{$option}}    &&
               defined $val;

	# Not $rcfile
	dump_option($option) 	unless $OUT eq \*STDERR; 
    }
}

sub set_list {
  my ($stem,@list) = @_;
  my $val;
  $ENV{"${stem}_n"} = @list;
  for $i (0 .. $#list) {
    $val = $list[$i];
    $val =~ s/\\/\\\\/g;
    $val =~ s/([\0-\37\177\200-\377])/"\\0x" . unpack('H2',$1)/eg;
    $ENV{"${stem}_$i"} = $val;
  }
}

sub get_list {
  my $stem = shift;
  my @list;
  my $n = delete $ENV{"${stem}_n"};
  my $val;
  for $i (0 .. $n - 1) {
    $val = delete $ENV{"${stem}_$i"};
    $val =~ s/\\((\\)|0x(..))/ $2 ? $2 : pack('H2', $3) /ge;
    push @list, $val;
  }
  @list;
}

sub catch {
    $signal = 1;
    return;			# Put nothing on the stack - malloc/free land!
}

sub warn {
    my($msg)= join("",@_);
    $msg .= ": $!\n" unless $msg =~ /\n$/;
    print $OUT $msg;
}

sub TTY {
    if (@_ and $term and $term->Features->{newTTY}) {
      my ($in, $out) = shift;
      if ($in =~ /,/) {
	($in, $out) = split /,/, $in, 2;
      } else {
	$out = $in;
      }
      open IN, $in or die "cannot open `$in' for read: $!";
      open OUT, ">$out" or die "cannot open `$out' for write: $!";
      $term->newTTY(\*IN, \*OUT);
      $IN	= \*IN;
      $OUT	= \*OUT;
      return $tty = $in;
    } elsif ($term and @_) {
	&warn("Too late to set TTY, enabled on next `R'!\n");
    } 
    $tty = shift if @_;
    $tty or $console;
}

sub noTTY {
    if ($term) {
	&warn("Too late to set noTTY, enabled on next `R'!\n") if @_;
    }
    $notty = shift if @_;
    $notty;
}

sub ReadLine {
    if ($term) {
	&warn("Too late to set ReadLine, enabled on next `R'!\n") if @_;
    }
    $rl = shift if @_;
    $rl;
}

sub RemotePort {
    if ($term) {
        &warn("Too late to set RemotePort, enabled on next 'R'!\n") if @_;
    }
    $remoteport = shift if @_;
    $remoteport;
}

sub tkRunning {
    if (${$term->Features}{tkRunning}) {
        return $term->tkRunning(@_);
    } else {
	print $OUT "tkRunning not supported by current ReadLine package.\n";
	0;
    }
}

sub NonStop {
    if ($term) {
	&warn("Too late to set up NonStop mode, enabled on next `R'!\n") if @_;
    }
    $runnonstop = shift if @_;
    $runnonstop;
}

sub pager {
    if (@_) {
	$pager = shift;
	$pager="|".$pager unless $pager =~ /^(\+?\>|\|)/;
    }
    $pager;
}

sub shellBang {
    if (@_) {
	$sh = quotemeta shift;
	$sh .= "\\b" if $sh =~ /\w$/;
    }
    $psh = $sh;
    $psh =~ s/\\b$//;
    $psh =~ s/\\(.)/$1/g;
    &sethelp;
    $psh;
}

sub ornaments {
  if (defined $term) {
    local ($warnLevel,$dieLevel) = (0, 1);
    return '' unless $term->Features->{ornaments};
    eval { $term->ornaments(@_) } || '';
  } else {
    $ornaments = shift;
  }
}

sub recallCommand {
    if (@_) {
	$rc = quotemeta shift;
	$rc .= "\\b" if $rc =~ /\w$/;
    }
    $prc = $rc;
    $prc =~ s/\\b$//;
    $prc =~ s/\\(.)/$1/g;
    &sethelp;
    $prc;
}

sub LineInfo {
    return $lineinfo unless @_;
    $lineinfo = shift;
    my $stream = ($lineinfo =~ /^(\+?\>|\|)/) ? $lineinfo : ">$lineinfo";
    $slave_editor = ($stream =~ /^\|/);
    open(LINEINFO, "$stream") || &warn("Cannot open `$stream' for write");
    $LINEINFO = \*LINEINFO;
    my $save = select($LINEINFO);
    $| = 1;
    select($save);
    $lineinfo;
}

sub list_versions {
  my %version;
  my $file;
  for (keys %INC) {
    $file = $_;
    s,\.p[lm]$,,i ;
    s,/,::,g ;
    s/^perl5db$/DB/;
    s/^Term::ReadLine::readline$/readline/;
    if (defined ${ $_ . '::VERSION' }) {
      $version{$file} = "${ $_ . '::VERSION' } from ";
    } 
    $version{$file} .= $INC{$file};
  }
  dumpit($OUT,\%version);
}

sub sethelp {
    # XXX: make sure these are tabs between the command and explantion,
    #      or print_help will screw up your formatting if you have
    #      eeevil ornaments enabled.  This is an insane mess.

    $help = "
B<T>		Stack trace.
B<s> [I<expr>]	Single step [in I<expr>].
B<n> [I<expr>]	Next, steps over subroutine calls [in I<expr>].
<B<CR>>		Repeat last B<n> or B<s> command.
B<r>		Return from current subroutine.
B<c> [I<line>|I<sub>]	Continue; optionally inserts a one-time-only breakpoint
		at the specified position.
B<l> I<min>B<+>I<incr>	List I<incr>+1 lines starting at I<min>.
B<l> I<min>B<->I<max>	List lines I<min> through I<max>.
B<l> I<line>		List single I<line>.
B<l> I<subname>	List first window of lines from subroutine.
B<l> I<\$var>		List first window of lines from subroutine referenced by I<\$var>.
B<l>		List next window of lines.
B<->		List previous window of lines.
B<w> [I<line>]	List window around I<line>.
B<.>		Return to the executed line.
B<f> I<filename>	Switch to viewing I<filename>. File must be already loaded.
		I<filename> may be either the full name of the file, or a regular
		expression matching the full file name:
		B<f> I</home/me/foo.pl> and B<f> I<oo\\.> may access the same file.
		Evals (with saved bodies) are considered to be filenames:
		B<f> I<(eval 7)> and B<f> I<eval 7\\b> access the body of the 7th eval
		(in the order of execution).
B</>I<pattern>B</>	Search forwards for I<pattern>; final B</> is optional.
B<?>I<pattern>B<?>	Search backwards for I<pattern>; final B<?> is optional.
B<L>		List all breakpoints and actions.
B<S> [[B<!>]I<pattern>]	List subroutine names [not] matching I<pattern>.
B<t>		Toggle trace mode.
B<t> I<expr>		Trace through execution of I<expr>.
B<b> [I<line>] [I<condition>]
		Set breakpoint; I<line> defaults to the current execution line;
		I<condition> breaks if it evaluates to true, defaults to '1'.
B<b> I<subname> [I<condition>]
		Set breakpoint at first line of subroutine.
B<b> I<\$var>		Set breakpoint at first line of subroutine referenced by I<\$var>.
B<b> B<load> I<filename> Set breakpoint on `require'ing the given file.
B<b> B<postpone> I<subname> [I<condition>]
		Set breakpoint at first line of subroutine after 
		it is compiled.
B<b> B<compile> I<subname>
		Stop after the subroutine is compiled.
B<d> [I<line>]	Delete the breakpoint for I<line>.
B<D>		Delete all breakpoints.
B<a> [I<line>] I<command>
		Set an action to be done before the I<line> is executed;
		I<line> defaults to the current execution line.
		Sequence is: check for breakpoint/watchpoint, print line
		if necessary, do action, prompt user if necessary,
		execute line.
B<a> [I<line>]	Delete the action for I<line>.
B<A>		Delete all actions.
B<W> I<expr>		Add a global watch-expression.
B<W>		Delete all watch-expressions.
B<V> [I<pkg> [I<vars>]]	List some (default all) variables in package (default current).
		Use B<~>I<pattern> and B<!>I<pattern> for positive and negative regexps.
B<X> [I<vars>]	Same as \"B<V> I<currentpackage> [I<vars>]\".
B<x> I<expr>		Evals expression in list context, dumps the result.
B<m> I<expr>		Evals expression in list context, prints methods callable
		on the first element of the result.
B<m> I<class>		Prints methods callable via the given class.

B<<> ?			List Perl commands to run before each prompt.
B<<> I<expr>		Define Perl command to run before each prompt.
B<<<> I<expr>		Add to the list of Perl commands to run before each prompt.
B<>> ?			List Perl commands to run after each prompt.
B<>> I<expr>		Define Perl command to run after each prompt.
B<>>B<>> I<expr>		Add to the list of Perl commands to run after each prompt.
B<{> I<db_command>	Define debugger command to run before each prompt.
B<{> ?			List debugger commands to run before each prompt.
B<<> I<expr>		Define Perl command to run before each prompt.
B<{{> I<db_command>	Add to the list of debugger commands to run before each prompt.
B<$prc> I<number>	Redo a previous command (default previous command).
B<$prc> I<-number>	Redo number'th-to-last command.
B<$prc> I<pattern>	Redo last command that started with I<pattern>.
		See 'B<O> I<recallCommand>' too.
B<$psh$psh> I<cmd>  	Run cmd in a subprocess (reads from DB::IN, writes to DB::OUT)"
  . ( $rc eq $sh ? "" : "
B<$psh> [I<cmd>] 	Run I<cmd> in subshell (forces \"\$SHELL -c 'cmd'\")." ) . "
		See 'B<O> I<shellBang>' too.
B<H> I<-number>	Display last number commands (default all).
B<p> I<expr>		Same as \"I<print {DB::OUT} expr>\" in current package.
B<|>I<dbcmd>		Run debugger command, piping DB::OUT to current pager.
B<||>I<dbcmd>		Same as B<|>I<dbcmd> but DB::OUT is temporarilly select()ed as well.
B<\=> [I<alias> I<value>]	Define a command alias, or list current aliases.
I<command>		Execute as a perl statement in current package.
B<v>		Show versions of loaded modules.
B<R>		Pure-man-restart of debugger, some of debugger state
		and command-line options may be lost.
		Currently the following setting are preserved: 
		history, breakpoints and actions, debugger B<O>ptions 
		and the following command-line options: I<-w>, I<-I>, I<-e>.

B<O> [I<opt>] ...	Set boolean option to true
B<O> [I<opt>B<?>]	Query options
B<O> [I<opt>B<=>I<val>] [I<opt>=B<\">I<val>B<\">] ... 
		Set options.  Use quotes in spaces in value.
    I<recallCommand>, I<ShellBang>	chars used to recall command or spawn shell;
    I<pager>			program for output of \"|cmd\";
    I<tkRunning>			run Tk while prompting (with ReadLine);
    I<signalLevel> I<warnLevel> I<dieLevel>	level of verbosity;
    I<inhibit_exit>		Allows stepping off the end of the script.
    I<ImmediateStop>		Debugger should stop as early as possible.
    I<RemotePort>			Remote hostname:port for remote debugging
  The following options affect what happens with B<V>, B<X>, and B<x> commands:
    I<arrayDepth>, I<hashDepth> 	print only first N elements ('' for all);
    I<compactDump>, I<veryCompact> 	change style of array and hash dump;
    I<globPrint> 			whether to print contents of globs;
    I<DumpDBFiles> 		dump arrays holding debugged files;
    I<DumpPackages> 		dump symbol tables of packages;
    I<DumpReused> 			dump contents of \"reused\" addresses;
    I<quote>, I<HighBit>, I<undefPrint> 	change style of string dump;
    I<bareStringify> 		Do not print the overload-stringified value;
  Other options include:
    I<PrintRet>		affects printing of return value after B<r> command,
    I<frame>		affects printing messages on entry and exit from subroutines.
    I<AutoTrace>	affects printing messages on every possible breaking point.
    I<maxTraceLen>	gives maximal length of evals/args listed in stack trace.
    I<ornaments> 	affects screen appearance of the command line.
	During startup options are initialized from \$ENV{PERLDB_OPTS}.
	You can put additional initialization options I<TTY>, I<noTTY>,
	I<ReadLine>, I<NonStop>, and I<RemotePort> there (or use
	`B<R>' after you set them).

B<q> or B<^D>		Quit. Set B<\$DB::finished = 0> to debug global destruction.
B<h> [I<db_command>]	Get help [on a specific debugger command], enter B<|h> to page.
B<h h>		Summary of debugger commands.
B<$doccmd> I<manpage>	Runs the external doc viewer B<$doccmd> command on the 
		named Perl I<manpage>, or on B<$doccmd> itself if omitted.
		Set B<\$DB::doccmd> to change viewer.

Type `|h' for a paged display if this was too hard to read.

"; # Fix balance of vi % matching: } }}

    $summary = <<"END_SUM";
I<List/search source lines:>               I<Control script execution:>
  B<l> [I<ln>|I<sub>]  List source code            B<T>           Stack trace
  B<-> or B<.>      List previous/current line  B<s> [I<expr>]    Single step [in expr]
  B<w> [I<line>]    List around line            B<n> [I<expr>]    Next, steps over subs
  B<f> I<filename>  View source in file         <B<CR>/B<Enter>>  Repeat last B<n> or B<s>
  B</>I<pattern>B</> B<?>I<patt>B<?>   Search forw/backw    B<r>           Return from subroutine
  B<v>	      Show versions of modules    B<c> [I<ln>|I<sub>]  Continue until position
I<Debugger controls:>                        B<L>           List break/watch/actions
  B<O> [...]     Set debugger options        B<t> [I<expr>]    Toggle trace [trace expr]
  B<<>[B<<>]|B<{>[B<{>]|B<>>[B<>>] [I<cmd>] Do pre/post-prompt B<b> [I<ln>|I<event>|I<sub>] [I<cnd>] Set breakpoint
  B<$prc> [I<N>|I<pat>]   Redo a previous command     B<d> [I<ln>] or B<D> Delete a/all breakpoints
  B<H> [I<-num>]    Display last num commands   B<a> [I<ln>] I<cmd>  Do cmd before line
  B<=> [I<a> I<val>]   Define/list an alias        B<W> I<expr>      Add a watch expression
  B<h> [I<db_cmd>]  Get help on command         B<A> or B<W>      Delete all actions/watch
  B<|>[B<|>]I<db_cmd>  Send output to pager        B<$psh>\[B<$psh>\] I<syscmd> Run cmd in a subprocess
  B<q> or B<^D>     Quit			  B<R>	      Attempt a restart
I<Data Examination:>	      B<expr>     Execute perl code, also see: B<s>,B<n>,B<t> I<expr>
  B<x>|B<m> I<expr>	Evals expr in list context, dumps the result or lists methods.
  B<p> I<expr>	Print expression (uses script's current package).
  B<S> [[B<!>]I<pat>]	List subroutine names [not] matching pattern
  B<V> [I<Pk> [I<Vars>]]	List Variables in Package.  Vars can be ~pattern or !pattern.
  B<X> [I<Vars>]	Same as \"B<V> I<current_package> [I<Vars>]\".
For more help, type B<h> I<cmd_letter>, or run B<$doccmd perldebug> for all docs.
END_SUM
				# ')}}; # Fix balance of vi % matching
}

sub print_help {
    local $_ = shift;

    # Restore proper alignment destroyed by eeevil I<> and B<>
    # ornaments: A pox on both their houses!
    #
    # A help command will have everything up to and including
    # the first tab sequence paddeed into a field 16 (or if indented 20)
    # wide.  If it's wide than that, an extra space will be added.
    s{
	^ 		    	# only matters at start of line
	  ( \040{4} | \t )*	# some subcommands are indented
	  ( < ? 		# so <CR> works
	    [BI] < [^\t\n] + )  # find an eeevil ornament
	  ( \t+ )		# original separation, discarded
	  ( .* )		# this will now start (no earlier) than 
				# column 16
    } {
	my($leadwhite, $command, $midwhite, $text) = ($1, $2, $3, $4);
	my $clean = $command;
	$clean =~ s/[BI]<([^>]*)>/$1/g;  
    # replace with this whole string:
	(length($leadwhite) ? " " x 4 : "")
      . $command
      . ((" " x (16 + (length($leadwhite) ? 4 : 0) - length($clean))) || " ")
      . $text;

    }mgex;

    s{				# handle bold ornaments
	B < ( [^>] + | > ) >
    } {
	  $Term::ReadLine::TermCap::rl_term_set[2] 
	. $1
	. $Term::ReadLine::TermCap::rl_term_set[3]
    }gex;

    s{				# handle italic ornaments
	I < ( [^>] + | > ) >
    } {
	  $Term::ReadLine::TermCap::rl_term_set[0] 
	. $1
	. $Term::ReadLine::TermCap::rl_term_set[1]
    }gex;

    print $OUT $_;
}

sub fix_less {
    return if defined $ENV{LESS} && $ENV{LESS} =~ /r/;
    my $is_less = $pager =~ /\bless\b/;
    if ($pager =~ /\bmore\b/) { 
	my @st_more = stat('/usr/bin/more');
	my @st_less = stat('/usr/bin/less');
	$is_less = @st_more    && @st_less 
		&& $st_more[0] == $st_less[0] 
		&& $st_more[1] == $st_less[1];
    }
    # changes environment!
    $ENV{LESS} .= 'r' 	if $is_less;
}

sub diesignal {
    local $frame = 0;
    local $doret = -2;
    $SIG{'ABRT'} = 'DEFAULT';
    kill 'ABRT', $$ if $panic++;
    if (defined &Carp::longmess) {
	local $SIG{__WARN__} = '';
	local $Carp::CarpLevel = 2;		# mydie + confess
	&warn(Carp::longmess("Signal @_"));
    }
    else {
	print $DB::OUT "Got signal @_\n";
    }
    kill 'ABRT', $$;
}

sub dbwarn { 
  local $frame = 0;
  local $doret = -2;
  local $SIG{__WARN__} = '';
  local $SIG{__DIE__} = '';
  eval { require Carp } if defined $^S;	# If error/warning during compilation,
                                        # require may be broken.
  warn(@_, "\nCannot print stack trace, load with -MCarp option to see stack"),
    return unless defined &Carp::longmess;
  my ($mysingle,$mytrace) = ($single,$trace);
  $single = 0; $trace = 0;
  my $mess = Carp::longmess(@_);
  ($single,$trace) = ($mysingle,$mytrace);
  &warn($mess); 
}

sub dbdie {
  local $frame = 0;
  local $doret = -2;
  local $SIG{__DIE__} = '';
  local $SIG{__WARN__} = '';
  my $i = 0; my $ineval = 0; my $sub;
  if ($dieLevel > 2) {
      local $SIG{__WARN__} = \&dbwarn;
      &warn(@_);		# Yell no matter what
      return;
  }
  if ($dieLevel < 2) {
    die @_ if $^S;		# in eval propagate
  }
  eval { require Carp } if defined $^S;	# If error/warning during compilation,
                                	# require may be broken.

  die(@_, "\nCannot print stack trace, load with -MCarp option to see stack")
    unless defined &Carp::longmess;

  # We do not want to debug this chunk (automatic disabling works
  # inside DB::DB, but not in Carp).
  my ($mysingle,$mytrace) = ($single,$trace);
  $single = 0; $trace = 0;
  my $mess = Carp::longmess(@_);
  ($single,$trace) = ($mysingle,$mytrace);
  die $mess;
}

sub warnLevel {
  if (@_) {
    $prevwarn = $SIG{__WARN__} unless $warnLevel;
    $warnLevel = shift;
    if ($warnLevel) {
      $SIG{__WARN__} = \&DB::dbwarn;
    } else {
      $SIG{__WARN__} = $prevwarn;
    }
  }
  $warnLevel;
}

sub dieLevel {
  if (@_) {
    $prevdie = $SIG{__DIE__} unless $dieLevel;
    $dieLevel = shift;
    if ($dieLevel) {
      $SIG{__DIE__} = \&DB::dbdie; # if $dieLevel < 2;
      #$SIG{__DIE__} = \&DB::diehard if $dieLevel >= 2;
      print $OUT "Stack dump during die enabled", 
        ( $dieLevel == 1 ? " outside of evals" : ""), ".\n"
	  if $I_m_init;
      print $OUT "Dump printed too.\n" if $dieLevel > 2;
    } else {
      $SIG{__DIE__} = $prevdie;
      print $OUT "Default die handler restored.\n";
    }
  }
  $dieLevel;
}

sub signalLevel {
  if (@_) {
    $prevsegv = $SIG{SEGV} unless $signalLevel;
    $prevbus = $SIG{BUS} unless $signalLevel;
    $signalLevel = shift;
    if ($signalLevel) {
      $SIG{SEGV} = \&DB::diesignal;
      $SIG{BUS} = \&DB::diesignal;
    } else {
      $SIG{SEGV} = $prevsegv;
      $SIG{BUS} = $prevbus;
    }
  }
  $signalLevel;
}

sub CvGV_name {
  my $in = shift;
  my $name = CvGV_name_or_bust($in);
  defined $name ? $name : $in;
}

sub CvGV_name_or_bust {
  my $in = shift;
  return if $skipCvGV;		# Backdoor to avoid problems if XS broken...
  $in = \&$in;			# Hard reference...
  eval {require Devel::Peek; 1} or return;
  my $gv = Devel::Peek::CvGV($in) or return;
  *$gv{PACKAGE} . '::' . *$gv{NAME};
}

sub find_sub {
  my $subr = shift;
  $sub{$subr} or do {
    return unless defined &$subr;
    my $name = CvGV_name_or_bust($subr);
    my $data;
    $data = $sub{$name} if defined $name;
    return $data if defined $data;

    # Old stupid way...
    $subr = \&$subr;		# Hard reference
    my $s;
    for (keys %sub) {
      $s = $_, last if $subr eq \&$_;
    }
    $sub{$s} if $s;
  }
}

sub methods {
  my $class = shift;
  $class = ref $class if ref $class;
  local %seen;
  local %packs;
  methods_via($class, '', 1);
  methods_via('UNIVERSAL', 'UNIVERSAL', 0);
}

sub methods_via {
  my $class = shift;
  return if $packs{$class}++;
  my $prefix = shift;
  my $prepend = $prefix ? "via $prefix: " : '';
  my $name;
  for $name (grep {defined &{${"${class}::"}{$_}}} 
	     sort keys %{"${class}::"}) {
    next if $seen{ $name }++;
    print $DB::OUT "$prepend$name\n";
  }
  return unless shift;		# Recurse?
  for $name (@{"${class}::ISA"}) {
    $prepend = $prefix ? $prefix . " -> $name" : $name;
    methods_via($name, $prepend, 1);
  }
}

sub setman { 
    $doccmd = $^O !~ /^(?:MSWin32|VMS|os2|dos|amigaos|riscos|MacOS)\z/s
		? "man"             # O Happy Day!
		: "perldoc";        # Alas, poor unfortunates
}

sub runman {
    my $page = shift;
    unless ($page) {
	&system("$doccmd $doccmd");
	return;
    } 
    # this way user can override, like with $doccmd="man -Mwhatever"
    # or even just "man " to disable the path check.
    unless ($doccmd eq 'man') {
	&system("$doccmd $page");
	return;
    } 

    $page = 'perl' if lc($page) eq 'help';

    require Config;
    my $man1dir = $Config::Config{'man1dir'};
    my $man3dir = $Config::Config{'man3dir'};
    for ($man1dir, $man3dir) { s#/[^/]*\z## if /\S/ } 
    my $manpath = '';
    $manpath .= "$man1dir:" if $man1dir =~ /\S/;
    $manpath .= "$man3dir:" if $man3dir =~ /\S/ && $man1dir ne $man3dir;
    chop $manpath if $manpath;
    # harmless if missing, I figure
    my $oldpath = $ENV{MANPATH};
    $ENV{MANPATH} = $manpath if $manpath;
    my $nopathopt = $^O =~ /dunno what goes here/;
    if (system($doccmd, 
		# I just *know* there are men without -M
		(($manpath && !$nopathopt) ? ("-M", $manpath) : ()),  
	    split ' ', $page) )
    {
	unless ($page =~ /^perl\w/) {
	    if (grep { $page eq $_ } qw{ 
		5004delta 5005delta amiga api apio book boot bot call compile
		cygwin data dbmfilter debug debguts delta diag doc dos dsc embed
		faq faq1 faq2 faq3 faq4 faq5 faq6 faq7 faq8 faq9 filter fork
		form func guts hack hist hpux intern ipc lexwarn locale lol mod
		modinstall modlib number obj op opentut os2 os390 pod port 
		ref reftut run sec style sub syn thrtut tie toc todo toot tootc
		trap unicode var vms win32 xs xstut
	      }) 
	    {
		$page =~ s/^/perl/;
		system($doccmd, 
			(($manpath && !$nopathopt) ? ("-M", $manpath) : ()),  
			$page);
	    }
	}
    } 
    if (defined $oldpath) {
	$ENV{MANPATH} = $manpath;
    } else {
	delete $ENV{MANPATH};
    } 
} 

# The following BEGIN is very handy if debugger goes havoc, debugging debugger?

BEGIN {			# This does not compile, alas.
  $IN = \*STDIN;		# For bugs before DB::OUT has been opened
  $OUT = \*STDERR;		# For errors before DB::OUT has been opened
  $sh = '!';
  $rc = ',';
  @hist = ('?');
  $deep = 100;			# warning if stack gets this deep
  $window = 10;
  $preview = 3;
  $sub = '';
  $SIG{INT} = \&DB::catch;
  # This may be enabled to debug debugger:
  #$warnLevel = 1 unless defined $warnLevel;
  #$dieLevel = 1 unless defined $dieLevel;
  #$signalLevel = 1 unless defined $signalLevel;

  $db_stop = 0;			# Compiler warning
  $db_stop = 1 << 30;
  $level = 0;			# Level of recursive debugging
  # @stack and $doret are needed in sub sub, which is called for DB::postponed.
  # Triggers bug (?) in perl is we postpone this until runtime:
  @postponed = @stack = (0);
  $stack_depth = 0;		# Localized $#stack
  $doret = -2;
  $frame = 0;
}

BEGIN {$^W = $ini_warn;}	# Switch warnings back

#use Carp;			# This did break, left for debuggin

sub db_complete {
  # Specific code for b c l V m f O, &blah, $blah, @blah, %blah
  my($text, $line, $start) = @_;
  my ($itext, $search, $prefix, $pack) =
    ($text, "^\Q${'package'}::\E([^:]+)\$");
  
  return sort grep /^\Q$text/, (keys %sub), qw(postpone load compile), # subroutines
                               (map { /$search/ ? ($1) : () } keys %sub)
    if (substr $line, 0, $start) =~ /^\|*[blc]\s+((postpone|compile)\s+)?$/;
  return sort grep /^\Q$text/, values %INC # files
    if (substr $line, 0, $start) =~ /^\|*b\s+load\s+$/;
  return sort map {($_, db_complete($_ . "::", "V ", 2))}
    grep /^\Q$text/, map { /^(.*)::$/ ? ($1) : ()} keys %:: # top-packages
      if (substr $line, 0, $start) =~ /^\|*[Vm]\s+$/ and $text =~ /^\w*$/;
  return sort map {($_, db_complete($_ . "::", "V ", 2))}
    grep !/^main::/,
      grep /^\Q$text/, map { /^(.*)::$/ ? ($prefix . "::$1") : ()} keys %{$prefix . '::'}
				 # packages
	if (substr $line, 0, $start) =~ /^\|*[Vm]\s+$/ 
	  and $text =~ /^(.*[^:])::?(\w*)$/  and $prefix = $1;
  if ( $line =~ /^\|*f\s+(.*)/ ) { # Loaded files
    # We may want to complete to (eval 9), so $text may be wrong
    $prefix = length($1) - length($text);
    $text = $1;
    return sort 
	map {substr $_, 2 + $prefix} grep /^_<\Q$text/, (keys %main::), $0
  }
  if ((substr $text, 0, 1) eq '&') { # subroutines
    $text = substr $text, 1;
    $prefix = "&";
    return sort map "$prefix$_", 
               grep /^\Q$text/, 
                 (keys %sub),
                 (map { /$search/ ? ($1) : () } 
		    keys %sub);
  }
  if ($text =~ /^[\$@%](.*)::(.*)/) { # symbols in a package
    $pack = ($1 eq 'main' ? '' : $1) . '::';
    $prefix = (substr $text, 0, 1) . $1 . '::';
    $text = $2;
    my @out 
      = map "$prefix$_", grep /^\Q$text/, grep /^_?[a-zA-Z]/, keys %$pack ;
    if (@out == 1 and $out[0] =~ /::$/ and $out[0] ne $itext) {
      return db_complete($out[0], $line, $start);
    }
    return sort @out;
  }
  if ($text =~ /^[\$@%]/) { # symbols (in $package + packages in main)
    $pack = ($package eq 'main' ? '' : $package) . '::';
    $prefix = substr $text, 0, 1;
    $text = substr $text, 1;
    my @out = map "$prefix$_", grep /^\Q$text/, 
       (grep /^_?[a-zA-Z]/, keys %$pack), 
       ( $pack eq '::' ? () : (grep /::$/, keys %::) ) ;
    if (@out == 1 and $out[0] =~ /::$/ and $out[0] ne $itext) {
      return db_complete($out[0], $line, $start);
    }
    return sort @out;
  }
  if ((substr $line, 0, $start) =~ /^\|*O\b.*\s$/) { # Options after a space
    my @out = grep /^\Q$text/, @options;
    my $val = option_val($out[0], undef);
    my $out = '? ';
    if (not defined $val or $val =~ /[\n\r]/) {
      # Can do nothing better
    } elsif ($val =~ /\s/) {
      my $found;
      foreach $l (split //, qq/\"\'\#\|/) {
	$out = "$l$val$l ", last if (index $val, $l) == -1;
      }
    } else {
      $out = "=$val ";
    }
    # Default to value if one completion, to question if many
    $rl_attribs->{completer_terminator_character} = (@out == 1 ? $out : '? ');
    return sort @out;
  }
  return $term->filename_list($text); # filenames
}

sub end_report {
  print $OUT "Use `q' to quit or `R' to restart.  `h q' for details.\n"
}

END {
  $finished = 1 if $inhibit_exit;      # So that some keys may be disabled.
  $fall_off_end = 1 unless $inhibit_exit;
  # Do not stop in at_exit() and destructors on exit:
  $DB::single = !$fall_off_end && !$runnonstop;
  DB::fake::at_exit() unless $fall_off_end or $runnonstop;
}

package DB::fake;

sub at_exit {
  "Debugged program terminated.  Use `q' to quit or `R' to restart.";
}

package DB;			# Do not trace this 1; below!

1;
