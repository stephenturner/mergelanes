## Create some data

Let's create some dummy files to work with. Three samples (id1, id2, id3), paired end (R1, R2), split over four lanes (L001, L002, L003, L004).

```sh
touch id{1,2,3}_L00{1,2,3,4}_R{1,2}_001.fastq.gz
ls *.fastq.gz
```

```
id1_L001_R1_001.fastq.gz
id1_L001_R2_001.fastq.gz
id1_L002_R1_001.fastq.gz
id1_L002_R2_001.fastq.gz
id1_L003_R1_001.fastq.gz
id1_L003_R2_001.fastq.gz
id1_L004_R1_001.fastq.gz
id1_L004_R2_001.fastq.gz
id2_L001_R1_001.fastq.gz
id2_L001_R2_001.fastq.gz
id2_L002_R1_001.fastq.gz
id2_L002_R2_001.fastq.gz
id2_L003_R1_001.fastq.gz
id2_L003_R2_001.fastq.gz
id2_L004_R1_001.fastq.gz
id2_L004_R2_001.fastq.gz
id3_L001_R1_001.fastq.gz
id3_L001_R2_001.fastq.gz
id3_L002_R1_001.fastq.gz
id3_L002_R2_001.fastq.gz
id3_L003_R1_001.fastq.gz
id3_L003_R2_001.fastq.gz
id3_L004_R1_001.fastq.gz
id3_L004_R2_001.fastq.gz
```

## Build a command

Let's find all the R1 read files, make sure they're in order, and line up the four lanes with `paste`.

```sh
find *R1*fastq.gz | sort | paste - - - -
```

```
id1_L001_R1_001.fastq.gz	id1_L002_R1_001.fastq.gz	id1_L003_R1_001.fastq.gz	id1_L004_R1_001.fastq.gz
id2_L001_R1_001.fastq.gz	id2_L002_R1_001.fastq.gz	id2_L003_R1_001.fastq.gz	id2_L004_R1_001.fastq.gz
id3_L001_R1_001.fastq.gz	id3_L002_R1_001.fastq.gz	id3_L003_R1_001.fastq.gz	id3_L004_R1_001.fastq.gz
```

Do this with R2 as well, and use process substitution to do it all in one fell swoop.

```sh
cat <(find *R1*fastq.gz | sort | paste - - - -) <(find *R2*fastq.gz | sort | paste - - - -) | sort
```

```
id1_L001_R1_001.fastq.gz	id1_L002_R1_001.fastq.gz	id1_L003_R1_001.fastq.gz	id1_L004_R1_001.fastq.gz
id1_L001_R2_001.fastq.gz	id1_L002_R2_001.fastq.gz	id1_L003_R2_001.fastq.gz	id1_L004_R2_001.fastq.gz
id2_L001_R1_001.fastq.gz	id2_L002_R1_001.fastq.gz	id2_L003_R1_001.fastq.gz	id2_L004_R1_001.fastq.gz
id2_L001_R2_001.fastq.gz	id2_L002_R2_001.fastq.gz	id2_L003_R2_001.fastq.gz	id2_L004_R2_001.fastq.gz
id3_L001_R1_001.fastq.gz	id3_L002_R1_001.fastq.gz	id3_L003_R1_001.fastq.gz	id3_L004_R1_001.fastq.gz
id3_L001_R2_001.fastq.gz	id3_L002_R2_001.fastq.gz	id3_L003_R2_001.fastq.gz	id3_L004_R2_001.fastq.gz
```

The next step uses GNU awk (from homebrew, gives you access to `gensub`). This bit will print the `cat` command, followed by the four read files you're concatenating, then a `>`, then prints out the first lane again, and substitutes out the stuff you don't need, and this is the output file name. It's easier to see what this does by looking at the result.

```sh
gawk '{ print "cat",$1,$2,$3,$4,">",gensub(/_L001_(R[12])_001/, "_\\1", "g", $1);}'
```

