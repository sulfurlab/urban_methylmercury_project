(请吧地址做如下修改)

https://github.com/sulfurlab/urban_methylmercury_project.

#Workflow

1. Software used in this workflow

[perl](https://www.perl.org/)

[python3](https://www.python.org/)

[axel](https://github.com/axel-download-accelerator/axel)

[sra-tools](https://github.com/ncbi/sra-tools)

[fastp](https://github.com/OpenGene/fastp)

[megahit](https://github.com/voutcn/megahit)

[prodigal](https://github.com/hyattpd/Prodigal)

[hmmsearch](https://github.com/madscientist01/hmmsearch)

[cd-hit](https://sites.google.com/view/cd-hit)

[bowtie2](https://bowtie-bio.sourceforge.net/bowtie2)

[bbtools](https://jgi.doe.gov/data-and-tools/software-tools/bbtools)

[graftM](https://github.com/geronimp/graftM)

[muscle](https://github.com/rcedgar/muscle)

[Aliview](https://ormbunkar.se/aliview/)

[gblocks](https://github.com/atmaivancevic/Gblocks)

[iqtree2](https://github.com/iqtree/iqtree2)


2. Bioinformatics

2.1 Raw data download

##SRA下载，循环提取Samples_download_ftp.txt每行第二列下载路径（需要遍历循环）

```python
#!~/bin/bash
old_name_arr=($(awk -F/ '{print $NF}' test.txt))
new_name_arr=($(awk '{print $1}' test.txt))
link_arr=($(awk {'print $2'} test.txt))
for ((i=0;i<${#link_arr[@]};i++))
  do
    #输出下载命令
	#echo "axel -a -n20 ${link_arr[i]}"
    #echo "mv ${old_name_arr[i]} ${new_name_arr[i]}"
    #直接下载
    axel -a -n20 ${link_arr[i]}
    mv ${old_name_arr[i]} ${new_name_arr[i]}
  done
```

##crAssphage (NC_024711.1)

The crAssphage (NC_024711.1) genomes were downloaded from GenBank 

##public hgcA sequences 下载

A lagre-scale hgcAB database was downloaded from https://figshare.com/authors/Elizabeth_McDaniel/7519667

2.2 FASTQ format from SRA files

```
fasterq-dump --split-3 * -O . -e 30
```

2.2 Read trimming （需要遍历循环）

```python
#!~/bin/bash
old_name_arr=($(awk -F/ '{print $NF}' test.txt))
new_name_arr=($(awk '{print $1}' test.txt))
link_arr=($(awk {'print $2'} test.txt))
for ((i=0;i<${#link_arr[@]};i++))
  do
  fastp --thread 16 --in1 ${new_name_arr[i]}_1.fastq --in2 ${new_name_arr[i]}_2.fastq --out1 ${new_name_arr[i]}_1.fq --out2 ${new_name_arr[i]}_2.fq
  done
```



2.3 Assembly (需要遍历循环)

```
#!~/bin/bash
old_name_arr=($(awk -F/ '{print $NF}' test.txt))
new_name_arr=($(awk '{print $1}' test.txt))
link_arr=($(awk {'print $2'} test.txt))
for ((i=0;i<${#link_arr[@]};i++))
  do
  megahit -1 ${new_name_arr[i]}_1.fq -2 ${new_name_arr[i]}_2.fq --min-contig-len 1000 --k-min 41  -t 110 -o ${new_name_arr[i]}_assembly
  done
```



2.4 ORFs prediction

```python
#根据文件夹重新命名X_assembly的.fa文件

python rename.py

#合并所有X_assembly中.fa文件

cat *_assembly/*.fa > all_assembly.fa

#预测ORF

prodigal -i all_assembly.fa -d all_assembly.fna -a all_assembly.faa
```

2.5 HgcAB identification

hmmsearch hgcA_verified.HMM all_assembly.faa > hgcA.out

hmmsearch hgcB_verified.HMM all_assembly.faa > hgcB.out

#For hgcA, Sequence hits with an E value cutoff score <1e−50 and/or a score of 300 were removed from the results to ensure high confidence in all hits.

#For hgcB, all predicted protein sequences with the HMM profile with threshold cutoff score greater than 70.

#For hgcAB, manually removed hit sequences without the conserved cap-helix domain [G(I/V)NVWCAAGK] and two strictly conserved CX2CX2CX3C ferredoxin-binding motif (CXXCXXXC).

2.6 HgcAB catalogue construction

#hgcAB sequences extraction

```python
python extract.py # 分别输出hgcA.fna, hgcB.fna

cat hgcA.fna hgcA_public.fna > hgcA_final.fna

cat hgcB.fna hgcB_public.fna > hgcB_final.fna

cd-hit-est -i hgcA_final.fna -o hgcA_final_0.97.fna -c 0.97 -n 10 -d 0 -M 16000 - T 8

cd-hit-est -i hgcB_final.fna -o hgcB_final_0.97.fna -c 0.97 -n 10 -d 0 -M 16000 - T 8
```

2.7 HgcAB abundance calculation

```
cat phage_genome hgcA_final_0.97.fna hgcB_final_0.97.fna > hgcAB_phage.fna

bowtie2-build hgcAB_phage.fna hgcAB_phage
```



```
#!~/bin/bash
old_name_arr=($(awk -F/ '{print $NF}' test.txt))
new_name_arr=($(awk '{print $1}' test.txt))
link_arr=($(awk {'print $2'} test.txt))
for ((i=0;i<${#link_arr[@]};i++))
  do
  bowtie2 -new_name_arr[i] hgcAB_phage -1 new_name_arr[i]_1.fq -2 new_name_arr[i]_2.fq -S new_name_arr[i].sam 
  done
```



```
pileup.sh in=X.sam coverage=X-coverage

mkdir coverage

mv *_coverage coverage
```



python coverage.py #获得丰度矩阵



#hgcAB abundance in each metagenome was normalized as gene coverage / per Giga base pairs.

2.8 Phylogenetic Tree



```python
muscle -in hgcA_final_0.97.fna -out hgcA_final_0.97_alin.fna

Gblocks  hgcA_final_0.97_alin.fna  -t=d  -b4=5 -b5=h -e=.gb

iqtree2  -s ahgcA_final_0.97_alin.fna.gb  -B 1000 -T  80  --prefix all_gb_iqtree
```



2.9 HgcA taxonomic classifications



```python
graftM create --sequences hgcA_public.fna --taxonomy hgcA_public.taxonomy.txt --output hgcA.genes.gpkg

graftM graft --forward hgcA_final_0.97.fna --graftm_package marker.genes.gpkg/ --output_directory query.graftm
```

