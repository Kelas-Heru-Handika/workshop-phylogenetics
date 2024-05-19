# Segul regex patterns for data cleaning

REGEX_CLEANING="( voucher)(.*)$"

# Run IQ-TREE simple

iqtree2 -s concat.phy -p concat_4genes_partition.txt -m MFP -B 1000 -t AUTO