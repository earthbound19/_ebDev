# DESCRIPTION
# Animate RND block noise as in makeBWGridRandomNoiseAnim.sh, and use it as alpha in a composite animation with a foreground image animated over a background image, where the RND block noise is the animated transparency (or alpha) mask. THIS IS A STUB, in development.

# CODE
echo "At this writing, this script is a stub. Final script intent will be to animate RND block noise as in makeBWGridRandomNoiseAnim.sh, and use it as alpha in a composite animation with a foreground image animated over a background image, where the RND block noise is the animated transparency (or alpha) mask."

# pbm to nn upscaled png:
# img2imgNN.sh 16x9__2021_11_13__23_28_11__837658100.pbm png 1920

# composite via compose mask; re:
# https://legacy.imagemagick.org/Usage/compose/#mask
# ex. command:
# magick composite tile_water.jpg   tile_aqua.jpg  moon_mask.gif   mask_over.jpg
# -- but that isn't working with imagemagick for me. But it does work with graphicsmagick! :

# gm composite fg.png bg.png mask.png fg_cutout_bb.png