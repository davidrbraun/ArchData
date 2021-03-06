
## Herzlinger and Goren-Inbar 2019 - Beyond a Cutting Edge: a Morpho-technological Analysis of Acheulian Handaxes and Cleavers from Gesher Benot Ya‘aqov, Israel

Herzlinger and Goren-Inbar (2020) published on the handaxes and cleavers
from Gesher Benot Ya‘aqov, Israel, in the *Journal of Paleolithic
Archaeology* and placed all of the data on [OSF](https://osf.io/u3n9k/).
The data include 3D models of all of the artifacts and a spreadsheet of
attribute values for each including the number of dorsal and ventral
scars and the type of blank. For the 3D models, the data format is
something called .3dl which is compatible with the software program
AGMT3-D, which was published by in open access by [Gadi Herzlinger and
Leore Grosman on PLOS
One](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0207890)
and is freely available for download.

We wondered if the data could be used outside of this program by
converting the format to something more standard like PLY. In fact, the
files are in a standard Matlab format that R can be used to easily
convert them. So the code that follows loads each artifact, coverts it
to a PLY, saves the file, and then makes a 2D snapshot of each (after
rotating them).

``` r
library(rgl)
library(Rvcg)
library(Morpho)
library(R.matlab)
library(ggplot2)
library(png)
library(grid)
library(gridExtra)

# To run this code, first down load the zip file containing the 3D models from this page
# https://osf.io/u3n9k/
# Next, unzip the files to a folder called data.
# This code will then loop through that folder and convert each file to a ply type.

for (filename in list.files('data', pattern = '*.3dl')) {
  new_filename = paste('data/', strsplit(filename,'\\.')[[1]][1], '.ply', sep = '')
  if (!file.exists(new_filename)) {
    
    # Read the MatLab format file
    biface_matlab_format = readMat(paste('data', filename, sep = '//'))
    
    # Convert to a more standardized formet
    biface = tmesh3d(vertices = t(biface_matlab_format$v),
                     indices = t(biface_matlab_format$f),
                     homogeneous = FALSE)
      
    # Save the result at a PLY
    vcgPlyWrite(biface, new_filename)
  }
}
```

Make a view of each and save as a PNG file.

``` r
# use rgl to render each handaxe, rotate it appropriately.  Note this routine does not
# generate proper png files if the documented is knitted.  Instead, just run this code
# block.

open3d()
```

    ## wgl 
    ##   1

``` r
for (filename in list.files('data', pattern = '*.ply')) {
  new_filename = paste('data/', strsplit(filename,'\\.')[[1]][1], '.png', sep = '')
  if (!file.exists(new_filename)) {
    biface = vcgPlyRead(paste('data', filename, sep = '//'))

    # Do PCA on the vertices to achieve a more standard orientation
      v = princomp(t(biface$vb[1:3,]), scores = TRUE, cor = FALSE)$scores
      
      # Put the PCA scores back in the mesh object along with the texture
    biface$vb[,] = t(cbind(v, biface$vb[4,]))                           
    
      # Rotate into standard view
    biface = rotaxis3d(biface, c(0, 0, 0), c(0, 1, 0), -pi / 2)
    biface = rotaxis3d(biface, c(0, 0, 0), c(0, 0, 1), -pi / 2)

    # Check to see if it looks to be upside down and flip if so
    if (sd(biface$vb[1,biface$vb[3,]<0]) < sd(biface$vb[1,biface$vb[3,]>0])) {
      biface = rotaxis3d(biface, c(0,0,0), c(1,0,0), pi) }      

    clear3d()
    
    shade3d(biface, color = '#FFD54F')
    
    snapshot3d(new_filename, fmt = 'png')
  }
}
rgl.close()
```

Now display them.

``` r
par(mfrow=c(10,10))

for (filename in list.files('data', pattern = '*.png')) {
  img <- readPNG(paste('data', filename, sep = '/')) 
  g <- rasterGrob(img, interpolate=TRUE) 
  p = ggplot(data.frame(x = 1:25, y = 1:25), aes(x, y))
  p = p + annotation_custom(g, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf)
  p = p + xlab('') + ylab('')
  p = p + ggtitle(filename)
  p = p + theme_minimal()
  print(p)
}
```

![](readme_files/figure-gfm/plot_handaxes-1.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-2.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-3.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-4.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-5.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-6.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-7.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-8.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-9.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-10.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-11.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-12.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-13.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-14.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-15.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-16.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-17.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-18.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-19.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-20.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-21.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-22.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-23.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-24.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-25.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-26.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-27.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-28.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-29.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-30.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-31.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-32.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-33.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-34.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-35.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-36.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-37.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-38.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-39.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-40.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-41.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-42.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-43.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-44.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-45.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-46.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-47.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-48.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-49.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-50.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-51.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-52.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-53.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-54.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-55.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-56.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-57.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-58.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-59.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-60.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-61.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-62.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-63.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-64.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-65.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-66.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-67.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-68.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-69.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-70.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-71.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-72.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-73.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-74.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-75.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-76.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-77.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-78.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-79.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-80.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-81.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-82.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-83.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-84.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-85.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-86.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-87.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-88.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-89.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-90.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-91.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-92.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-93.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-94.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-95.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-96.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-97.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-98.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-99.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-100.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-101.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-102.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-103.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-104.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-105.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-106.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-107.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-108.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-109.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-110.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-111.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-112.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-113.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-114.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-115.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-116.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-117.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-118.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-119.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-120.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-121.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-122.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-123.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-124.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-125.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-126.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-127.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-128.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-129.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-130.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-131.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-132.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-133.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-134.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-135.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-136.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-137.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-138.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-139.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-140.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-141.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-142.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-143.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-144.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-145.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-146.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-147.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-148.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-149.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-150.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-151.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-152.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-153.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-154.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-155.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-156.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-157.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-158.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-159.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-160.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-161.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-162.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-163.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-164.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-165.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-166.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-167.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-168.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-169.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-170.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-171.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-172.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-173.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-174.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-175.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-176.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-177.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-178.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-179.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-180.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-181.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-182.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-183.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-184.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-185.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-186.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-187.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-188.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-189.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-190.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-191.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-192.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-193.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-194.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-195.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-196.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-197.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-198.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-199.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-200.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-201.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-202.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-203.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-204.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-205.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-206.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-207.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-208.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-209.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-210.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-211.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-212.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-213.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-214.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-215.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-216.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-217.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-218.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-219.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-220.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-221.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-222.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-223.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-224.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-225.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-226.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-227.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-228.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-229.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-230.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-231.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-232.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-233.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-234.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-235.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-236.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-237.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-238.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-239.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-240.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-241.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-242.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-243.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-244.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-245.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-246.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-247.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-248.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-249.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-250.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-251.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-252.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-253.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-254.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-255.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-256.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-257.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-258.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-259.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-260.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-261.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-262.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-263.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-264.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-265.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-266.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-267.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-268.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-269.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-270.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-271.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-272.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-273.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-274.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-275.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-276.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-277.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-278.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-279.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-280.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-281.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-282.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-283.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-284.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-285.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-286.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-287.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-288.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-289.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-290.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-291.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-292.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-293.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-294.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-295.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-296.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-297.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-298.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-299.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-300.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-301.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-302.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-303.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-304.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-305.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-306.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-307.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-308.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-309.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-310.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-311.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-312.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-313.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-314.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-315.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-316.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-317.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-318.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-319.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-320.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-321.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-322.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-323.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-324.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-325.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-326.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-327.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-328.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-329.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-330.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-331.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-332.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-333.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-334.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-335.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-336.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-337.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-338.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-339.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-340.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-341.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-342.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-343.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-344.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-345.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-346.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-347.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-348.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-349.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-350.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-351.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-352.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-353.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-354.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-355.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-356.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-357.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-358.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-359.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-360.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-361.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-362.png)<!-- -->![](readme_files/figure-gfm/plot_handaxes-363.png)<!-- -->

<div id="refs" class="references hanging-indent">

<div id="ref-herzlinger_beyond_2020">

Herzlinger, Gadi, and Naama Goren-Inbar. 2020. “Beyond a Cutting Edge: A
Morpho-Technological Analysis of Acheulian Handaxes and Cleavers from
Gesher Benot Ya‘aqov, Israel.” *Journal of Paleolithic Archaeology* 3
(1): 33–58. <https://doi.org/10.1007/s41982-019-00033-5>.

</div>

</div>
