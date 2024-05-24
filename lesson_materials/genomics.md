# Intro to Phylogenomics

## Software Requirements

- [ULLAR](https://github.com/hhandika/ullar)
- [Phyluce](https://phyluce.readthedocs.io/en/latest/)
- [IQ-TREE](http://www.iqtree.org/)

## Ullar Installation

```bash
cd ~/downloads
wget https://github.com/hhandika/ullar/releases/download/v0.2.0/ullar-Linux-x86_64.tar.gz

tar xvzf ullar-Linux-x86_64.tar.gz

cp ullar-Linux-x86_64/ullar ~/programs

echo 'export PATH=$PATH:~/programs' >> ~/.bashrc
```

## Try running Ullar

```bash
ullar -v
```

## Prepare ULLAR input

### Rename files

```bash
cd ~/genomics/data/

mv SRR6794552_1.fastq.gz Suncus_murinus_KU164724_1.fastq.gz
mv SRR6794552_2.fastq.gz Suncus_murinus_KU164724_2.fastq.gz
```

### Create ULLAR input

```bash
cd ~/genomics/

ullar new -d data/

## Check config
cat configs/raw_read.yaml
```

## with descriptive sample name

```bash

ullar new -d data/ --sample-name descriptive
```

## Clean reads

```bash
ullar clean -c configs/raw_read.yaml

ullar clean -c configs/raw_read.yaml --process --skip-config-check
```

## Contig assembly

```bash
ullar assemble -c configs/cleaned_read.yaml --process
```

## Download reference

```bash
wget https://raw.githubusercontent.com/faircloth-lab/uce-probe-sets/master/uce-5k-probe-set/uce-5k-probes.fasta
```

## Create symlink

```bash
ullar utils symlink -d assemblies -o assemblies/contig_symlinks
```

## Find UCE loci

```bash
phyluce_assembly_match_contigs_to_probes --contigs assemblies/contig_symlinks --probes uce-5k-probes.fasta --output uce-search-results
```

## Creating taxon set

```bash
mkdir -p taxon-sets/soricidae

ls assemblies/ >> taxon.conf

phyluce_assembly_get_match_counts --locus-db uce-search-results/probe.matches.sqlite --taxon-list-config soricidae.conf --taxon-group 'soricidae' --incomplete-matrix --output taxon-sets/soricidae/soricidae-incomplete.conf
```

## Extract UCE loci

```bash
mkdir log

cd taxon-sets/soricidae

phyluce_assembly_get_fastas_from_match_counts --contigs ../../assemblies/contig_symlinks --locus-db ../../uce-search-results/probe.matches.sqlite --match-count-output soricidae-incomplete.conf --output soricidae-incomplete.fasta --incomplete-matrix soricidae-incomplete.incomplete --log ../../log/soricidae-incomplete.log
```

## Check contig quality

```bash
segul contig summary -i assemblies/*/*-contigs.fasta
```

## Align UCE loci

```bash
cd taxon-sets/soricidae

phyluce_align_seqcap_align --input soricidae-incomplete.fasta --output maff-nexus-edge-trimming --aligner mafft --cores 12 --incomplete-matrix --taxa 2 --core 4 --incomplete-matrix --log-path ../../log/
```

## Clean filenames

```bash
## Check the filenames
segul sequence id -d mafft-nexus-edge-trimming/

segul sequence rename -d mafft-nexus-edge-trimming/ -o mafft-nexus-edge-trimmed-segul-clean --remove-re-all="^(?i)('|.*uce-)\d{1,4}_|(')"
```

## Final matrix

### Summarize alignment

```bash
segul align summary -d mafft-nexus-edge-trimmed-segul-clean/
```

### Filter parsimony informative sites

```bash
segul align filter -d mafft-nexus-edge-trimmed-segul-clean/  --pinf 1
```

### Filter with taxon completeness

```bash
segul align filter --dir mafft-nexus-edge-trimmed-segul-clean/  --percent .8 -o final-matrix-80percentTaxa --concat
```

## Tree inference

```bash
iqtree -s final-matrix-80percentTaxa.nexus -p final-matrix-80percentTaxa_partition.nexus -m GTR+I+G -B 1000 -T 4 --prefix final-matrix-80percentTaxa
```

## With bnni search

```bash
iqtree -s final-matrix-80percentTaxa.nexus -p final-matrix-80percentTaxa_partition.nexus -m GTR+I+G -B 1000 -T 4 --prefix final-matrix-80percentTaxa-bnni -bnni
```
