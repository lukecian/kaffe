#!/usr/local/bin/perl -w
#
# Dump a java .class file to stdout
#

#
# Copyright (c) 1999 University of Utah CSL.
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# Written by Patrick Tullmann <tullmann@cs.utah.edu>
#

use JavaClass;

# Control the verbosity of &printClass()
$JavaClass::detailedFields = 0;
$JavaClass::detailedMethods = 0;

## Parse the command line
my $classFile = shift  || &usage();

## Read/parse the class file
my $class = &JavaClass::readClass($classFile);

## Print the class filea
&JavaClass::printClass($class);

###
###
###

sub usage() {
  print STDOUT "Usage:\n";
  print STDOUT "    dumpClass.pl <ClassFile>\n\n";
  print STDOUT "    Note that '.class' will be appended if it is not specified in the file name.\n";

  exit 11;
}

#eof
