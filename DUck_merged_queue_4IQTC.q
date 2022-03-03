#!/bin/bash
#$ -N DUck_queue          # The name of the job, can be whatever makes sense to you
#$ -S /bin/bash          # Force sh if not Sun Grid Engine default shell
#$ -cwd                 # The batchsystem should use the current directory as working directory.
#$ -q fartorgpu.q            # Queue name where the job should be placed into.
#$ -o DUck.q.o             # Redirect output stream to this file.
#$ -e DUck.q.e             # Redirect error stream to this file.
#$ -l h_rt=15:00:00 # Time limit
#$ -pe gpu 1
#$ -m e


##### FUNCTIONS ####
#Function adapted from 'submit_duck_smd_gpu.csh' of the DUck std pipeline
prepare_duck_and_launch(){
   nustart=$1
   nuend=$2
   temp=$3
   nu=$nustart
   while (($nu <= $nuend)); do
      if [ "$temp" == '300K' ]; then
         dir=DUCK_${nu}
         mkdir $dir
         cd $dir
         if [ "$nu" == "0" ]; then
            pmemd.cuda -O -i ../duck.in -o duck_${nu}.o -p ../lib/system_solv.prmtop -c ../4b_eq.rst -r duck_${nu}.rst -x duck_${nu}.nc -e duck_${nu}.nc -e duck_${nu}.e -ref ../lib/system_solv.prmcrd
            echo "pmemd.cuda -O -i ../duck.in -o duck_${nu}.o -p ../lib/system_solv.prmtop -c ../4b_eq.rst -r duck_${nu}.rst -x duck_${nu}.nc -e duck_${nu}.nc -e duck_${nu}.e -ref ../lib/system_solv.prmcrd" > cmd${nu}
         else
            pmemd.cuda -O -i ../duck.in -o duck_${nu}.o -p ../lib/system_solv.prmtop -c ../md${nu}.rst -r duck_${nu}.rst -x duck_${nu}.nc -e duck_${nu}.e -ref ../lib/system_solv.prmcrd
            echo "pmemd.cuda -O -i ../duck.in -o duck_${nu}.o -p ../lib/system_solv.prmtop -c ../md${nu}.rst -r duck_${nu}.rst -x duck_${nu}.nc -e duck_${nu}.nc -e duck_${nu}.e -e ../lib/system_solv.prmcrd" > cmd${nu}
         fi
         cd ..  
      elif [ "$temp" == '325K' ]; then
         dir=DUCK_325K_${nu}
         mkdir $dir
         cd $dir
	 if [ "$nu" == "0" ]; then
            pmemd.cuda -O -i ../duck_325K.in -o duck_${nu}.o -p ../lib/system_solv.prmtop -c ../4b_eq.rst -r duck_${nu}.rst -x duck_${nu}.nc -e duck_${nu}.nc -e duck_${nu}.e -ref ../lib/system_solv.prmcrd
            echo "pmemd.cuda -O -i ../duck_325K.in -o duck_${nu}.o -p ../lib/system_solv.prmtop -c ../4b_eq.rst -r duck_${nu}.rst -x duck_${nu}.nc -e duck_${nu}.nc -e duck_${nu}.e -ref ../lib/system_solv.prmcrd" > cmd${nu}
         else
            pmemd.cuda -O -i ../duck_325K.in -o duck_${nu}.o -p ../lib/system_solv.prmtop -c ../md${nu}.rst -r duck_${nu}.rst -x duck_${nu}.nc -e duck_${nu}.e -ref ../lib/system_solv.prmcrd
            echo "pmemd.cuda -O -i ../duck_325K.in -o duck_${nu}.o -p ../lib/system_solv.prmtop -c ../md${nu}.rst -r duck_${nu}.rst -x duck_${nu}.nc -e duck_${nu}.nc -e duck_${nu}.e -e ../lib/system_solv.prmcrd" > cmd${nu}
         fi 
         cd ..
      fi
      nu=$((nu+1))
   done

}

# Function to check if WQB is lower than 0.1 using getWqbValues.py
# getWqbValues.py is a script from Maciej modified.
# We use this one instead of the R version, as R is not available in the IQTC

