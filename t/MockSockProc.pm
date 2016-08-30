package MockSockProc;

use strict;
use warnings;

sub mock_exec_succeed {
	my $req = shift;

	my ($cmd, $stdin_count, $stdin) = split /\r\n/, $req;

	my $status = 0;
	my $stdout = "successful exec of $cmd ($stdin)";
	my $outlen = length $stdout;
	my $stderr = '';
	my $errlen = length $stderr;

	return build_response({
		status => $status,
		stdout => $stdout,
		outlen => $outlen,
		stderr => $stderr,
		errlen => $errlen,
	});
}

sub mock_exec_fail {
	my $req = shift;

	my ($cmd, $stdin_count, $stdin) = split /\r\n/, $req;

	my $status = -1;
	my $stdout = '';
	my $outlen = length $stdout;
	my $stderr = "failed to exec $cmd";
	my $errlen = length $stderr;

	return build_response({
		status => $status,
		stdout => $stdout,
		outlen => $outlen,
		stderr => $stderr,
		errlen => $errlen,
	});
}

sub build_response {
	my ($args) = @_;

	my @res;
	push @res, 'status:' . $args->{status};
	push @res, $args->{outlen};
	push @res, $args->{stdout} . $args->{errlen};
	push @res, $args->{stderr};

	return join "\r\n", @res;
}

1;
