# DESCRIPTION
# Produces varieties of a color growth. Calls color_growth.py N times (per $1) for preset $2, randomly varying the seed with each run, resulting in a so many renders that all have the same setting but a different seed.

# USAGE
# From a directory with a .cgp preset for color_growth.py, run with these parameters:
# - $1 how many times to render the preset, with a new randomly chosen `--RANDOM_SEED` value each time.
# - $2 the file name of the preset from which to make so many renders.
# Example that would produce 10 renders of the given preset:
#    color_growth_1cgp_many_variants.sh 10 colorGrowth-Py-scarlet-orange.cgp


# CODE
pathToScript=`whereis color_growth.py | sed 's/color_growth: \(.*\)/\1/g'`

for i in `seq 1 $1`
do
	rndSeedValForParam=`shuf -i 0-4294967296 -n 1`
	python $pathToScript --LOAD_PRESET $2 --RANDOM_SEED $rndSeedValForParam
done