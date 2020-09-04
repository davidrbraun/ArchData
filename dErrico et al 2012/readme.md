
## d’Errico et al. 2011 - PACEA geo-referenced radiocarbon database

Here we use the [c14bazAAR](https://github.com/ropensci/c14bazAAR) R
library to download the radiocarbon database compile by d’Errico et al.
(2011). We buid a dynamic map showing the site locations from this data
set. See our [Ruebens et
al. 2015](https://github.com/davidrbraun/ArchData/tree/master/Ruebens%20et%20al%202015)
example for how to make a static map.

``` r
#library(ggplot2)
library(tidyr)
library(dplyr)
library(knitr)
library(leaflet)
library(mapview)
library(utf8)
library(magrittr)
library(utf8)

#webshot::install_phantomjs(force = TRUE)

library(c14bazAAR)
if (!file.exists('data/pacea_ams.rds')) {
  pacea_ams = get_c14data('pacea')
  saveRDS(pacea_ams, 'data/pacea_ams.rds') 
} else {
  pacea_ams = readRDS('data/pacea_ams.rds')
}
```

There are 6020 cases in this data file. Here is what the first 10 rows
of data look like.

``` r
kable(pacea_ams[1:10,])
```

| sourcedb | sourcedb\_version | method | labnr      | c14age | c14std | site      | sitetype | feature | period                   | culture          | material | region        | country     |   lat |    lon | shortref                                                         | comment |
| :------- | :---------------- | :----- | :--------- | -----: | -----: | :-------- | :------- | :------ | :----------------------- | :--------------- | :------- | :------------ | :---------- | ----: | -----: | :--------------------------------------------------------------- | :------ |
| pacea    | 2020-01-22        | 14C    | GrN-17729  |  34800 |   1900 | A Valina  | cave     | habitat | Middle/Upper Paleolithic | Chatelperronian  | bone     | NA            | Spain       | 43.05 | \-7.34 | Llana Rodr<ed>guez and Soto Barreiro, 1991; Fortea P<e9>rez 1996 | NA      |
| pacea    | 2020-01-22        | AMS    | GrA-3014   |  32600 |    250 | A Valina  | cave     | habitat | Middle/Upper Paleolithic | Chatelperronian  | bone     | NA            | Spain       | 43.05 | \-7.34 | Fortea Perez 1996                                                | NA      |
| pacea    | 2020-01-22        | 14C    | GrN-20833  |  31730 |   2800 | A Valina  | cave     | habitat | Middle/Upper Paleolithic | Chatelperronian  | bone     | NA            | Spain       | 43.05 | \-7.34 | Fortea Perez 1996                                                | NA      |
| pacea    | 2020-01-22        | 14C    | GrN-4180   |  11140 |    700 | Aardhorst | NA       | habitat | Mesolithic               | Early Mesolithic | charcoal | Noord-Brabant | Netherlands | 51.55 |   5.12 | NA                                                               | NA      |
| pacea    | 2020-01-22        | 14C    | GrN-5997   |   8705 |    750 | Aardhorst | NA       | habitat | Mesolithic               | Early Mesolithic | charcoal | Noord-Brabant | Netherlands | 51.55 |   5.12 | NA                                                               | NA      |
| pacea    | 2020-01-22        | 14C    | GrN-5996   |   8550 |    750 | Aardhorst | NA       | habitat | Mesolithic               | Early Mesolithic | charcoal | Noord-Brabant | Netherlands | 51.55 |   5.12 | NA                                                               | NA      |
| pacea    | 2020-01-22        | 14C    | GrN-21011  |  21600 |    210 | Abauntz   | cave     | habitat | Upper Paleolithic        | Solutrean        | bone     | Navarre       | Spain       | 43.02 | \-2.04 | Higham et al. 2007                                               | NA      |
| pacea    | 2020-01-22        | 14C    | Ly-1965    |  15800 |    350 | Abauntz   | cave     | habitat | Upper Paleolithic        | Magdalenian      | NA       | Navarre       | Spain       | 43.02 | \-2.04 | Evin et al. 1983                                                 | NA      |
| pacea    | 2020-01-22        | 14C    | GrN-16316  |  15460 |    130 | Abauntz   | cave     | habitat | Upper Paleolithic        | Magdalenian      | bone     | Navarre       | Spain       | 43.02 | \-2.04 | Higham et al. 2007                                               | NA      |
| pacea    | 2020-01-22        | 14C    | Beta-65723 |  14470 |    480 | Abauntz   | cave     | habitat | Upper Paleolithic        | Magdalenian      | NA       | Navarre       | Spain       | 43.02 | \-2.04 | Higham et al. 2007                                               | NA      |

Here is a Leaflet version of the map. When rendered within rStudio this
produces a dynamic map that can be zoomed and where each data point
shows all of the data attached to that point.

``` r
htmltitle <- "<h5> PACEA Radiocarbon Database </h5>"

# Fix the UTF8 encoding for the fields to be included
pacea_ams$site = utf8_encode(pacea_ams$site)
pacea_ams$sitetype = utf8_encode(pacea_ams$sitetype)
pacea_ams$period = utf8_encode(pacea_ams$period)
pacea_ams$culture = utf8_encode(pacea_ams$culture)

# For the map, aggregate the data by site (rather than by date)
site_locations = pacea_ams %>%
  select(site, lat, lon) %>%
  distinct()

# And then lump the periods, types (should normally be one already),
# cultures into one text field for each site for the map  
for (i in 1:nrow(site_locations)) {
  site_locations$type[i] = paste(unique(pacea_ams$sitetype[pacea_ams$site == site_locations$site[i]]),
                              collapse = ', ')
  site_locations$period[i] = paste(unique(pacea_ams$period[pacea_ams$site == site_locations$site[i]]),
                                collapse = ', ')
  site_locations$culture[i] = paste(unique(pacea_ams$culture[pacea_ams$site == site_locations$site[i]]),
                                 collapse = ', ')
  site_locations$dates[i] = length(pacea_ams$site[pacea_ams$site == site_locations$site[i]])
}

# Make the labels for each site
mylabels <- paste(
  "Site Name: ", utf8_encode(site_locations$site), "<br/>",
  "Type: ", utf8_encode(site_locations$sitetype), "<br/>",
  "Period: ", utf8_encode(site_locations$period), "<br/>",
  "Culture: ", utf8_encode(site_locations$culture), "<br/>",
  "No. of dates: ", site_locations$dates) %>% lapply(htmltools::HTML)

# Make the interactive map
m <- leaflet() %>%
      addTiles %>%
      addMarkers(data = site_locations,
                  popup = ~site,
                  label = mylabels,
                  labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), 
                                              textsize = "13px", direction = "auto")) %>%
      addControl(html=htmltitle, position = "topright")
  
m
```

![](readme_files/figure-gfm/leaflet%20version-1.png)<!-- -->

The following code saves the HTML code from the Leaflet map. You can
view the [dynamic map
here](https://davidrbraun.github.io/ArchData/index.html).

``` r
mapshot(m, 'leaflet/index.html')
```

<div id="refs" class="references hanging-indent">

<div id="ref-d2011pacea">

d’Errico, FRANCESCO, William E Banks, Marian Vanhaeren, Véronique
Laroulandie, and Mathieu Langlais. 2011. “PACEA Geo-Referenced
Radiocarbon Database.” *PaleoAnthropology* 2011: 1–12.

</div>

</div>
