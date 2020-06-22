# DESCRIPTION
# Calls color_growth (python) n ($1) times for preset $2,
# randomly varying the seed with each run.

pathToScript=`whereis color_growth.py | gsed 's/color_growth: \(.*\)/\1/g'`

for i in `seq 1 $1`
do
	rndSeedValForParam=`shuf -i 0-4294967296 -n 1`
	python $pathToScript --LOAD_PRESET $2 --RANDOM_SEED $rndSeedValForParam
done