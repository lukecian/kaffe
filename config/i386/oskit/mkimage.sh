#!/bin/sh
#
# Copyright (c) 1998, 1999 The University of Utah. All rights reserved.
#
# See the file "license.terms" for information on usage and redistribution
# of this file.
#
# Contributed by the Flux Research Group at the University of Utah.
# Authors: Leigh Stoller, Patrick Tullmann
#

# Build a multiboot image from Kaffe plus other stuff. You can either
# copy this script to your object directory and edit the paths below,
# or you can pass it all in as command line args.
#
# By default, you alway get the contents of the Kaffe
# install/share/kaffe directory (which includes the standard kaffe
# classes) and install/lib/kaffe/*.la (the libtool archive description
# files).
#
# 
# LIBTOOL NOTES:
# 
# When using preloaded (static) libraries, libtool still needs to
# examine the .la files (but not the real archives) at runtime,
# KAFFELIBRARYPATH should contain the directories where all the native
# .la library descriptions can be found.
# 
# KAFFELIBRARYPATH's default value in the OSKit is /lib.  This script
# loads all the .la files into that /lib in the boot image.
# 

# Your Kaffe install directory
KAFFEDIR=/opt/kaffe/install

# where your oskit was installed
OSKITDIR=/opt/oskit/install

# Default classpath file (see the README for a description of this file)
CLASSPATHFILE=default_kaffe_classpath

# Default boot image construction program.  We use Multiboot images.
#  NOTE that mkmb2 is broken in 990722.
MAKEIMAGE=mkmbimage

# default directory to put the new kernel image into
KERNELDIR=.

## ---

# If non-null will be passed as kernel command line
KERNELCOMMANDLINE=

# Make mkimage.sh quiet by making this variable non-nil.
QUIET=

# A list of directories
DIRS=

# A list of unrooted directories
URDIRS=

# A list of explicit file:file pairs to put in the image
EXPLICITFILES=

# Control whether the default_kaffe_classpath is generated by this script or not
CREATE_CLASSPATHFILE=yes

# Parse the command-line options to override above.
until [ $# -eq 0 ]
do
	case "$1" in
		--kerneldir=* )
			KERNELDIR=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;
			shift;;
		--kaffedir=* )
			KAFFEDIR=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;
			shift;;
		--oskitdir=* )
			OSKITDIR=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;
			shift;;
		--makeimage=* )
			MAKEIMAGE=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;
			shift;;
		--classpathfile=* )
			CLASSPATHFILE=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'`;
			CREATE_CLASSPATHFILE=no
			shift;;
		--commandline=* )
			## XXX only works for *arguments to main not env vars*
			KERNELCOMMANDLINE=`echo "$1" | sed 's/[-a-z]*=//'`;
			KERNELCOMMANDLINE="-c \"${KERNELCOMMANDLINE}\""
			shift;;
		--explicitfile=* )
			EXPLICITFILES="$EXPLICITFILES `echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'`" ;
			shift;;
		--help )
			echo "Create a boot image for Kaffe/OSKit"
			echo "Options (and their defaults):"
			echo "  --kerneldir=<dir>       The directory in which to drop the created Image ($IMAGEDIR)"
			echo "  --kaffedir=<dir>        The directory in which kaffe was installed ($KAFFEDIR)"
			echo "  --oskitdir=<dir>        The directory in which the OSKit was installed ($OSKITDIR)"
			echo "  --makeimage=prog        The program to use to create the image ($MAKEIMAGE)"
			echo "  --classpathfile=<file>  The file containing the classpath for Kaffe ($CLASSPATHFILE)"
			echo "         (Note that $CLASSPATHFILE will be generated for you if not specified.)"
			echo "  --explicitfile=<file>[:<imagename>]   Add <file> to the boot image.  Make <file> "
			echo "         visibile in the kernel filesystem as <imagename>."
			echo "  -dir <dir>              Add all the files in <dir> to the image.  No name mapping."
			exit 7;;
		-dir )
			DIRS="$DIRS $2" ;
			shift;
			shift;;
		-unrooteddir )
			URDIRS="$URDIRS $2" ;
			shift;
			shift;;
		* ) echo "Bad arg: $1";
			  exit 8 ;;
	esac
done

if test ! -d $KAFFEDIR; then
    echo "$KAFFEDIR is not a directory.  Specify with --kaffedir=<dir>"
    exit 9
fi
    
if test ! -d $KERNELDIR; then
    echo "ERROR: $KERNELDIR is not a valid directory.  Specify one with --kerneldir=<dir>"
    exit 10
fi


CPF="$CLASSPATHFILE:/etc/kaffe_classpath"

# The Kaffe kernel
KAFFE=$KAFFEDIR/libexec/Kaffe

if test ! -x $KAFFE; then
    echo "ERROR: $KAFFE is not an executable."
    exit 11
fi

# The directory with the minimum necessary class files.
CLASSDIR=$KAFFEDIR/share/kaffe

# The final list of directories
DIRS="$CLASSDIR $DIRS"

MAKEIMAGE=${OSKITDIR}/bin/${MAKEIMAGE}


### Create the classpath file if just using the default
if test $CREATE_CLASSPATHFILE = "yes"; then
    rm -f $CLASSPATHFILE
    touch $CLASSPATHFILE
    for i in $CLASSDIR/*.jar; do
	echo -n "${i}:" >> $CLASSPATHFILE;
    done
    echo "." >> $CLASSPATHFILE;
else 
    if test ! -f $CLASSPATHFILE; then
	echo "$CLASSPATHFILE doesn't exist.  Please create or point elsewhere with --classpathfile=<file>"
	exit 12
    fi
fi

### Print out some 
if test -z "$QUIET"; then
    echo "  Sucking (full-path) all files in: $DIRS"
    echo "  Sucking (rel. path) all files in: $URDIRS"
    echo "  Plus all the *.la files in $KAFFEDIR/lib/kaffe"
    test ! -z "$EXPLICITFILES" && echo "  Plus these files: $EXPLICITFILES"
    echo "  Plus the classpath: $CPF"
fi

rm -f ${KERNELDIR}/Image

# Add all the files in the DIRS and all of the .la files.
{	for DIR in $DIRS
	do
		for FILE in `find -L $DIR -type f -o -type l`
		do
		    echo "$FILE:$FILE"
		done
	done
	for DIR in $URDIRS
	do
		for FILE in `find -L $DIR -type f -o -type l`
		do
		    echo "$FILE:"`echo $FILE | sed -e "s,^$DIR,/,"`
		done
	done

	for FILE in $KAFFEDIR/lib/kaffe/*.la
	do
		echo "$FILE:/lib/"$(basename $FILE)
	done
} | eval $MAKEIMAGE -o $KERNELDIR/Image $KERNELCOMMANDLINE -stdin \
    $KAFFE $CPF $EXPLICITFILES \
    && echo Created $KERNELDIR/Image

exit 0

#eof
