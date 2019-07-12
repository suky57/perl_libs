#!/usr/bin/perl


package Logger;

=pod

=head1 NAME

Logger.pm

=head1 SYNOPSIS

	use Logger;
	my $log = Logger->new({
		logfile => 'output.log',
		log2stdout => 1,
		debug => 1
	});
	
	$log->LogInfo('Information message ... ');
	$log->LogWarrn('Warning message ... ');
	$log->LogError('ERROR message ...');
	$log->LogDebug('DEBUGGING message ... ');

=head1 DESCRIPTION

Logging module which brings feature to consistent logging to *STDOUT as well as into specified file. If debug => 0 is in place LogDebug function will be ignored.

=cut

use warnings;
use strict;
use File::Basename;
use IO::File;
use POSIX;

sub new {
  my ($class, $args) = @_;
  my $self =  {
      logfile => $args->{logfile} || '',
      log2stdout => ($args->{log2stdout}) ? 1 : 0,
      log2file => ($args->{logfile}) ? 1 : 0,
      debug => $args->{debug} || 0
  };
  if ($args->{logfile}) {
    $self->{logfile_fh} = IO::File->new($args->{logfile}, 'a')
      or die "Log file " . $args->{logfile} . " couldn't be opened!";
  }
  return bless $self, $class;
}

sub DESTROY {
  $_[0]->{logfile_fh}->close() if $_[0]->{logfile};
}

my $get_timestamp = sub {
  return strftime "%Y/%m/%d %H:%M:%S", localtime;
};

my $get_module = sub {
	my $callback = (caller)[3];
	return ($callback) ? $callback : basename($0); 
};

my $log_msg = sub {
  my ($facility, $msg, $fh, $log2stdout) = @_;
  printf STDOUT "%s %s %s : %s\n", &$get_timestamp, &$get_module, $facility, $msg if $log2stdout;
  printf $fh "%s %s %s : %s\n", &$get_timestamp, &$get_module, $facility, $msg if $fh;
};

sub LogInfo {
  my ($self,$msg) = @_;
  &$log_msg('INFO', $msg, $self->{logfile_fh}, $self->{log2stdout});
}

sub LogWarrn {
  my ($self,$msg) = @_;
  &$log_msg('WARN', $msg, $self->{logfile_fh}, $self->{log2stdout});
}

sub LogError {
  my ($self,$msg) = @_;
  &$log_msg('ERROR', $msg, $self->{logfile_fh}, $self->{log2stdout});
}

sub LogDebug {
  my ($self,$msg) = @_;
  &$log_msg('DEBUG', $msg, $self->{logfile_fh}, $self->{log2stdout}) if $self->{debug};
}

=pod

=head1 AUTHOR

Written 2019 by Martin Sukany <martin@sukany.cz>

=cut

1;
