# Workflow
# 1. Software used in this workflow
[Easyfig](https://mjsull.github.io/Easyfig/)

[BLASTn](https://github.com/enormandeau/ncbi_blast_tutorial)




# 2.1 Download of publicly available metagenomic and metatranscriptomic data

```shell
# Read the download.txt file

while IFS= read -r url; do
    # Download the file using axel
    axel -a -n20 "$url"
done < download.txt
```

# 2.2 FASTQ format from SRA files

```shell
# Loop through all files starting with SRR or ERR in the current directory

for file in SRR* ERR*; do

    # Check if the file exists and is a regular file

    if [ -f "$file" ]; then
        echo "Processing file: $file"

        # Run the fasterq-dump command

        fasterq-dump --split-3 "$file" -O . -e 30
    else
        echo "File not found: $file"
    fi
done

echo "All files processed."
```

# 2.3 Read trimming

```shell
# Loop through all files ending with _1.fastq in the current directory

for file in *_1.fastq; do
    # Extract the prefix name by removing the _1.fastq suffix
    prefix="${file%_1.fastq}"

    echo "Processing files: ${prefix}_1.fastq and ${prefix}_2.fastq"
    # Run the fastp command
    fastp --thread 16 --in1 "${prefix}_1.fastq" --in2 "${prefix}_2.fastq" --out1 "${prefix}_1.fq" --out2 "${prefix}_2.fq"

done

echo "All files processed."
```

# 2.4 Assembly
```shell
for file in *_1.fq; do

    # Extract the prefix name by removing the _1.fq suffix

    prefix="${file%_1.fq}"

    echo "Processing files: ${prefix}_1.fq and ${prefix}_2.fq"
    
    # Run the megahit command
    megahit -1 "${prefix}_1.fq" -2 "${prefix}_2.fq" --min-contig-len 1000 --k-min 41 -t 110 -o "${prefix}_assembly"
    
    # Find the .fa file in the output directory
    assembly_dir="${prefix}_assembly"
    fa_file=$(find "${assembly_dir}" -type f -name "*.fa")
    
    # Check if the .fa file exists
    if [ -n "${fa_file}" ]; then
        # Rename the .fa file to use the prefix name
        mv "${fa_file}" "${assembly_dir}/${prefix}.fa"
        echo "Renamed ${fa_file} to ${assembly_dir}/${prefix}.fa"
    else
        echo "No .fa file found in ${assembly_dir}"
    fi

done

echo "All files processed."
```

# 2.5 hgcAB catalog construction

```shell
# Loop through all directories ending with "_assembly" in the current directory

for folder in *_assembly; do
    if [ -d "$folder" ]; then
        prefix="${folder%_assembly}"
        file="$folder/$prefix.fa"
        

        # Run prodigal
        prodigal -i "$file" -d "$folder/$prefix.fna" -a "$folder/$prefix.faa"
        
        # Run hmmsearch for hgcA
        hmmsearch hgcA_verified.HMM "$folder/$prefix.faa" > "$folder/hgcA.out"
        
        # Run hmmsearch for hgcB
        hmmsearch hgcB_verified.HMM "$folder/$prefix.faa" > "$folder/hgcB.out"
        
        # Filter the results and extract sequences
        awk '/^>>/ {name = substr($0, 4); next} /E-value/ {if ($5 <= 1E-50 || $7 >= 300 || $7 >= 70) print name}' "$folder/hgcA.out" > "$folder/hgcA_filtered.txt"
        awk '/^>>/ {name = substr($0, 4); next} /E-value/ {if ($5 <= 1E-50 || $7 >= 300 || $7 >= 70) print name}' "$folder/hgcB.out" > "$folder/hgcB_filtered.txt"
        
        # Extract sequences from the faa file
        seqtk subseq "$folder/$prefix.faa" "$folder/hgcA_filtered.txt" > "$folder/hgcA_sequences.faa"
        seqtk subseq "$folder/$prefix.faa" "$folder/hgcB_filtered.txt" > "$folder/hgcB_sequences.faa"
        
        # Extract sequences from the fna file
        seqtk subseq "$folder/$prefix.fna" "$folder/hgcA_filtered.txt" > "$folder/hgcA_sequences.fna"
        seqtk subseq "$folder/$prefix.fna" "$folder/hgcB_filtered.txt" > "$folder/hgcB_sequences.fna"
        
        # Merge all filtered sequences into a single file for each type
        cat "$folder/hgcA_sequences.faa" >> all_hgcA.faa
        cat "$folder/hgcB_sequences.faa" >> all_hgcB.faa
        cat "$folder/hgcA_sequences.fna" >> all_hgcA.fna
        cat "$folder/hgcB_sequences.fna" >> all_hgcB.fna
    fi

done
```

# 2.6 Align the combined sequences using MUSCLE

```shell
muscle -in all_hgcA.faa -out aligned_hgcA_sequences.afa
muscle -in all_hgcB.faa -out aligned_hgcB_sequences.afa

echo "Alignment complete. Please manually review and filter sequences in AliView."

# Instructions for manual filtering in AliView:

# - Manually remove hit sequences without the conserved cap-helix domain [G(I/V)NVWCAAGK]

# - Manually remove sequences without two strictly conserved CX2CX2CX3C ferredoxin-binding motifs (CXXCXXXC)

echo "After manual review, please save the final hgcA and hgcB protein sequences as final_hgcA.faa and final_hgcB.faa respectively."

read -p "Press Enter to continue after saving the final sequences..."
```

# 2.7 Comparing the similarity of hgcA from different sources

```shell
# Directories for different sources

raw_sewage_dir="raw_sewage"
urban_river_dir="urban_river"
natural_env_dir="natural_environment"

# manually classify sequences

echo "Please manually classify the sequences in final_hgcA.fna into the following directories:"
echo "Raw Sewage -> raw_sewage/final_hgcA.fna"
echo "Urban River -> urban_river/final_hgcA.fna"
echo "Natural Environment -> natural_environment/final_hgcA.fna"
echo "After manual classification, please run this script again to perform BLAST comparisons."

# Function to create BLAST database and run BLAST

run_blast() {
    local db_dir=$1
    local query_file="final_hgcA.fna"
    local output_file=$2
    makeblastdb -in "$db_dir/$query_file" -dbtype nucl
    blastn -query "$query_file" -db "$db_dir/$query_file" -out "$output_file" -outfmt 6
}

# Run BLAST comparisons for each source

run_blast "$raw_sewage_dir" "blast_raw_sewage.txt"
run_blast "$urban_river_dir" "blast_urban_river.txt"
run_blast "$natural_env_dir" "blast_natural_env.txt"

echo "BLAST comparisons complete. Results are in blast_raw_sewage.txt, blast_urban_river.txt, and blast_natural_env.txt."
```

# 2.8 download public hgcA sequences

A lagre-scale hgcAB database was downloaded from https://figshare.com/authors/Elizabeth_McDaniel/7519667

```shell
# Merge hgcA sequences with public sequences and remove redundancy

seqtk subseq all_hgcA.fna final_hgcA.faa > final_hgcA.fna
cat final_hgcA.fna hgcA_public.fna > hgcA_final.fna
cd-hit-est -i hgcA_final.fna -o hgcA_final_0.97.fna -c 0.97 -n 10 -d 0 -M 16000 -T 8

# Merge hgcB sequences with public sequences and remove redundancy

seqtk subseq all_hgcB.fna final_hgcB.faa > final_hgcB.fna
cat final_hgcB.fna hgcB_public.fna > hgcB_final.fna
cd-hit-est -i hgcB_final.fna -o hgcB_final_0.97.fna -c 0.97 -n 10 -d 0 -M 16000 -T 8

echo "Redundancy removal complete. Final files are hgcA_final_0.97.fna and hgcB_final_0.97.fna."
```

# 2.9 Calculating the abundance of hgcAB and crAssphage in each sample

```shell
# Download crAssphage genome

wget https://www.ncbi.nlm.nih.gov/nuccore/NC_024711.1/NC_024711.1.fna

# Index the crAssphage genome using bowtie2

bowtie2-build crAssphage.fna crAssphage

# Index the hgcA and hgcB reference sequences using bowtie2

bowtie2-build hgcA.fna hgcA
bowtie2-build hgcB.fna hgcB

# Loop through all _1.fq files in the current directory

for fq1 in *_1.fq; do
    # Extract the base name (e.g., sample_1.fq -> sample)
    base_name=$(basename "$fq1" _1.fq)
    fq2="${base_name}_2.fq"
    

    # Run bowtie2 alignment for hgcA
    sam_file_hgcA="${base_name}_hgcA.sam"
    bowtie2 -x hgcA -1 "$fq1" -2 "$fq2" -S "$sam_file_hgcA"
    # Generate coverage file for hgcA
    pileup.sh in="$sam_file_hgcA" out="${base_name}_hgcA_coverage.txt"
    
    # Run bowtie2 alignment for hgcB
    sam_file_hgcB="${base_name}_hgcB.sam"
    bowtie2 -x hgcB -1 "$fq1" -2 "$fq2" -S "$sam_file_hgcB"
    # Generate coverage file for hgcB
    pileup.sh in="$sam_file_hgcB" out="${base_name}_hgcB_coverage.txt"
    
    # Run bowtie2 alignment for crAssphage
    sam_file_crAssphage="${base_name}_crAssphage.sam"
    bowtie2 -x crAssphage -1 "$fq1" -2 "$fq2" -S "$sam_file_crAssphage"
    # Generate coverage file for crAssphage
    pileup.sh in="$sam_file_crAssphage" out="${base_name}_crAssphage_coverage.txt"

done

# Run custom Python scripts to build abundance matrices

python3 coverage.py
python3 normalized.py

echo "All processes complete. hgcA, hgcB, and crAssphage abundance matrices have been generated."


# Run custom Python scripts to build abundance matrices

python3 coverage.py
python3 normalized.py

echo "All processes complete. hgcA, hgcB, and crAssphage abundance matrices have been generated."
```

# 2.10 Phylogenetic Tree of hgcA sequences

```shell
muscle -in hgcA_final_0.97.fna -out hgcA_final_0.97_alin.fna

Gblocks  hgcA_final_0.97_alin.fna  -t=d  -b4=5 -b5=h -e=.gb

iqtree2  -s ahgcA_final_0.97_alin.fna.gb  -B 1000 -T  80  --prefix all_gb_iqtree
```

# 2.11 Taxonomic annotation

```shell
graftM create --sequences hgcA_public.fna --taxonomy hgcA_public.taxonomy.txt --output hgcA.genes.gpkg

graftM graft --forward hgcA_final_0.97.fna --graftm_package marker.genes.gpkg/ --output_directory query.graftm
```
