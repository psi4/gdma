#!/usr/bin/perl -i.bak

$/="";
while (<>) {
  if (/Stone05b/) {
    s/(http.*\+)\./\\url\{$1\}./;
  }
  print;
}
