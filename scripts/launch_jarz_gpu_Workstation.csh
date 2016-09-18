#!/bin/tcsh -f

###
set nustart=$1
set nuend=$2
set temp=$3
###
echo $LD_LIBRARY_PATH
set nu=$nustart
sed 's/temp0=300.0/temp0=325.0/' jarz.in > jarz_325K.in
while ($nu <= $nuend)
	if ($temp == "300K") then
		set dir = JAR_$nu
		mkdir $dir
		sed 's/ZZ/'$nu'/g' ../jar_template_gpu.sh > ./${dir}/jar_${nu}.sh
		if ($nu == 0) then
			sed 's/md'$nu'.rst/4_eq.rst/g' ./${dir}/jar_${nu}.sh > tmp
			mv tmp ./${dir}/jar_${nu}.sh
		endif
		cd $dir; chmod +x jar_${nu}.sh; ./jar_${nu}.sh; cd ..
	@ nu = $nu + 1
	endif
end
