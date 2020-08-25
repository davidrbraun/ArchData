
## Lombao et al. 2020 - A new approach to measure reduction intensity on cores and tools on cobbles: The Volumetric Reconstruction Method

In this paper on quantifying core reduction intensity, Lombao et al.
(2020) posted a [another large
set](https://zenodo.org/record/3368659#.X0TENcgzZJJ) (N = 128) of 3D
scans of 64 blanks and 64 cores/handaxes (see also Lombao et al.
(2019)). Also included is a spreadsheet of attribute data.

``` r
library(httr)
library(ggplot2)
library(readxl)
library(magrittr)
library(dplyr)
library(knitr)

# Check to see if the file exists locally already, 
# and if not, download it from the Zenodo website.
# This extra step is not necessary, but it is a nice
# trick to know for when datasets are often updated
# on a website, and it saves download time when testing
# code.
if (!file.exists('data/Lombao_2020.rds')) {
  url = "https://zenodo.org/record/3368659/files/VRM%20experiment%20database.xlsx?download=1"
  GET(url, write_disk(tf <- tempfile(fileext = ".xlsx")))
  Lombao_2020 = read_excel(tf, sheet = 1, skip = 0) 
  saveRDS(Lombao_2020, 'data/Lombao_2020.rds') 
} else {
  Lombao_2020 = readRDS('data/Lombao_2020.rds')
}

# Rename the columns to make them more R friendly
Lombao_2020 = Lombao_2020 %>%
  rename(Original_mass = 'Original mass (mm)') %>%
  rename(Original_surface = 'Original surface (mm2)') %>%
  rename(Original_volume = 'Original volume (mm3)') %>%
  rename(Mass_FTh = 'Mean FTh (Flake thickness) (mm)') %>%
  rename(Scar_generations_1 = 'Scar generations...15') %>%
  rename(Thickness = 'Thickness (mm)') %>%
  rename(Mean_PTh_1 = 'Mean PTh (Platform thickness) (mm)...13') %>%
  rename(Scar_generations_2 = 'Scar generations...12') %>%
  rename(Width = 'Width (mm)') %>%
  rename(Mean_PTh_2 = 'Mean PTh (Platform thickness) (mm)...10') %>%
  rename(Scar_generations_3 = 'Scar generations...9') %>%
  rename(Length = 'Length (mm)') %>%
  rename(Surface = 'Surface (mm2)') %>%
  rename(Final_volume = 'Final volume (mm3)') %>%
  rename(Final_mass = 'Final mass (g)') %>%
  rename(Reduction_strategy = 'Reduction strategy') %>%
  rename(Core_label = 'Core Label') %>%
  rename(Blank_label = 'Blank label')
```

A view on the attribute data.

``` r
kable(Lombao_2020)
```

| Blank\_label | Core\_label | Reduction\_strategy             | Final\_mass | Final\_volume |   Surface |   Density | Length | Scar\_generations\_3 | Mean\_PTh\_2 |  Width | Scar\_generations\_2 | Mean\_PTh\_1 | Thickness | Scar\_generations\_1 | Mass\_FTh | Original\_volume | Original\_surface | Original\_mass |
| :----------- | :---------- | :------------------------------ | ----------: | ------------: | --------: | --------: | -----: | -------------------: | -----------: | -----: | -------------------: | -----------: | --------: | -------------------: | --------: | ---------------: | ----------------: | -------------: |
| GC12         | AE97        | Bifacial Multipolar Centripetal |       626.8 |     237738.52 | 22494.274 | 0.0026365 | 110.41 |                    2 |        11.05 |  90.98 |                    3 |        11.05 |     61.40 |                    0 |        13 |         430945.9 |          30376.39 |      1136.1932 |
| MM2          | AJ15        | Bifacial Multipolar Centripetal |       374.9 |     142783.12 | 17777.431 | 0.0026257 |  90.36 |                    4 |        11.05 |  83.91 |                    2 |        11.05 |     56.80 |                    0 |        13 |         292962.5 |          23930.21 |       769.2200 |
| MM12         | AW98        | Bifacial Multipolar Centripetal |       685.1 |     257057.32 | 25761.263 | 0.0026652 | 116.94 |                    6 |        11.05 |  93.59 |                    4 |        11.05 |     48.66 |                    0 |        13 |         632897.6 |          44485.20 |      1686.7762 |
| MM8          | BN19        | Bifacial Multipolar Centripetal |       144.9 |      55018.68 |  9160.604 | 0.0026337 |  74.84 |                    2 |        11.05 |  62.36 |                    2 |        11.05 |     32.15 |                    1 |        13 |         144915.1 |          15946.00 |       381.6557 |
| GC8          | BO19        | Bifacial Multipolar Centripetal |       899.7 |     341708.35 | 33650.509 | 0.0026329 | 139.18 |                    4 |        11.05 | 114.81 |                    4 |        11.05 |     46.74 |                    1 |        13 |         766870.9 |          47377.97 |      2019.1305 |
| MM16         | DP46        | Bifacial Multipolar Centripetal |       256.7 |      97253.57 | 13186.224 | 0.0026395 |  75.89 |                    5 |        11.05 |  72.51 |                    4 |        11.05 |     46.33 |                    1 |        13 |         396348.8 |          35175.02 |      1046.1588 |
| GC16         | DT43        | Bifacial Multipolar Centripetal |       378.6 |     143198.47 | 18152.167 | 0.0026439 |  91.99 |                    4 |        11.05 |  90.59 |                    5 |        11.05 |     45.94 |                    1 |        13 |         534578.3 |          37445.15 |      1413.3625 |
| JR14         | IG72        | Bifacial Multipolar Centripetal |       385.8 |     142272.73 | 20475.997 | 0.0027117 | 107.31 |                    3 |        11.05 |  99.41 |                    6 |        11.05 |     39.63 |                    1 |        13 |         424981.4 |          32314.26 |      1152.4192 |
| AO6          | IH09        | Bifacial Multipolar Centripetal |       301.5 |     114207.18 | 16292.268 | 0.0026399 |  97.32 |                    6 |        11.05 |  87.83 |                    5 |        11.05 |     39.98 |                    1 |        13 |         523356.0 |          37672.27 |      1381.6280 |
| JR6          | IY04        | Bifacial Multipolar Centripetal |      1775.2 |     685545.67 | 48290.054 | 0.0025895 | 158.53 |                    1 |        11.05 | 151.05 |                    2 |        11.05 |     73.51 |                    0 |        13 |         912338.3 |          57577.86 |      2362.4727 |
| GC1          | LP16        | Bifacial Multipolar Centripetal |       540.8 |     205325.06 | 21368.287 | 0.0026339 | 114.47 |                    2 |        11.05 |  88.76 |                    3 |        11.05 |     44.17 |                    0 |        13 |         306845.7 |          25881.48 |       808.1924 |
| AO8          | NB91        | Bifacial Multipolar Centripetal |       646.0 |     236382.86 | 24776.835 | 0.0027329 | 109.23 |                    4 |        11.05 |  91.36 |                    4 |        11.05 |     59.03 |                    0 |        13 |         532015.5 |          38194.47 |      1453.9211 |
| JR9          | OB91        | Bifacial Multipolar Centripetal |       499.7 |     191789.40 | 25094.227 | 0.0026055 | 121.00 |                    6 |        11.05 | 104.92 |                    4 |        11.05 |     35.84 |                    0 |        13 |         783444.8 |          64273.99 |      2041.2357 |
| AO7          | RE43        | Bifacial Multipolar Centripetal |       662.4 |     235600.35 | 23015.073 | 0.0028115 | 110.61 |                    4 |        11.05 |  92.29 |                    4 |        11.05 |     52.69 |                    0 |        13 |         595269.3 |          42893.05 |      1673.6240 |
| AO15         | RH23        | Bifacial Multipolar Centripetal |       737.9 |     283236.27 | 26297.787 | 0.0026052 | 124.09 |                    4 |        11.05 |  95.15 |                    2 |        11.05 |     60.59 |                    0 |        13 |         598076.3 |          39611.07 |      1558.1356 |
| MM11         | YT43        | Bifacial Multipolar Centripetal |       728.8 |     276891.96 | 25823.651 | 0.0026321 | 107.13 |                    3 |        11.05 | 105.59 |                    2 |        11.05 |     60.33 |                    0 |        13 |         481699.3 |          34975.20 |      1267.8680 |
| GC10         | CR84        | Handaxe                         |      1088.8 |     413846.09 | 39343.946 | 0.0026309 | 172.47 |                    4 |        11.05 | 128.22 |                    4 |        11.05 |     54.05 |                    0 |        13 |        1085826.3 |          74922.39 |      2856.7326 |
| JR5          | EA79        | Handaxe                         |      1396.6 |     547029.68 | 43236.099 | 0.0025531 | 177.31 |                    5 |        11.05 | 109.41 |                    5 |        11.05 |     78.72 |                    0 |        13 |        1733023.2 |          85479.63 |      4424.5136 |
| AO5          | EC76        | Handaxe                         |      1061.0 |     408166.21 | 40648.510 | 0.0025994 | 187.70 |                    5 |        11.05 | 127.23 |                    4 |        11.05 |     38.30 |                    0 |        13 |         751714.9 |          62124.60 |      1954.0312 |
| MM7          | ER34        | Handaxe                         |      1493.6 |     571279.57 | 54507.027 | 0.0026145 | 244.75 |                    4 |        11.05 | 121.26 |                    5 |        11.05 |     48.09 |                    0 |        13 |        1093545.4 |          80484.38 |      2859.0545 |
| GC3          | GI27        | Handaxe                         |       811.5 |     308763.22 | 32884.694 | 0.0026282 | 154.08 |                    5 |        11.05 |  99.40 |                    5 |        11.05 |     53.24 |                    0 |        13 |         707802.8 |          52635.42 |      1860.2667 |
| MM3          | GV21        | Handaxe                         |       253.7 |      96022.83 | 14288.578 | 0.0026421 |  94.81 |                    5 |        11.05 |  63.86 |                    6 |        11.05 |     36.40 |                    2 |        13 |         487259.2 |          44943.71 |      1287.3780 |
| AO2          | JA51        | Handaxe                         |       191.5 |      72666.42 | 13036.708 | 0.0026353 | 101.44 |                    4 |        11.05 |  49.43 |                    5 |        11.05 |     38.38 |                    2 |        13 |         636647.2 |          41726.88 |      1677.7755 |
| MM1          | LT13        | Handaxe                         |      1348.0 |     520903.19 | 45440.179 | 0.0025878 | 205.06 |                    5 |        11.05 | 126.30 |                    6 |        11.05 |     46.47 |                    0 |        13 |        1057725.0 |          75827.41 |      2737.1943 |
| GC4          | NG25        | Handaxe                         |      1177.8 |     446037.07 | 37862.430 | 0.0026406 | 171.61 |                    2 |        11.05 | 102.06 |                    2 |        11.05 |     57.01 |                    0 |        13 |         606187.8 |          46323.06 |      1600.6921 |
| GC9          | PN39        | Handaxe                         |      1040.9 |     393581.22 | 35432.099 | 0.0026447 | 166.97 |                    6 |        11.05 | 113.03 |                    6 |        11.05 |     62.07 |                    1 |        13 |        1231999.9 |          64340.97 |      3258.2568 |
| JR1          | TD34        | Handaxe                         |       948.5 |     363655.69 | 36064.667 | 0.0026082 | 153.80 |                    4 |        11.05 | 104.41 |                    4 |        11.05 |     59.43 |                    1 |        13 |         885259.7 |          54842.85 |      2308.9666 |
| JR11         | TH39        | Handaxe                         |      1320.4 |     506148.35 | 43095.997 | 0.0026087 | 189.83 |                    4 |        11.05 | 127.31 |                    4 |        11.05 |     65.05 |                    0 |        13 |        1217181.0 |          80081.81 |      3175.2861 |
| AO11         | TY34        | Handaxe                         |      1374.3 |     530152.09 | 45908.079 | 0.0025923 | 187.27 |                    6 |        11.05 | 132.97 |                    5 |        11.05 |     53.62 |                    0 |        13 |        1005601.0 |          69757.61 |      2606.7944 |
| MM14         | UI67        | Handaxe                         |       769.0 |     303168.25 | 27184.020 | 0.0025365 | 111.92 |                    3 |        11.05 |  90.67 |                    3 |        11.05 |     55.99 |                    0 |        13 |         767876.1 |          52810.17 |      1947.7526 |
| AO3          | VG12        | Handaxe                         |       838.2 |     307543.74 | 32906.578 | 0.0027255 | 170.63 |                    6 |        11.05 | 110.67 |                    7 |        11.05 |     43.97 |                    0 |        13 |         990843.5 |          74594.98 |      2700.5103 |
| JR3          | VU16        | Handaxe                         |      1631.2 |     628731.77 | 47252.865 | 0.0025944 | 191.05 |                    2 |        11.05 | 130.11 |                    5 |        11.05 |     63.67 |                    0 |        13 |        1222193.5 |          71665.07 |      3170.8945 |
| MM10         | CV89        | Multifacial Multipolar          |       384.3 |     145718.18 | 16051.410 | 0.0026373 |  76.97 |                    2 |        11.05 |  62.60 |                    4 |        11.05 |     62.60 |                    0 |        13 |         436324.0 |          32898.41 |      1150.7095 |
| GC5          | CW68        | Multifacial Multipolar          |      1858.2 |     711013.48 | 46428.266 | 0.0026135 | 144.77 |                    2 |        11.05 | 139.04 |                    2 |        11.05 |     64.62 |                    0 |        13 |        1214616.8 |          68164.19 |      3174.3434 |
| GC7          | EV39        | Multifacial Multipolar          |       946.3 |     361543.12 | 29375.318 | 0.0026174 | 100.30 |                    4 |        11.05 |  90.43 |                    3 |        11.05 |     83.96 |                    0 |        13 |        1276591.5 |          67368.77 |      3341.3403 |
| MM13         | FG45        | Multifacial Multipolar          |       514.9 |     192664.84 | 19816.594 | 0.0026725 |  92.33 |                    2 |        11.05 |  83.05 |                    2 |        11.05 |     57.43 |                    1 |        13 |         484063.5 |          34382.35 |      1293.6677 |
| GC13         | FO41        | Multifacial Multipolar          |       398.3 |     151526.62 | 17617.596 | 0.0026286 |  98.81 |                    2 |        11.05 |  73.33 |                    5 |        11.05 |     48.88 |                    1 |        13 |         563967.2 |          37112.30 |      1482.4336 |
| AO13         | GF54        | Multifacial Multipolar          |       315.0 |     119518.59 | 15185.944 | 0.0026356 |  88.48 |                    5 |        11.05 |  60.39 |                    4 |        11.05 |     56.90 |                    4 |        13 |         616401.8 |          40835.88 |      1624.5720 |
| MM6          | HI90        | Multifacial Multipolar          |       963.0 |     365404.04 | 27779.940 | 0.0026354 | 114.26 |                    1 |        11.05 |  99.15 |                    3 |        11.05 |     66.61 |                    0 |        13 |         471892.3 |          31594.68 |      1243.6433 |
| GC6          | HT93        | Multifacial Multipolar          |       831.1 |     314775.99 | 27494.004 | 0.0026403 | 118.42 |                    5 |        11.05 |  99.95 |                    3 |        11.05 |     71.24 |                    0 |        13 |         540985.2 |          35777.59 |      1428.3579 |
| AO14         | IU76        | Multifacial Multipolar          |       175.5 |      66514.40 | 10227.379 | 0.0026385 |  62.80 |                    6 |        11.05 |  57.24 |                    4 |        11.05 |     46.50 |                    3 |        13 |         790819.1 |          48836.21 |      2086.5973 |
| JR2          | JH53        | Multifacial Multipolar          |       875.2 |     336574.92 | 27733.493 | 0.0026003 | 122.04 |                    2 |        11.05 |  97.66 |                    2 |        11.05 |     55.46 |                    0 |        13 |         796612.1 |          55691.78 |      2071.4406 |
| MM4          | NO21        | Multifacial Multipolar          |       662.0 |     245235.82 | 22866.441 | 0.0026994 |  90.08 |                    2 |        11.05 |  85.41 |                    5 |        11.05 |     73.27 |                    2 |        13 |         769616.1 |          50355.36 |      2077.5343 |
| JR8          | NP93        | Multifacial Multipolar          |      1531.3 |     591762.30 | 40912.259 | 0.0025877 | 147.33 |                    3 |        11.05 | 116.24 |                    1 |        11.05 |     72.22 |                    0 |        13 |         892283.2 |          54240.55 |      2308.9562 |
| AO4          | ON12        | Multifacial Multipolar          |       500.1 |     189117.07 | 19902.040 | 0.0026444 |  97.15 |                    5 |        11.05 |  77.44 |                    0 |        11.05 |     70.34 |                    5 |        13 |        1158303.9 |          73370.72 |      3063.0115 |
| JR15         | RA21        | Multifacial Multipolar          |       822.4 |     313530.80 | 29161.307 | 0.0026230 | 123.35 |                    3 |        11.05 | 102.32 |                    4 |        11.05 |     62.08 |                    0 |        13 |         556284.5 |          43284.76 |      1459.1497 |
| JR7          | RC48        | Multifacial Multipolar          |       830.4 |     315228.03 | 28942.482 | 0.0026343 | 131.35 |                    2 |        11.05 | 101.10 |                    3 |        11.05 |     50.49 |                    1 |        13 |         775378.0 |          50362.94 |      2042.5656 |
| AO12         | WA89        | Multifacial Multipolar          |       203.5 |      75220.70 | 11897.633 | 0.0027054 |  81.09 |                    4 |        11.05 |  76.38 |                    4 |        11.05 |     50.91 |                    2 |        13 |         717745.5 |          48268.29 |      1941.7689 |
| GC2          | AR13        | Unifacial Unipolar              |       882.1 |     334378.72 | 28273.469 | 0.0026380 | 119.89 |                    0 |        11.05 | 110.86 |                    2 |        11.05 |     56.71 |                    0 |        13 |         544005.5 |          36875.86 |      1435.1012 |
| MM5          | CE67        | Unifacial Unipolar              |       664.5 |     251929.04 | 23732.801 | 0.0026376 | 104.47 |                    1 |        11.05 |  77.72 |                    2 |        11.05 |     73.41 |                    2 |        13 |         702828.6 |          44472.01 |      1853.8142 |
| JR13         | GN52        | Unifacial Unipolar              |       442.1 |     168409.01 | 19872.580 | 0.0026252 | 103.47 |                    0 |        11.05 |  94.40 |                    3 |        11.05 |     33.72 |                    0 |        13 |         253407.9 |          26171.33 |       665.2353 |
| GC15         | HJ35        | Unifacial Unipolar              |      1016.5 |     385905.04 | 31138.418 | 0.0026341 | 117.15 |                    2 |        11.05 | 116.79 |                    2 |        11.05 |     61.77 |                    0 |        13 |         608187.4 |          39890.57 |      1602.0067 |
| MM15         | HR32        | Unifacial Unipolar              |       548.9 |     208944.64 | 22430.126 | 0.0026270 | 104.28 |                    0 |        11.05 |  93.92 |                    3 |        11.05 |     51.14 |                    1 |        13 |         592137.6 |          41666.94 |      1555.5524 |
| JR4          | OF14        | Unifacial Unipolar              |      1471.2 |     562225.84 | 43850.302 | 0.0026167 | 172.06 |                    2 |        11.05 | 135.04 |                    1 |        11.05 |     72.06 |                    0 |        13 |        1034475.1 |          68524.24 |      2706.9546 |
| AO9          | OP93        | Unifacial Unipolar              |       696.9 |     263797.56 | 24215.397 | 0.0026418 | 101.12 |                    0 |        11.05 |  87.87 |                    2 |        11.05 |     74.28 |                    2 |        13 |         562189.5 |          37286.36 |      1485.1913 |
| AO16         | PD64        | Unifacial Unipolar              |      1168.3 |     442541.51 | 33477.435 | 0.0026400 | 131.99 |                    0 |        11.05 |  93.97 |                    3 |        11.05 |     78.89 |                    0 |        13 |         830880.1 |          47074.20 |      2193.5055 |
| JR16         | PL61        | Unifacial Unipolar              |       947.5 |     358790.05 | 27738.385 | 0.0026408 | 121.34 |                    0 |        11.05 |  84.11 |                    3 |        11.05 |     69.56 |                    0 |        13 |         587856.6 |          37103.40 |      1552.4236 |
| MM9          | PO39        | Unifacial Unipolar              |       464.2 |     177366.73 | 19576.663 | 0.0026172 |  99.64 |                    4 |        11.05 |  80.92 |                    3 |        11.05 |     53.40 |                    1 |        13 |         757945.0 |          45556.12 |      1983.6757 |
| AO1          | TL31        | Unifacial Unipolar              |       481.6 |     182770.16 | 20850.533 | 0.0026350 | 113.09 |                    2 |        11.05 |  88.76 |                    4 |        11.05 |     44.32 |                    1 |        13 |         596261.4 |          39323.68 |      1571.1508 |
| GC14         | UV61        | Unifacial Unipolar              |      1229.9 |     465895.14 | 35080.706 | 0.0026399 | 138.09 |                    0 |        11.05 | 105.88 |                    3 |        11.05 |     65.92 |                    0 |        13 |         762198.2 |          49490.77 |      2012.1000 |
| AO10         | VC98        | Unifacial Unipolar              |      1157.8 |     439689.72 | 33948.247 | 0.0026332 | 128.00 |                    0 |        11.05 |  91.00 |                    0 |        11.05 |     83.00 |                    5 |        13 |        1205423.8 |          61131.54 |      3174.1466 |
| JR10         | VE93        | Unifacial Unipolar              |       605.4 |     229654.77 | 20767.899 | 0.0026361 |  93.78 |                    2 |        11.05 |  91.23 |                    0 |        11.05 |     51.48 |                    0 |        13 |         317520.5 |          26043.05 |       837.0256 |
| JR12         | WC86        | Unifacial Unipolar              |      1948.1 |     738178.89 | 48615.950 | 0.0026391 | 156.40 |                    3 |        11.05 | 119.25 |                    2 |        11.05 |     81.49 |                    0 |        13 |        1027756.4 |          57019.61 |      2712.3129 |
| GC11         | YI49        | Unifacial Unipolar              |       973.9 |     368859.78 | 28888.426 | 0.0026403 | 115.85 |                    0 |        11.05 | 112.21 |                    2 |        11.05 |     64.65 |                    0 |        13 |         468876.8 |          32126.44 |      1237.9749 |

<div id="refs" class="references hanging-indent">

<div id="ref-lombao_effects_2019">

Lombao, Diego, Arturo Cueva-Temprana, José Ramón Rabuñal, Juan I
Morales, and Marina Mosquera. 2019. “The Effects of Blank Size and
Knapping Strategy on the Estimation of Core’s Reduction Intensity.”
*Archaeological and Anthropological Sciences* 11 (10): 5445–61.

</div>

<div id="ref-lombao_new_2020">

Lombao, Diego, José Rabuñal, Arturo Cueva-Temprana, Marina Mosquera, and
Juan Morales. 2020. “A New Approach to Measure Reduction Intensity on
Cores and Tools on Cobbles: The Volumetric Reconstruction Method.”

</div>

</div>
