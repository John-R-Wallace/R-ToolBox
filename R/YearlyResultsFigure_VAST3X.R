
YearlyResultsFigure_VAST3X <- function(spShortName. = NULL, spLongName. = NULL, HomeDir = ".", eastLongitude = -124 - (N + 1) * longitudeDelta, longitudeDelta = 3.5, 
        Index. = NULL, fit. = fit, DateFile. = DateFile, Region. = Region, Year_Set. = Year_Set, Years2Include. = Years2Include,
        strata.limits. = NULL, Ages. = NULL, LenMin. = NULL, LenMax. = NULL, yearDelta = 0.5, 
        title = FALSE, relativeAbundance = FALSE, changeUnitsUnder1Kg = TRUE, sweptAreaInHectares = FALSE, rhoConfig. = NULL, numCol = 1000, Graph.Dev = "tif") 
{

    hexPolygon <- FALSE  # Now using plot_variable_JRW() - a hacked function of Thorson's plot_variable()
    
    if (!any(installed.packages()[, 1] %in% "devtools")) 
        install.packages("devtools")
    if (!any(installed.packages()[, 1] %in% "JRWToolBox")) 
        devtools::install_github("John-R-Wallace/JRWToolBox")
        
            
    JRWToolBox::lib(TeachingDemos, pos = 1000)   # Put in further back in search position because of a conflict with %<=% function in my tool box.
    
    color.bar <- function(lut, min, max=-min, nticks=11, ticks=seq(min, max, len=nticks), title = '', ...) {
          scale = (length(lut)-1)/(max-min)
          plot(c(0,10), c(min,max), type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='', main = title, ...)
          axis(2, ticks, las=1, col.axis = 'white')
          for (i in 1:(length(lut)-1)) {
             y = (i-1)/scale + min
             rect(0,y,10,y+1/scale, col=lut[i], border=NA)
          }
    }
 
    setwd(HomeDir) 
      
    graphics.off()
    
    if(any(grepl('D_gcy', names(fit.$Report))))
            D_gc <- fit.$Report[["D_gcy"]]
       
    if(any(grepl('D_gct', names(fit.$Report))))
            D_gc <- fit.$Report[["D_gct"]]        
     
    cat("\nDimension of D_gc:", dim(D_gc), "\n\n")     
    
    
   
    map_list. = FishStatsUtils::make_map_info( Region = Region., Extrapolation_List = fit.$extrapolation_list, spatial_list = fit.$spatial_list, 
                        NN_Extrap = fit.$spatial_list$PolygonList$NN_Extrap) 
    
        
    # D_gcy <- as.data.frame(log(fit$tmb_list$Obj$report()[["D_gcy"]][, 1, ]))
    # D_gcy <- as.data.frame(log(fit.$Report[["D_gcy"]][map_list.$PlotDF$Include[!is.na(map_list.$PlotDF$x2i)], 1, ]))
    
    SP.Results.Dpth. <- as.data.frame(log(D_gc[map_list.$PlotDF[map_list.$PlotDF[, 'Include'], 'x2i'], 1, ]))
        
    # D_gcy <- log(Obj$report()[["D_gcy"]][, 1, ])
    names(SP.Results.Dpth.) <- paste0("X", Year_Set.)
    
    # Appears no need for this code - and done each time in the year loop besides
    # loc_g <- map_list.$PlotDF[!is.na(map_list.$PlotDF$x2i), c('Lon','Lat')]
    # Points_orig = sp::SpatialPoints( coords=loc_g, proj4string=sp::CRS( '+proj=longlat' ) )
    # Points_LongLat = sp::spTransform( Points_orig, sp::CRS('+proj=longlat') ) # Reproject to Lat-Long  
    
    # SP.Results.Dpth. <- data.frame(map_list.$PlotDF[!is.na(map_list.$PlotDF$x2i) & map_list.$PlotDF$Include, c('Lon','Lat')], D_gcy)
    # SP.Results.Dpth. <- na.omit(SP.Results.Dpth.)
     
    print(SP.Results.Dpth.[1:4, ])
     

    if(hexPolygon) {       
      
       JRWToolBox::catf("\n\nCreating the species results by year figure using hexagon shapes (hexbin R package)\n\n")
        
       # numCol Colors 
       SP.Results <- SP.Results.Dpth.
       SP.Results[,-(1:2)] <- exp(SP.Results[,-(1:2)])
       SP.Results[,-(1:2)] <- SP.Results[,-(1:2)] - min(SP.Results[,-(1:2)])
       SP.Results[,-(1:2)] <- SP.Results[,-(1:2)] * (numCol - 1)/max(SP.Results[,-(1:2)]) + 1 
       SP.Results$Rescaled.Sum <- apply(SP.Results[,-(1:2)], 1, sum)
       SP.Results$Rescaled.Sum <- SP.Results$Rescaled.Sum - min(SP.Results$Rescaled.Sum)
       SP.Results$Rescaled.Sum <- SP.Results$Rescaled.Sum * (numCol - 1)/max(SP.Results$Rescaled.Sum) + 1
    }
    
    # ------------- VAST Species Results by Year Figure -------------  
   
    if(is.null(Index.)) {
        if(exists('Index')) {
           if(is.data.frame(Index))
               Index. <- Index
           else
              Index. <- Index$Table[Years2Include., ]
        } else
           Index. <- read.csv(paste0(DateFile., "Table_for_SS3.csv"))[Years2Include., ]
    }
            
    if(is.null(spShortName.) & exists('spShortName'))  
        spShortName. <- spShortName
    if(is.null(spShortName.) & !exists('spShortName')) {
         warning("No short species name given nor found.")
          spShortName. <- "Species X"
    }
    if(is.null(spLongName.) & exists('spLongName'))  
        spLongName. <- spLongName 
    if(is.null(spLongName.) & !exists('spLongName'))          
        spLongName. <- spShortName.
     
    if(hexPolygon)
        resName <- "SpResults_Hex_ "
    
    if(!hexPolygon)
        resName <- "SpResults "    

    if(is.null(rhoConfig.))  {
    
        if(Graph.Dev == "png")      
            png(paste0(DateFile., resName, spShortName., ".png"),  width = 6000, height = 6000, bg = 'white', type = 'cairo')
        
        if(Graph.Dev == "tif")      
            tiff(paste0(DateFile., resName, spShortName., ".tif"),  width = 6000, height = 6000, bg = 'white', type = 'cairo') # 10" X 10" @ 600 dpi (10*10*600*600 = 6000^2)
    } else {
    
        if(Graph.Dev == "png")      
            png(paste0(DateFile., resName, spShortName., ", Rho = ", rhoConfig., ".png"),  width = 6000, height = 6000, bg = 'white', type = 'cairo')
        
        if(Graph.Dev == "tif")      
            tiff(paste0(DateFile., resName, spShortName., ", Rho = ", rhoConfig., ".tif"),  width = 6000, height = 6000, bg = 'white', type = 'cairo') # 10" X 10" @ 600 dpi (10*10*600*600 = 6000^2)
    } 
    
    par(cex = 6)   

    N <- length(Year_Set.)

    # eastLongitude <- -122 - (N + 1) * longitudeDelta
    eastLongitude <- eastLongitude # Needed for imap() to find this
    
    latExtend <- ifelse(N > 13, -((-125 - (N + 1) * 3.5 + 117) - (-125 - 14 * 3.5 + 117))/3, 0)
       
    Imap::imap(longlat = list(Imap::world.h.land, Imap::world.h.borders, Imap::world.h.island), col= c("black", "cyan"), poly = c("grey40", NA), longrange = c(eastLongitude, -117), latrange = c(27 - latExtend, 48.2), 
             axes = 'latOnly', zoom = FALSE, bg = "white", cex.ylab = 1.5, cex.axis = 1.5, lwd.ticks = 1.5)
    box(lwd = 5)
    
    # Col <- colorRampPalette(colors = c("blue", "dodgerblue", "cyan", "green", "orange", "red", "red3"))
    # Col = colorRampPalette(colors=c("blue", "dodgerblue", "cyan", "green", "yellow", JRWToolBox::col.alpha('yellow'), JRWToolBox::col.alpha('red'), "red"))
    Col =  Col = colorRampPalette(colors=c("blue", "dodgerblue", "cyan", "green", "yellow", "orange", "red"))
    
    COL <- Col(numCol)
    
    # JRWToolBox::hexPolygon(SP.Results$Lon, SP.Results$Lat, hexC = hexcoords(dx = 0.01, sep=NA), col = COL, border = COL)
     
    if(hexPolygon) {
      for (i in 1:N) {
 
        COL <- Col(numCol)[SP.Results[, N + 3 - i]]
        assign("COL", COL, pos = 1) # Is this needed?
        JRWToolBox::hexPolygon(SP.Results$Lon - i * longitudeDelta, SP.Results$Lat, hexC = hexcoords(dx = 0.01, sep = NA), col = COL, border = COL)
       } 
       
       #  for (i in 1:N) {
       #  COL <- Col(numCol)[SP.Results[, N + 3 - i]]
       #  assign("COL", COL, pos = 1)
       #  JRWToolBox::hexPolygon(SP.Results$X - i * longitudeDelta, SP.Results$Y, hexC = hexcoords(dx = 0.1, sep = NA), col = COL, border = COL)
    }
    
    if(!hexPolygon) {
       oldOpt <- options(warn = -1)
       for (i in 0:N) {
       
            JRWToolBox::plot_variable_JRW( Y_gt = log(D_gc[, 1, ]), projargs = '+proj=longlat', col = COL,
                    map_list = map_list., numYear = ifelse(i == 0, 0, N - i + 1), Delta = - i * longitudeDelta )
          }       
          # plot_variable_JRW(  Y_gt = SP.Results.Dpth., projargs='+proj=longlat', map_list = make_map_info(Region = "California_current", 
          #      Extrapolation_List = Extrapolation_List, spatial_list = Spatial_List), numYear = i, Delta = - i * longitudeDelta )
          options(oldOpt)
    }
    
    Index.$LongPlotValues <- -124.6437 + seq(-longitudeDelta, by = -longitudeDelta, len = N)
    Index.$LatPlotValues <- rev((48 - 34.2) * (Index.$Estimate_metric_tons - min(Index.$Estimate_metric_tons))/max(Index.$Estimate_metric_tons) + 34.2)
    Index.$LatSD_mt <- rev((48 - 34.2)/(max(Index.$Estimate_metric_tons) - min(Index.$Estimate_metric_tons)) * Index.$SD_mt)
    
    # It appears that calls to text() need to be before things get changed by using subplot() below.
 
    # Standard swept area is km2, but here the numbers are converted to hectares, unless the swept area was already in hectares (non-standard)
    GRAMS <- ifelse(sweptAreaInHectares, 1, 0.01) * max(exp(SP.Results.Dpth.)) < 1 & changeUnitsUnder1Kg   # Auto change to grams under 1 kg/ha

    # Converting relative plotting location, 0.5 out of [0, 1] to latitude
    latAdj <- 0.5 * (48.2 - 27 + latExtend) + 27 - latExtend
    longStatic <- -118.1
    
    if(N <= 4) {
       latAdj <- latAdj + 1.2
       longStatic <- -119.7
    }   
    
    # text(-118.5, 37.50, ...
    if(GRAMS)
        text(longStatic, latAdj, 'Grams per Hectare', cex = 0.80, col = 'white')    
    else
        text(longStatic, latAdj, 'Kg per Hectare', cex = 0.85, col = 'white') 
     
    if(is.null(strata.limits.)) {
       if(exists('stata.limits')) 
          strata.limits. <- strata.limits 
       else 
          strata.limits. <- Settings$strata.limits
    }  
    
    LatMin. <- strata.limits.$south_border[1]
    
    if(LatMin. >= 33.8)
           ageLat <- 34
           
    if(LatMin. > 32.25 & LatMin. < 33.8)
           ageLat <- 33
           
    if(LatMin. <= 32.25)    
           ageLat <- 32  
     
     if(is.null(Ages.) & !(!exists('Ages', where = 1, inherits = F) || is.null(Ages))) {
          Ages. <- Ages
          cat("\n\nUsing the non-null 'Ages' found in .GlobalEnv. Delete or rename the file to not use it.\n")
    }     
        
    if(is.null(LenMin.) & exists('LenMin')) {
          LenMin. <- LenMin
          cat("\n\nUsing the 'LenMin' found. Delete or rename the file to not use it.\n")
    }
    if(is.null(LenMax.) & exists('LenMax')) {
          LenMax. <- LenMax
          cat("\n\nUsing the 'LenMax' found. Delete or rename the file to not use it.\n\n")
    }
    
    if(title) {
        if( is.null(LenMin.) | is.null(LenMax.)  )
           title(list(JRWToolBox::casefold.f(spLongName.), cex = 1.5))
        if( !is.null(LenMin.) & !is.null(LenMax.) & is.null(Ages.) ) 
           title(list(paste0(JRWToolBox::casefold.f(spLongName.), '; Length range (cm): ', LenMin., " - ", LenMax.), cex = 1.5))
        if( !is.null(LenMin.) & !is.null(LenMax.) & !is.null(Ages.) ) {
           if(length(Ages.) == 1)
             title(list(paste0(JRWToolBox::casefold.f(spLongName.), '; Age: ', Ages., ', Length range (cm): ', LenMin., " - ", LenMax.), cex = 1.5))
           else
             title(list(paste0(JRWToolBox::casefold.f(spLongName.), '; Ages: ', min(Ages.), " - ", max(Ages.), ', Length range (cm): ', LenMin., " - ", LenMax.), cex = 1.5))
        }             
    }
    
    # Abundanace and CI from SD_log
    Abundance <- ifelse(sweptAreaInHectares, 100, 1) * Index.$Estimate_metric_tons
    li <- ifelse(sweptAreaInHectares, 100, 1) * Index.$Estimate_metric_tons * exp(-Index.$SD_log)
    ui <- ifelse(sweptAreaInHectares, 100, 1) * Index.$Estimate_metric_tons * exp(Index.$SD_log)
        
    if(relativeAbundance) {
        maxUi <- max(ui)
        Abundance <- Abundance/maxUi
        li <- li/maxUi
        ui <- ui/maxUi
        sweptAreaInHectares <- FALSE
        parsMar <- list( mar=c(1.5,5,0,0) + 0.1)
        yLab = 'Relative\nAbundance'
        xAdjust <- 0.02
     } else {
        parsMar <- list( mar=c(1.5,4,0,0) + 0.1)
        yLab <- 'Abundance (mt)'
        xAdjust <- 0
     }    
    
    # If swept area is in hectares (non-standard) then a 100X adjustment is needed since VAST multiples by 4 km2 per extrapolation grid point, but while using hectares needs 400ha per point.    
    if(LatMin. >= 35.0) {
        text(-123.2, 37.25, "All", cex = 0.80)
        text(-123.2, 37.25 - yearDelta, "Years", cex = 0.80)
        TeachingDemos::subplot( {par(cex = 5); JRWToolBox::plotCI.jrw2(Index.$Year, Abundance, li, ui, type = 'b', sfrac = 0, xlab='Year', ylab = list(yLab, cex = 1.2), col = 'red', lwd = 7, cex =1, xaxt = "n", 
                 yaxt = "n", bty = 'n'); axis(3, Year_Set., lwd = 5, cex.axis =1.5); axis(2, lwd = 5, cex.axis =1.1)}, x=grconvertX(c(0.01 - xAdjust, 0.820), from='npc'), y=grconvertY(c(0.22, 0.48), 
                 from='npc'), type='fig', pars= parsMar)
    } 
    
    if(LatMin. >= 33.8 & LatMin. < 35) {
        text(-120, 33.29, "All", cex = 0.80)
        text(-120, 33.29 - yearDelta, "Years", cex = 0.80)
        TeachingDemos::subplot( {par(cex = 5); JRWToolBox::plotCI.jrw2(Index.$Year, Abundance, li, ui, type = 'b', sfrac = 0, xlab='Year', ylab = list(yLab, cex = 1.2), col = 'red', lwd = 7, cex =1, xaxt = "n", 
               yaxt = "n", bty = 'n'); axis(3, Year_Set., lwd = 5, cex.axis =1.5); axis(2, lwd = 5, cex.axis =1.1)}, x=grconvertX(c(0.08 - xAdjust, 0.870), from='npc'), y=grconvertY(c(0.02, 0.28), from='npc'), 
               type='fig', pars= parsMar)
    } 

    if(LatMin. > 32.25 & LatMin. < 33.8) {
        text(-118.0, 32.053, "All", cex = 0.85)
        text(-118.0, 32.053 - yearDelta, "Years", cex = 0.85)
        TeachingDemos::subplot( {par(cex = 5); JRWToolBox::plotCI.jrw2(Index.$Year, Abundance, li, ui, type = 'b', sfrac = 0, xlab='Year', ylab = list(yLab, cex = 1.2), col = 'red', lwd = 7, cex =1, xaxt = "n", 
               yaxt = "n", bty = 'n'); axis(3, Year_Set., lwd = 5, cex.axis =1.5); axis(2, lwd = 5, cex.axis =1.1)}, x=grconvertX(c(0.10 - xAdjust, 0.915), from='npc'), y=grconvertY(c(0, 0.225), 
               from='npc'), type='fig', pars= parsMar)
    }
    
    # Old values: y=grconvertY(c(0, 0.190), from='npc'); x=grconvertX(c(0.10, 0.89), from='npc')
    
    xExpand <- ifelse(N > 13, (N - 13) * 0.025/3, 0)
    if(LatMin. <= 32.25) {
        text(-118.7, 31.266, "All", cex = 0.85)
        text(-118.7, 31.266 - yearDelta, "Years", cex = 0.85)
        TeachingDemos::subplot( {par(cex = 5); JRWToolBox::plotCI.jrw3(Index.$Year, ifelse(sweptAreaInHectares, 100, 1) * Index.$Estimate_metric_tons,  ifelse(sweptAreaInHectares, 100, 1) * Index.$SD_mt, 
          type = 'b', sfrac=0, xlab='Year', ylab = yLab, col = 'red', lwd = 7, cex =1, xaxt = "n", bty = 'n');  axis(3, Year_Set., lwd = 5); axis(side = 2, lwd = 5)}, 
          x=grconvertX(c(0.10 - xAdjust - xExpand, 0.89 + xExpand), from='npc'), y=grconvertY(c(0, (31.03 - 27 + 0.8 * latExtend)/(48.2 - 27 + 0.8 * latExtend)), from='npc'), type='fig', pars= parsMar )
    }
    
    
    # Standard swept area is km2, but here the numbers are converted to hectares, unless the swept area was already in hectares (non-standard)
    if(N <= 4) {
       xStart <- 0.720
       yStart <- 0.632
    } else {
       xStart <- 0.850
       yStart <- 0.625
    }   
       
    # Slightly increasing the factor on longitudeDelta (0.00702 & 0.0611) results in a smaller rectangle for the legend
    xAdj <-  xStart + c(-1, 1) * (0.04 - longitudeDelta * 0.00702)
    yAdj <-  yStart + c(-1, 1) * (0.2875 - longitudeDelta * 0.0611)
    
    if(GRAMS)
        TeachingDemos::subplot( { par(cex = 5); color.bar(Col(ifelse(numCol > 100, numCol, 100)), JRWToolBox::r(1000 * ifelse(sweptAreaInHectares, 1, 0.01) * min(exp(SP.Results.Dpth.)), 0), 
            JRWToolBox::r(1000 * ifelse(sweptAreaInHectares, 1, 0.01) * max(exp(SP.Results.Dpth.)), ifelse(1000 * ifelse(sweptAreaInHectares, 1, 0.01) * max(exp(SP.Results.Dpth.)) < 1, 1, 0)), 
            nticks = 6) }, x=grconvertX(xAdj, from='npc'), y=grconvertY(yAdj, from='npc'), type='fig', pars=list( mar=c(0,0,1,0) + 0.1) )    
    else 
        TeachingDemos::subplot( { par(cex = 5); color.bar(Col(ifelse(numCol > 100, numCol, 100)), JRWToolBox::r(ifelse(sweptAreaInHectares, 1, 0.01) * min(exp(SP.Results.Dpth.)), 1), 
            JRWToolBox::r(ifelse(sweptAreaInHectares, 1, 0.01) * max(exp(SP.Results.Dpth.)), 1), nticks = 6) }, x=grconvertX(xAdj, from='npc'), 
            y=grconvertY(yAdj, from='npc'), type='fig', pars=list( mar=c(0,0,1,0) + 0.1) )     
        
    dev.off()
  
    # invisible(SP.Results.Dpth.)  
    invisible()  
 }
 
