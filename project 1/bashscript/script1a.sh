#$ -N splitfi
#$ -cwd
#$ -l h_rt=00:20:00,pcpus=8

awk 'BEGIN {RS=">"; OUT="fastafiles2/" sprintf("%.4d", i) ".fa"} FNR > 1 {if (m<150) {printf ">"$0 >> OUT; m=m+1;} else{close(OUT); m=0; OUT="fastafiles2/" sprintf("%.4d", ++i) ".fa"; printf ">"$0 >> OUT}}' human.rna.fna.mRNA

