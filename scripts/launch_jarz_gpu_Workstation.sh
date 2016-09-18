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
		dir="JAR_$nu";
		mkdir $dir;
		sed 's/ZZ/'$nu'/g' ../jar_template_gpu.sh > ./${dir}/jar_${nu}.sh;
		if [ ${nu} -eq 0 ]
		then
			sed 's/md'$nu'.rst/4_eq.rst/g' ./${dir}/jar_${nu}.sh > tmp
			mv tmp ./${dir}/jar_${nu}.sh
		fi
		cd $dir; chmod +x jar_${nu}.sh; ./jar_${nu}.sh; cd ..;
	elif [ $ARG3 = "325K" ];
		then
		dir="JAR_325K_$nu";
		mkdir $dir;
		sed 's/ZZ/'$nu'/g' ../jar_template_325K_gpu.sh > ./${dir}/jar_325K_${nu}.sh;
		if [ ${nu} -eq 0 ]
		then
			sed 's/md'$nu'.rst/4_eq.rst/g' ./${dir}/jar_325K_${nu}.sh > tmp
			mv tmp ./${dir}/jar_325K_${nu}.sh
		fi
		cd $dir; chmod +x jar_325K_${nu}.sh; ./jar_325K_${nu}.sh; cd ..;
	fi

	
done


#set dir = JAR_$nu
#		mkdir $dir
#		sed 's/ZZ/'$nu'/g' ../jar_template_gpu.sh > ./${dir}/jar_${nu}.sh
#		if ($nu == 0) then
#			sed 's/md'$nu'.rst/4_eq.rst/g' ./${dir}/jar_${nu}.sh > tmp
#			mv tmp ./${dir}/jar_${nu}.sh
#		endif
#		cd $dir; sh jar_${nu}.sh; cd ..
#	@ nu = $nu + 1
#end
