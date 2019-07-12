#!/usr/bin/perl


package Logger;

use warnings;
use strict;
use File::Basename;
use IO::File;
use POSIX;

sub new {
  my ($class, $args) = @_;
  my $self =  {
      logfile => $args->{logfile} || '',
      log2stdout => $args->{log2stdout} || 1,
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
  return basename($0);
};

my $log_msg = sub {
  my ($facility, $msg, $fh) = @_;
  printf STDOUT "%s %s %s : %s\n", &$get_timestamp, &$get_module, $facility, $msg;
  printf $fh "%s %s %s : %s\n", &$get_timestamp, &$get_module, $facility, $msg if $fh;
};

sub LogInfo {
  my ($self,$msg) = @_;
  &$log_msg('INFO', $msg, $self->{logfile_fh});
}

sub LogWarn {
  my ($self,$msg) = @_;
  &$log_msg('WARN', $msg, $self->{logfile_fh});
}

sub LogError {
  my ($self,$msg) = @_;
  &$log_msg('ERROR', $msg, $self->{logfile_fh});
}

sub LogDebug {
  my ($self,$msg) = @_;
  &$log_msg('DEBUG', $msg, $self->{logfile_fh}) if $self->{debug};
}

1;
