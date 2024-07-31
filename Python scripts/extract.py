from Bio import SeqIO
result= open('572.fa', 'w')
a={}
f=open('id.txt', 'r')
for line in f:
    a[line.strip()]=1
f.close()
for seq_record in SeqIO.parse('hgcA.fa', 'fasta'):
    if str(seq_record.id) in a:
        result.write('>'+str(seq_record.description)+'\n')
        result.write(str(seq_record.seq)+'\n')
result.close()
print('ok')
