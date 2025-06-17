#!/usr/bin/env bash

# To use this script to build MFORTH on Linux or macOS you will need Wine
# as well as a copy of TASM.EXE and TASM85.TAB in the bin/ directory

MFORTH_COMMIT=$(git log -1 --oneline HEAD | awk '{print $1}')
SRCDIR=$(pwd)/src/MFORTH
# All other paths are relative to SRCDIR
BINDIR=../../bin
TOOLSDIR=../../tools

# TASM seems dumb and tries to look for TASM85.TAB in the current directory
ln -s "${BINDIR}"/TASM85.TAB .

# Assemble MFORTH with the standard, linked-list dictionary.
wine "${BINDIR}"/TASM.EXE -85 -s -b -f00 \
	-dMFORTH_COMMIT="\"$MFORTH_COMMIT\"" \
	main.asm \
	"${BINDIR}"/MFORTH.BX \
	"${BINDIR}"/MFORTH.LST \
	"${BINDIR}"/MFORTH.EXP \
	"${BINDIR}"/MFORTH.SYM 2> /dev/null

# This tool is a mono thing. We have to compile it in a subshell.
(   if [ ! -e "${TOOLSDIR}"/PhashGen.exe ] ; then
        cd ../PhashGen
        xbuild PhashGen.csproj 
        mv obj/Debug/PhashGen.exe "${TOOLSDIR}/"
    fi
)

# Use PhashGen to generate a perfect hash table for the dictionary.
mono "${TOOLSDIR}"/PhashGen.exe \
	"${BINDIR}"/MFORTH.BX \
	"${BINDIR}"/MFORTH.SYM \
	./phash.asm

# Assemble MFORTH again, this time using the perfect hash table.
wine "${BINDIR}"/TASM.EXE -85 -s -b -f00 \
	-dPHASH \
	-dMFORTH_COMMIT="\"$MFORTH_COMMIT\"" \
	main.asm \
	"${BINDIR}"/MFORTH.BX \
	"${BINDIR}"/MFORTH.LST \
	"${BINDIR}"/MFORTH.EXP \
	"${BINDIR}"/MFORTH.SYM 2> /dev/null

# tidy up
rm ./TASM85.TAB
