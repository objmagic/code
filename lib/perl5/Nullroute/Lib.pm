package Nullroute::Lib;
use base "Exporter";
use Carp;
use File::Basename;
use constant {
	true => 1,
	false => 0,
};

our @EXPORT = qw(
	true
	false
	_debug
	_info
	_log
	_notice
	_warn
	_err
	_die
	_usage
	forked
	randstr
	readfile
	trim
	uniq
);

$::arg0 //= basename($0);

$::nested = $ENV{LVL}++;
$::debug = int $ENV{DEBUG};
$::arg0prefix = $::nested || $::debug;

$::warnings = 0;
$::errors = 0;

our $pre_output = undef;
our $post_output = undef;

my $seen_usage = 0;

sub _msg {
	my ($msg, $prefix, $color) = @_;

	my $color = (-t 2) ? $color : "";
	my $reset = (-t 2) ? "\e[m" : "";
	my $name = $::arg0 . ($::debug ? "[$$]" : "");
	my $nameprefix = $::arg0prefix ? "$name: " : "";

	if ($prefix eq "debug") {
		my $n = 1;
		my @frame;
		do {
			++$n;
			@frame = caller($n); # stack frame below _debug()
			$frame[3] //= "main";
			$frame[3] =~ s/^main:://;
		} while ($frame[3] eq "__ANON__");
		#$msg = $frame[1].":".$frame[2]." (".$frame[3].") ".$msg;
		#$msg = "(".$frame[3].") ".$msg;
		$prefix = $prefix." (".$frame[3].")";
	}
	elsif ($prefix eq "usage" && !$::debug && $seen_usage++) {
		$prefix = "   or";
	}

	if ($pre_output) { $pre_output->($msg, $prefix); }

	warn "${nameprefix}${color}${prefix}:${reset} ${msg}\n";

	if ($post_output) { $post_output->($msg, $prefix); }
}

sub _fmsg {
	return _msg(@_) if $::debug;

	my ($msg, $prefix, $color, $fmt_prefix, $fmt_color) = @_;

	my $color = (-t 2) ? $fmt_color : "";
	my $reset = (-t 2) ? "\e[m" : "";
	my $nameprefix = $::arg0prefix ? "$name: " : "";

	if ($pre_output) { $pre_output->($msg, $prefix); }

	warn "${nameprefix}${color}${fmt_prefix}${reset} ${msg}\n";

	if ($post_output) { $post_output->($msg, $prefix); }
}

sub _debug  { _msg(shift, "debug", "\e[36m") if $::debug; }

sub _info   { _msg(shift, "info", "\e[1;34m") if $::debug; }

sub _log    { _fmsg(shift, "log", "\e[1;32m", "--", "\e[32m"); }

sub _notice { _msg(shift, "notice", "\e[1;35m"); }

sub _warn   { _msg(shift, "warning", "\e[1;33m"); ++$::warnings; }

sub _err    { _msg(shift, "error", "\e[1;31m"); ++$::errors; }

sub _die    { _err(shift); exit 1; }

sub _usage  { _msg($::arg0." ".shift, "usage", ""); }

sub forked (&) { fork || exit shift->(); }

sub randstr {
	my $len = shift // 12;

	my @chars = ('A'..'Z', 'a'..'z', '0'..'9');
	join "", map {$chars[int rand @chars]} 1..$len;
}

sub readfile {
	my ($file) = @_;

	open(my $fh, "<", $file) or croak "$!";
	grep {chomp} my @lines = <$fh>;
	close($fh);
	wantarray ? @lines : shift @lines;
}

sub trim { map {s/^\s+//; s/\s+$//; $_} @_; }

sub uniq (@) { my %seen; grep {!$seen{$_}++} @_; }

1;