check_WQB(){
   wqb_limit=$1
   lowest_wqb=$(python getWqbValues.py)
   echo $lowest_wqb > wqb.log
   are_we_above_the_limit=$(echo "$lowest_wqb < $wqb_limit" | bc )
   if [ "$are_we_above_the_limit" == "1" ]; then
      echo "Wqb lower than ${wqb_limit}, stoping DUck run"
      cp -r ./* $LIG_TARGET/
      exit 
   fi
}



#### Modules ####
#How to check modules in the queueu
#module_fartor av

#Load modules (we are missing R in here, but python is installed, so we could use Maciej's scripts to check the WQB)
. /etc/profile
module load amber/20_cuda9.0_ompi

#Necessary to use a free GPU
export CUDA_VISIBLE_DEVICES=`cat $TMPDIR/.gpus`

#### Coping the files to node ####
#Things will need to run in $TMPDIR
LIG_TARGET=$PWD
cp -r $LIG_TARGET/* $TMPDIR
cd $TMPDIR

#Remove local output files, as it removes the queue ones when copying back
rm DUck.q.o DUck.q.e

#Where is the calculation being done?
echo "TMPDIR is $TMPDIR"

#### PARAMS ####
replicas=10
min_wqb=4

#### Runing Duck ####
# Minimization&Equilibration
pmemd.cuda -O -i 1_min.in -o min.out -p lib/system_solv.prmtop -c lib/system_solv.prmcrd -r min.rst -ref lib/system_solv.prmcrd
pmemd.cuda -O -i 2_eq.in -o 2_eq.out -p lib/system_solv.prmtop -c min.rst -r  2_eq.rst -x 2_eq.nc -ref lib/system_solv.prmcrd
pmemd.cuda -O -i 3_eq_200.in -o eq3_200.out -p lib/system_solv.prmtop -c 2_eq.rst -r 3_eq_200.rst -x 3_eq_200.nc -ref lib/system_solv.prmcrd
pmemd.cuda -O -i 3_eq_250.in -o eq3_250.out -p lib/system_solv.prmtop -c 3_eq_200.rst -r 3_eq_250.rst -x 3_eq_250.nc -ref lib/system_solv.prmcrd
pmemd.cuda -O -i 3_eq_300.in -o eq3_300.out -p lib/system_solv.prmtop -c 3_eq_250.rst -r 3_eq_300.rst -x 3_eq_300.nc -ref lib/system_solv.prmcrd
pmemd.cuda -O -i 4a_eq.in -o eq4a.out -p lib/system_solv.prmtop -c 3_eq_300.rst -r 4a_eq.rst -x 4a_eq.nc -ref lib/system_solv.prmcrd -e 4a_eq.ene
pmemd.cuda -O -i 4b_eq.in -o eq4b.out -p lib/system_solv.prmtop -c 4a_eq.rst -r 4b_eq.rst -x 4b_eq.nc -ref lib/system_solv.prmcrd -e 4b_eq.ene

#Launch DUck 0
prepare_duck_and_launch 0 0 300K
prepare_duck_and_launch 0 0 325K

#Check if WQB is not lower than the min
check_WQB $min_wqb

#For each replica wanted do: MD, prepare SMD & launch SMD
for ((i=1;i<=$replicas;++i)); do
   if [ "$i" == "1" ]; then
      pmemd.cuda -O -i md.in -o md1.out -p lib/system_solv.prmtop -c 4b_eq.rst -r md1.rst -x md1.nc -ref lib/system_solv.prmcrd
   else
      pmemd.cuda -O -i md.in -o md${i}.out -p lib/system_solv.prmtop -c md$((i-1)).rst -r md${i}.rst -x md${i}.nc -ref lib/system_solv.prmcrd   
   fi

   prepare_duck_and_launch $i $i 300K
   prepare_duck_and_launch $i $i 325K
   check_WQB $min_wqb

done

#### Coping the files back to local ####
cp -r ./* $LIG_TARGET/
cd $LIG_TARGET


exit
