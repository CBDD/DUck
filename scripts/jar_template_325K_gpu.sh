
 pmemd.cuda -O \
                           -i ../jarz_325K.in \
                           -o jar_ZZ.oout \
                           -p ../lib/system_solv.prmtop \
                           -c ../mdZZ.rst \
                           -r jar_ZZ.rst \
                           -x jar_ZZ.nc \
                           -e jar_ZZ.ene \
                           -ref ../lib/system_solv.prmcrd
gzip jar_ZZ.ene
