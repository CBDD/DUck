#!/bin/tcsh -f

###
set nustart=$1
set nuend=$2
set temp=$3
###

set nu=$nustart
while ($nu <= $nuend)
	if ($temp == "300K") then
		set dir = DUCK_$nu
		mkdir $dir
		sed 's/ZZ/'$nu'/g' duck_template_gpu.q > ./${dir}/duck_${nu}.q
		if ($nu == 0) then
			sed 's/md'$nu'.rst/4b_eq.rst/g' ./${dir}/duck_${nu}.q > tmp
			mv tmp ./${dir}/duck_${nu}.q
		endif
		cd $dir; qsub duck_${nu}.q; cd ..
# 325 K
	else if ($temp == "325K" ) then
		set dir = DUCK_325K_$nu
		mkdir $dir
		sed 's/ZZ/'$nu'/g' duck_template_gpu_325K.q > ./${dir}/duck_325K_${nu}.q
		if ($nu == 0) then
			sed 's/md'$nu'.rst/4b_eq.rst/g' ./${dir}/duck_325K_${nu}.q > tmp
			mv tmp ./${dir}/duck_325K_${nu}.q
		endif
		cd $dir; qsub duck_325K_${nu}.q; cd ..
	endif
	@ nu = $nu + 1
end
