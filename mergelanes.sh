#!/usr/bin/env bash

# create some data to play with
# touch id{1,2,3}_L00{1,2,3,4}_R{1,2}_001.fastq.gz

cat <(find *_R1*fastq.gz | sort | paste - - - -) <(find *R2*fastq.gz | sort | paste - - - -) | sort | gawk '{ print "cat",$1,$2,$3,$4,">",gensub(/_L001_(R[12])_001/, "_\\1", "g", $1);}'
