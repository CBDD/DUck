
 pmemd.cuda -O \
                           -i ../duck_325K.in \
                           -o duck_ZZ.out \
                           -p ../lib/system_solv.prmtop \
                           -c ../mdZZ.rst \
                           -r duck_ZZ.rst \
                           -x duck_ZZ.nc \
                           -e duck_ZZ.ene \
                           -ref ../lib/system_solv.prmcrd
gzip duck_ZZ.ene
