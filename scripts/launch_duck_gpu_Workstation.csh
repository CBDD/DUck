#!/bin/tcsh -f

###
set nustart=$1
set nuend=$2
set temp=$3
###
echo $LD_LIBRARY_PATH
set nu=$nustart
while ($nu <= $nuend)
	if ($temp == "300K") then
		set dir = DUCK_$nu
		mkdir $dir
		sed 's/ZZ/'$nu'/g' ../duck_template_gpu.sh > ./${dir}/duck_${nu}.sh
		if ($nu == 0) then
			sed 's/md'$nu'.rst/4_eq.rst/g' ./${dir}/duck_${nu}.sh > tmp
			mv tmp ./${dir}/duck_${nu}.sh
		endif
		cd $dir; chmod +x duck_${nu}.sh; ./duck_${nu}.sh; cd ..
	@ nu = $nu + 1
	endif
end
