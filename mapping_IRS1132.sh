### steps to map reads of edited lines

##install the following tools

samtools  #https://github.com/samtools/
bowtie2  #https://github.com/BenLangmead/bowtie2
picard #https://github.com/broadinstitute/picard

##the example uses p1300-Cas9-8N3P12N3P11N3P_seq.fasta as a reference vector
####create an index
bowtie2-build p1300-Cas9-8N3P12N3P11N3P_seq.fasta p1300-Cas9-8N3P12N3P11N3P
##create a list of your reads  (IR), use the nanmes without the fastq extension
##run a loop over a list (IR) of files that contain the paired reads
for x in `cat IR`
do
##Filter with trimgalore  Clipping --clip the firt 15 nucleotides of of each read. This dependes of the fasqc plot. It is optional
trim_galore --paired $x"_1.fastq"  $x"_2.fastq" -q 30 --clip_R1 15 --clip_R2 15
##mapping
echo "mapping" $x
bowtie2 -S $x".sam" -x p1300-Cas9-8N3P12N3P11N3P  -1 *_val_1.fq -2 *_val_2.fq
echo "finished mapping" $x
##sort with picard
picard SortSam "I="$x".sam" "O="$x"_sort.bam" TMP_DIR=tmp SO=coordinate
rm $x".sam"
##filter secundary aligment
samtools view -b -@ 2 -F 0x800 -o $x"_sort_filtered.bam" $x"_sort.bam"
rm $x"_sort.bam"
##index
samtools index $x"_sort_filtered.bam"
picard MarkDuplicates "I="$x"_sort_filtered.bam" "O="$x"_marked.bam" "METRICS_FILE="$x"_Sample_ID_marked.metrics" TMP_DIR=tmp
samtools index $x"_marked.bam"
#### filter only aligned reads
samtools view -F 0x04 -b $x"_marked.bam" > $x"_aligned.bam" -@ 2
samtools index $x"_aligned.bam"
done

### the produced $x"_aligned.bam" is ready to be a loaded togeteher with the p1300-Cas9-8N3P12N3P11N3P_seq.fasta to inspect and
#call for vector integration
