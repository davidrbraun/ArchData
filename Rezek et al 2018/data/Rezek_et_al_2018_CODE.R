
# This is the code for Rezek et al. 2018 "Two million years of flaking stone and
 # the evolutionary efficiency of stone tool technology", 
  # published in Nature Ecology and Evolution.

# The data is in Flake_data and Summary_data. Both files are available with this code 
 # at zenodo.org and with the published paper.

# Please make the following formatting in those files:
 # Before loading Flake_data, remove the units of measurement in the names of the variables,
  # and rename the variable "length*width/thickness^2" into "l*w/t^2".
 # Before loading Summary_data, remove the units of measurements in the names of the variables.

setwd("...")
getwd()
Flake_data=read.csv("Flake_data.csv", header=TRUE, sep=',')

# Fix bad cases by setting them to "NA"
  Flake_data$LENGTH[Flake_data$LENGTH==""] = NA
  Flake_data$WIDTH[Flake_data$WIDTH==""] = NA
  Flake_data$THICK[Flake_data$THICK==""] = NA
  Flake_data$PD[Flake_data$PD==""] = NA
  Flake_data$EPA[Flake_data$EPA==""] = NA
  Flake_data$X.l.w..t.2[Flake_data$X.l.w..t.2 ==""] = NA   # l*w/t^2 is for lenght*width/thickness^2

# Calculate the number of flakes with PD and EPA data per assemblage,
  # and the median PD and EPA values per assemblage.
  install.packages("dplyr")
  library(dplyr)
  PDEPA_medians=Flake_data %>% 
  filter(!is.na(PD) & !is.na(EPA)) %>%   # Remove "NA" cases
  group_by(Assemblage.code) %>%   # Group by assemblage
  summarize(n_PDEPA = n(),
            median_PD = median(PD),
            median_EPA = median(EPA))
# Calculate the number of flakes with l*w/t^2 data per assemblage,
  # and the median l*w/t^2 values per assemblage.
  Edge_medians=Flake_data %>% 
    filter(!is.na(X.l.w..t.2)) %>%  # Remove "NA" cases
    group_by(Assemblage.code) %>%   # Group by assemblage
    summarize(n_Edge = n(),
              median_Edge = median(X.l.w..t.2))


# Figure 1 -----
  Summary_data=read.csv("Summary_data.csv", header=TRUE, sep=',')

  install.packages("ggrepel")
  install.packages("ggplot2")
  library(ggrepel)
  library(ggplot2)

  ggplot(Summary_data, aes(x=Median.PD, y=Median.EPA, 
                          color=PERIOD, 
                          size=10
  )) + 
    geom_point(size=2) + 
    coord_fixed(ratio=0.25) +
    scale_color_manual(name="PERIOD", 
                      values=c("royalblue1", "tomato", "mediumseagreen")) +
    geom_text_repel(aes(label=ID), size=3.5) +
    labs(x = "Median platform depth (mm)", 
        y = "Median exterior platform angle (°)") + 
    xlim(1,15) + ylim(55,105) +
    theme_grey(20) +
    theme(legend.position="none",legend.title = element_blank()) 


# Supplementary Figure 1A -----
  Flake_data_individual=Flake_data %>% 
    filter(!is.na(PD) & !is.na(EPA)) %>%   # Remove "NA" cases
    select(PERIOD, PD, EPA) %>%
    mutate(zlogPD = scale(log(PD)),   # Log-transform PD and EPA and convert them into into z-scores.
          zlogEPA = scale(log(EPA)))

  ggplot(Flake_data_individual, aes(x=zlogPD, y=zlogEPA, 
                                    color=PERIOD, size=10)) + 
    geom_point(size=0.5) + 
    coord_fixed(ratio=1) +
    scale_color_manual(values=c("royalblue1", "tomato", "mediumseagreen")) +
    labs(x = "z-transformed log platform depth", 
         y = "z-transformed log exterior platform angle") + 
    stat_ellipse(level=0.95, size=1) +
    theme_grey(22.5) +
    scale_x_continuous(breaks=c(-4, -2, 0, 2, 4, 6)) +
    theme(legend.position="none",legend.title = element_blank())


# Supplementary Figure 1B -----
  covar.vec=c("Median.PD", "Median.EPA")   # Convert median EPA and PD values into z scores.
  Summary_data[, covar.vec]=scale(Summary_data[, covar.vec])

  ggplot(Summary_data, aes(x=Median.PD, y=Median.EPA, 
                           color=PERIOD)) + 
    geom_point(size=3) +
    coord_fixed(ratio=1) +
    scale_color_manual(values=c("royalblue1", "tomato", "mediumseagreen")) +
    labs(x = "z-transformed median platform depth", 
         y = "z-transformed median exterior platform angle") + 
    stat_ellipse(level=0.95, size=1) +
    theme_grey(22.5) +
    scale_y_continuous(breaks=c(-2, 0, 2)) +
    theme(legend.position="none",legend.title = element_blank())