```sh
cat <(find *R1*fastq.gz | sort | paste - - - -) <(find *R2*fastq.gz | sort | paste - - - -) | sort | gawk '{ print "cat",$1,$2,$3,$4,">",gensub(/_L001_(R[12])_001/, "_\\1", "g", $1);}'
```

```
cat id1_L001_R1_001.fastq.gz id1_L002_R1_001.fastq.gz id1_L003_R1_001.fastq.gz id1_L004_R1_001.fastq.gz > id1_R1.fastq.gz
cat id1_L001_R2_001.fastq.gz id1_L002_R2_001.fastq.gz id1_L003_R2_001.fastq.gz id1_L004_R2_001.fastq.gz > id1_R2.fastq.gz
cat id2_L001_R1_001.fastq.gz id2_L002_R1_001.fastq.gz id2_L003_R1_001.fastq.gz id2_L004_R1_001.fastq.gz > id2_R1.fastq.gz
cat id2_L001_R2_001.fastq.gz id2_L002_R2_001.fastq.gz id2_L003_R2_001.fastq.gz id2_L004_R2_001.fastq.gz > id2_R2.fastq.gz
cat id3_L001_R1_001.fastq.gz id3_L002_R1_001.fastq.gz id3_L003_R1_001.fastq.gz id3_L004_R1_001.fastq.gz > id3_R1.fastq.gz
cat id3_L001_R2_001.fastq.gz id3_L002_R2_001.fastq.gz id3_L003_R2_001.fastq.gz id3_L004_R2_001.fastq.gz > id3_R2.fastq.gz
```

## A script

The [mergelanes.sh](mergelanes.sh) script in this repository will do this for you, echo'ing out all the commands you'll need to run.

```sh
./mergelanes.sh
```

```
cat id1_L001_R1_001.fastq.gz id1_L002_R1_001.fastq.gz id1_L003_R1_001.fastq.gz id1_L004_R1_001.fastq.gz > id1_R1.fastq.gz
cat id1_L001_R2_001.fastq.gz id1_L002_R2_001.fastq.gz id1_L003_R2_001.fastq.gz id1_L004_R2_001.fastq.gz > id1_R2.fastq.gz
cat id2_L001_R1_001.fastq.gz id2_L002_R1_001.fastq.gz id2_L003_R1_001.fastq.gz id2_L004_R1_001.fastq.gz > id2_R1.fastq.gz
cat id2_L001_R2_001.fastq.gz id2_L002_R2_001.fastq.gz id2_L003_R2_001.fastq.gz id2_L004_R2_001.fastq.gz > id2_R2.fastq.gz
cat id3_L001_R1_001.fastq.gz id3_L002_R1_001.fastq.gz id3_L003_R1_001.fastq.gz id3_L004_R1_001.fastq.gz > id3_R1.fastq.gz
cat id3_L001_R2_001.fastq.gz id3_L002_R2_001.fastq.gz id3_L003_R2_001.fastq.gz id3_L004_R2_001.fastq.gz > id3_R2.fastq.gz
```

Just pipe that to `sh` or `parallel` to run it.

```sh
./mergelanes.sh | sh
```

## Limitations

It's not very flexible. You'll need to modify if you don't have paired end data, or if the read pairs are `_1` and `_2` instead of `_R1` and `_R2`. It also assumes reads are split over four lanes. Again, easy to modify, but probably better to make the script more flexible. Contributions welcome.

## An easier way?

[Suggestion from Wei Shen](https://github.com/stephenturner/mergelanes/issues/1): 

> `cut` is used to split `id1_L001_R1_001.fastq.gz` by `_` to get the sample ID.

```sh
ls *R1* | cut -d _ -f 1 | sort | uniq \
    | while read id; do \
        cat $id*R1*.fastq.gz > $id.R1.fastq.gz;
        cat $id*R2*.fastq.gz > $id.R2.fastq.gz;
      done
```
