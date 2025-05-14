#!/usr/bin/bash

# To use this script to build MFORTH on Linux you will need Wine
# as well as a copy of TASM.EXE and TASM85.TAB in the bin/ directory
#
# It might be possible to simplify this if you can track down a copy
# of the Linux build of TASM. I haven't been able to find it.

MFORTH_COMMIT=$(git log -1 --oneline HEAD | awk '{print $1}')
SRCDIR=$(dirname $0)/src/MFORTH
# All other paths are relative to SRCDIR
BINDIR=../../bin
TOOLSDIR=../../tools

pushd .
cd $SRCDIR

# TASM seems dumb and tries to look for TASM85.TAB in the current directory
ln -s $BINDIR/TASM85.TAB .

# Assemble MFORTH with the standard, linked-list dictionary.
wine $BINDIR/TASM.EXE -85 -s -b -f00 \
	-dMFORTH_COMMIT="\"$MFORTH_COMMIT\"" \
	main.asm \
	$BINDIR/MFORTH.BX \
	$BINDIR/MFORTH.LST \
	$BINDIR/MFORTH.EXP \
	$BINDIR/MFORTH.SYM

# Use PhashGen to generate a perfect hash table for the dictionary.
wine $TOOLSDIR/PhashGen.exe \
	$BINDIR/MFORTH.BX \
	$BINDIR/MFORTH.SYM \
	./phash.asm

# Assemble MFORTH again, this time using the perfect hash table.
wine $BINDIR/TASM.EXE -85 -s -b -f00 \
	-dPHASH \
	-dMFORTH_COMMIT="\"$MFORTH_COMMIT\"" \
	main.asm \
	$BINDIR/MFORTH.BX \
	$BINDIR/MFORTH.LST \
	$BINDIR/MFORTH.EXP \
	$BINDIR/MFORTH.SYM

# tidy up
rm ./TASM85.TAB
popd
