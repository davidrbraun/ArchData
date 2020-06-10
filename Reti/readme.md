---
title: "Reti Data"
author: "Shannon P. McPherron"
date: "6/10/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

library(readxl)
library(httr)

```

## R Markdown


```{r read_data}
url = "https://ndownloader.figshare.com/articles/2056551/versions/1"
GET(url1, write_disk(tf <- tempfile(fileext = ".zip")))
df <- read_excel(tf, 2L)
str(df)

```


Reti, Jay (2015): Reti - PLOS ONE Data.xlsx. figshare. Dataset. https://doi.org/10.6084/m9.figshare.2056551.v1