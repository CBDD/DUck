ARG1=${1}
ARG2=${2}
ARG3=${3}
echo $ARG1
echo $ARG2
echo $ARG3

for nu in `seq $ARG1 $ARG2`;
do 
	echo "$nu";
	if [ $ARG3 = "300K" ];
	then
		dir="DUCK_$nu";
		mkdir $dir;
		sed 's/ZZ/'$nu'/g' ../duck_template_gpu.sh > ./${dir}/duck_${nu}.sh;
		if [ ${nu} -eq 0 ]
		then
			sed 's/md'$nu'.rst/4_eq.rst/g' ./${dir}/duck_${nu}.sh > tmp
			mv tmp ./${dir}/duck_${nu}.sh
		fi
		cd $dir; chmod +x duck_${nu}.sh; ./duck_${nu}.sh; cd ..;
	elif [ $ARG3 = "325K" ];
		then
		dir="DUCK_325K_$nu";
		mkdir $dir;
		sed 's/ZZ/'$nu'/g' ../duck_template_gpu_325K.sh > ./${dir}/duck_325K_${nu}.sh;
		if [ ${nu} -eq 0 ]
		then
			sed 's/md'$nu'.rst/4_eq.rst/g' ./${dir}/duck_325K_${nu}.sh > tmp
			mv tmp ./${dir}/duck_325K_${nu}.sh
		fi
		cd $dir; chmod +x duck_325K_${nu}.sh; ./duck_325K_${nu}.sh; cd ..;
	fi

	
done

