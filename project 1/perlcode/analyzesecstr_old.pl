#!/usr/bin/perl -w

sub analyzesecstr {
# Analysis of secondary structures (RNAfold) which is written as a sequence with the alphabet = {'(', ')', '.'}; the left and the right parenthesis to show a pairing of nts. and the dot to show a mismatch. In a given secondary structure (sequence), 

# 1. Find the largest occurring stem sequence, i.e., defined as the longest sequence of pairings between the miRNA strand and the star(*) strand, occassionally allowing a mismatch (one or two). 

# 2. Find the longest hair loop sequence (bulb)


# Read the sequence from left to right. If a '(' is seen push into the @stack elseif a ')' is seen pop the @stack, elseif a '.' is seen (signifies occurrence of two events: a mismatch in a stem (temporal) or a one among a loop. So do not reset the $len.stem