# Figure 2 -----
  # Put the approximate ages of assemblages on a log-scale
   Log_time = Summary_data %>%
      select(ID, Site...Layer, Approximate.age..ka., PERIOD, Homo.sapiens, 
             Median.length.width.thickness.2) %>%
      mutate(log_age = log(Approximate.age..ka.))  
  # Plot the graph with y-axis reversed
  ggplot(Log_time, aes(x=Median.length.width.thickness.2, y=log_age, 
                       label=ID)) + 
    geom_point(size=3.5, aes(color=Homo.sapiens)) +
    geom_hline(yintercept = c(7.6, 6.7, 3.9), color="grey") +
    scale_y_reverse(breaks=c(7.6, 7.3, 6.7, 6, 5.3, 4.6, 3.9),   # Reverse the y-axis
                    labels=c("7.6"="2", "7.3"="1.5","6.7"="0.78", "6"="0.4",
                             "5.3"="0.2", "4.6"="0.1", "3.9"="0.05")) +
    geom_text_repel(size=4) +
    xlim(-15,60) +
    labs(x = "ratio between sharp edge amount and flake size", 
        y = "Time (Million years ago)") +
    coord_fixed(ratio=12.5) +
    theme_grey(25) +
    theme(panel.grid.minor=element_blank(),
          panel.grid.major=element_blank()) +
    scale_color_manual(values=c("black","red")) +
    theme(legend.position = "none")
  

# Supplemetary Table 1 -----
  # Calculate the median and interquartile range of sharp edge amount among all flakes within a period
  Edge_period=Flake_data %>% 
    filter(!is.na(X.l.w..t.2)) %>%   # Remove "NA" cases
    group_by(PERIOD) %>%
    summarize(n = n(),
              median_edge = median(X.l.w..t.2),
              IQR_edge = IQR(X.l.w..t.2))

  
# Figure 3 and Supplememtary Table 2 -----
  Neanderthals=Summary_data %>% 
    filter(!is.na(Cortex.ratio)) %>%   # Remove the other assemblages.
    mutate(median_Edge = Median.length.width.thickness.2,   # Simplify the name of the variable.
           maintenance = (N.of.modified.artifacts..complete.blanks.and.fragments.with.platform.
                          /N.of.unmodified.flakes..complete.and.fragments.with.platform.),   
           transport = abs(1-Cortex.ratio))    # Calculate transport intensity.
  
  Neanderthals$median_Edge=log(Neanderthals$median_Edge)  # Log-transform the median edge amount.
  covar.vec=c("maintenance", "transport")   # z-transform covariates.
  Neanderthals[, covar.vec]=scale(Neanderthals[, covar.vec])
  cor(Neanderthals[, covar.vec])   # Check for the absence of correlation between maintenance and transport.
  
  # The null and the interaction models
    null=lm(median_Edge ~ maintenance + transport, 
            data=Neanderthals)
    interaction=lm(median_Edge ~ maintenance + transport + maintenance:transport, 
                   data=Neanderthals)
    anova(null, interaction, test="F")   # Check if there is a difference between the two models
    
    summary(null)   # Summary of the null model
    # Effect sizes for individual predictors
      drop1(null)
      ind.eff=drop1(null) 
      (ind.eff$RSS[-1]-ind.eff$RSS[1])/ind.eff$RSS[-1]
    # Confidence intervals for the individual predictors
      cbind(coefficients(null), confint(object=null))
    
  # Running the assumptions for the null model.
    setwd("...")   # To get all diagnostics plots at once, source a function.
    source("diagnostic_fcns.r")
    diagnostics.plot(null)   # Check residuals for normality and homogeneity.
    cor.test(fitted(null), abs(residuals(null)))    # Quantify homogeneity.
    max(abs(dffits(null)))     # Check DFFit 
    round(cbind(null$coefficients, null$coefficients +   # Check DFBeta values.
                t(apply(X=dfbeta(null), MARGIN=2, FUN=range))), digits=3)
    max(cooks.distance(null))    # Check Cook's distance.
    max(as.vector(influence(null)$hat))   # Check leverage.
      lev.thresh(null)    # Get the threshold for leverage.
    # Check variance inflation factors.
      install.packages("car")
      library(car)
      vif(null)
    
  # Plotting the regression (the null model)
  setwd("...")    # Source a function.
  source("three_d_plot.r")  
  xx=draw.2.w.int.bw.cov.2(
    plot.data=Neanderthals,
    vars=c("maintenance", "transport"),
    coefs=coefficients(null),
    link="identity",
    grid.resol=25,
    var.names=c(" ", " "),
    zlab=" ",
    zlim=range(Neanderthals$median_Edge)*c(1.05, 1),
    theta=-240,
    phi=10,
    expand=0.5,
    r=10,
    response=Neanderthals$median_Edge,
    size.fac=1.2,
    print.NA.cells=T,
    quiet=F
    )
  
  
  
  
  
  