# URL
# https://github.com/abcnorio/aas-sim-mult

# (C) by abcnorio 2024-2025

# licence
# GPL v3
# https://www.gnu.org/licenses/gpl-3.0.en.html


########################################
### svhs simulation script helpers

### FUNCTIONS
# create log sequence
create.log <-function(start=1e-6,end=1e2,length=1e2+1)
{
  10^( seq(log10(start),log10(end),length.out=length) )
}


### CREATE SEQUENCES of possible values per parameter
# create sequences for later drawing samples
create.seqs <- function(basejson.sheet=NULL,
                        loglaenge=1e2,
                        rnmult=1e5,
                        seed=776699,
                        VERBOSE=FALSE
                        )
{
  set.seed(seed)
  basejson.sheet.l <- dim(basejson.sheet)[1]
  basejson.sheet.n <- basejson.sheet[,"configname"]

  samp.list <- lapply(seq_along(1:basejson.sheet.l), function(i)
  {
    cat("i = ",i," [",basejson.sheet.n[i],"]\n",sep="")
    default.profile <- basejson.sheet[i,]

    if(VERBOSE == TRUE) print(default.profile)

    if(default.profile[,"type"] == "PERCENT")
    {
      if(default.profile[,"development"] == "linear")
      {
        # linear  
        sek <- seq(as.numeric(default.profile[,"min"]),
                  as.numeric(default.profile[,"max"]),
                  by=1/10^as.numeric(default.profile[,"digits"])
                  )
      } else if(default.profile[,"development"] == "nonlinear")
      {
        # log/ non-linear
        lowerbound <- 10^(-as.integer(default.profile[,"digits"]))
        sek <- create.log(start=lowerbound,
                          end=as.integer(default.profile[,"max"]),
                          length=loglaenge)
        sek <- c(as.integer(default.profile[,"min"]),sek)
      }
    } else if(default.profile[,"type"] == "INTEGER")
    {
      # integer
      sek <- as.integer(default.profile[,"min"]):as.integer(default.profile[,"max"])
    } else if(default.profile[,"type"] == "FLOAT")
    {
      # float number
      sek <- seq(from=as.numeric(default.profile[,"min"]),
                to=as.numeric(default.profile[,"max"]),
                by=( 1/(10^as.integer(default.profile[,"digits"])) )
                )
    } else if(default.profile[,"type"] == "CATEGORY")
    {
      # category
      sek <- c(as.integer(default.profile[,"min"]):as.integer(default.profile[,"max"]))
    } else if(default.profile[,"type"] == "RANDOM")
    {
      # category
      sek <- runif(1)*rnmult
    } else if(default.profile[,"type"] == "VERSION")
    {
      # category
      sek <- 1
    } else if(default.profile[,"type"] == "LOGICAL")
    {
      # category
      # no real T/F values but lowercase
      sek <- c(TRUE,FALSE)
    }
  })
  names(samp.list) <- basejson.sheet.n

return(samp.list)
}
#########
# call:
#samp.list <- create.seqs(basejson.sheet=basejson.sheet)
#length(samp.list)
#sapply(samp.list,length)
#lapply(samp.list,head)
#lapply(samp.list,tail)

### CREATE PROBABILITIES AND DRAW SAMPLES FROM SEQUENCE ALONG WITH PROBABILITIES
create.samples <- function(basejson.sheet=NULL, # base sheet
                           samp.list=NULL, # sample space created earlier
                           Nsize=1e2, # sample size to create
                           seed=776699,
                           VERBOSE=FALSE,
                           credint=c(0.6,.8,.9,.95,.99) # credible interval limits if needed
                           )
{
  set.seed(seed)
  basejson.sheet.l <- dim(basejson.sheet)[1]
  basejson.sheet.n <- basejson.sheet[,"configname"]
  
  params.out <- lapply(seq_along(1:basejson.sheet.l), function(i)
  {
    CHANGE <- TRUE
    
    cat("\ni = ",i," [",basejson.sheet.n[i],"]",sep="")
    
    probNsize <- length(samp.list[[i]])
    default.profile <- basejson.sheet[i,]
  
    # check whether we should anything at all for the parameter in question
    if(default.profile[,"CH"] == FALSE)
    {
      anchorv <- default.profile[,"anchorPR"]
      if(default.profile[,"type"] == "LOGICAL")
      {
        anchorv <- tolower(anchorv)
        
      } else
      {
        anchorv <- as.numeric(anchorv)
      }
      CHANGE <- FALSE
      sampleV.out <- rep(anchorv,Nsize)
    } else if(! is.na(default.profile[,"subref.lfd"]))
    {
      # check for dependency of a parameter with an upper parameter being blocked
      subref.spl <- default.profile[,"subref.lfd"]
      if(! is.numeric(subref.spl) )
      {
        subref.spl <- as.numeric(unlist(strsplit(subref.spl,",",fixed=TRUE)))
      }
      subref.id <- which( basejson.sheet[,"lfd"] == subref.spl)
      if(any( basejson.sheet[subref.id,"CH"] == FALSE ))
      {
        anchorv <- default.profile[,"anchorPR"]
        if(default.profile[,"type"] == "LOGICAL")
        {
          anchorv <- tolower(anchorv)
        } else
        {
          anchorv <- as.numeric(anchorv)
        }
        CHANGE <- FALSE
        sampleV.out <- rep(anchorv,Nsize)
      }
    }
    
  if(CHANGE == TRUE)
  {
    # extract default values
    anchorv <- default.profile[,"anchorPR"]
    sdv <- default.profile[,"SD"]
    minv <- default.profile[,"min"]
    maxv <- default.profile[,"max"]
    digits <- default.profile[,"digits"]
  
    samp.list.l <- length(samp.list[[i]])
    
    # convert to proper format
    if(default.profile[,"type"] %in% c("FLOAT","INTEGER","PERCENT","CATEGORY"))
    {
      anchorv <- as.numeric(anchorv)
      minv <- as.numeric(minv)
      maxv <- as.numeric(maxv)
      digits <- as.numeric(digits)
      if(default.profile[,"probcalc"] != "beta")
      {
        sdv <- as.numeric(sdv)
      }
    }
    if(default.profile[,"type"] %in% c("LOGICAL"))
    {
      anchorv <- as.logical(anchorv)
      minv <- as.logical(minv)
      maxv <- as.logical(maxv)
    }
    probs <- unlist(strsplit(default.profile[,"probs"],"|",fixed=TRUE))
    if(default.profile[,"type"] %in% c("CATEGORY","LOGICAL","INTEGER"))
    {
      if( default.profile[,"probcalc"] == c("uniform") )
      {
        if(length(probs) == 1 && probs == "EQUAL") 
        {
          probs <- rep(1/samp.list.l,samp.list.l)
        } else
        {
          probs <- as.numeric( probs )
        }
      }
    }
    
    if(default.profile[,"type"] == "PERCENT")
    {
      if(default.profile[,"development"] == "linear")
      {
        # linear
        if(default.profile[,"probcalc"] == "normtrunc")
        {
          #rnormtruncdat <- rnormTrunc(probNsize, mean=anchorv, sd=sdv, min=minv, max=maxv)
          #hdi(rnormtruncdat,credint)
          dnormtruncdat <- dnormTrunc(seq(minv, maxv, length.out=probNsize),
                                      mean=anchorv,
                                      sd=sdv,
                                      min=minv,
                                      max=maxv
                                      )
          sampleV.out <- sample(samp.list[[i]], size=Nsize, replace=TRUE, prob=dnormtruncdat)
          sampleV.out <- signif(sampleV.out, digits=digits)
        } else stop("Anything except 'normtrunc' not implemented.")
      } else if(default.profile[,"development"] == "nonlinear")
      {
        # log/ non-linear
        # extract dist specific parameters
        methode <- default.profile[,"METHOD"]
        LOW <- as.numeric( default.profile[,"LOW"] )
        UP <- as.numeric( default.profile[,"UP"] )
        stopifnot(methode %in% c("mean","mode"))
  
        # locate LOW, UP, and anchorv      
        df <- data.frame(sek=seq(0,1,length.out=samp.list.l), samp=samp.list[[i]])
        LOW.id <- which( samp.list[[i]] == Closest( df[,"samp"], LOW) )
        UP.id <- which( samp.list[[i]] == Closest(samp.list[[i]], UP) )
        anchorv.id <- which( samp.list[[i]] == Closest(samp.list[[i]], anchorv) )
        LOW.trans <- df[LOW.id,"sek"]
        UP.trans <- df[UP.id,"sek"]
        anchorv.trans <- df[anchorv.id,"sek"]
  
        beta.parm <- betaExpert(best=anchorv.trans, lower=LOW.trans, upper=UP.trans, method=methode)
        dbetadat <- dbeta(df[,"sek"],
                          shape1=beta.parm[["alpha"]],
                          shape2=beta.parm[["beta"]])
        sampleV.out <- sample(samp.list[[i]], size=Nsize, replace=TRUE, prob=dbetadat)
        sampleV.out <- signif(sampleV.out, digits)
      }
    } else if(default.profile[,"type"] == "INTEGER")
    {
      # integer
      if(default.profile[,"probcalc"] == "normtrunc")
      {
        #rnormtruncdat <- rnormTrunc(probNsize, mean=anchorv, sd=sdv, min=minv, max=maxv)
        #hdi(rnormtruncdat,credint)
        dnormtruncdat <- dnormTrunc(seq(minv, maxv, length.out=probNsize),
                                    mean=anchorv,
                                    sd=sdv,
                                    min=minv,
                                    max=maxv
                                    )
        sampleV.out <- sample(samp.list[[i]], size=Nsize, replace=TRUE, prob=dnormtruncdat)
        sampleV.out <- signif(sampleV.out, digits=digits)
      } else if(default.profile[,"probcalc"] == "uniform")
      {  
        sampleV.out <- sample(samp.list[[i]], size=Nsize, replace=TRUE, prob=probs)
      } else stop("Anything except 'normtrunc' not implemented.")
    } else if(default.profile[,"type"] == "FLOAT")
    {
      # float number
      if(default.profile[,"probcalc"] == "normtrunc")
      {
        #rnormtruncdat <- rnormTrunc(probNsize, mean=anchorv, sd=sdv, min=minv, max=maxv )
        #hdi(rnormtruncdat,credint)
        dnormtruncdat <- dnormTrunc(seq(minv, maxv, length.out=probNsize),
                                    mean=anchorv,
                                    sd=sdv,
                                    min=minv,
                                    max=maxv
                                    )
        sampleV.out <- sample(samp.list[[i]], size=Nsize, replace=TRUE, prob=dnormtruncdat)
        sampleV.out <- signif(sampleV.out, digits=digits)
      } else stop("Anything except 'normtrunc' not implemented.")
    } else if(default.profile[,"type"] == "CATEGORY")
    {
      if(default.profile[,"probcalc"] == "uniform")
      {
        # category
        sampleV.out <- sample(samp.list[[i]], size=Nsize, replace=TRUE, prob=probs)
      } else stop("Anything except 'uniform' (with probs) not implemented.")
  
    } else if(default.profile[,"type"] == "RANDOM")
    {
      # random
      sampleV.out <- sample(1:(Nsize*100),Nsize)
    } else if(default.profile[,"type"] == "VERSION")
    {
      # version
      sampleV.out <- rep(1,Nsize)
    } else if(default.profile[,"type"] == "LOGICAL")
    {
      # logical
      sampleV.out <- sample(c("false","true"), Nsize, replace=TRUE, prob=probs)
    }
  } # end if IF CHANGE 
  
  # required to give something back to the lapply call
  sampleV.out
  }) # end of lapply

  if(VERBOSE) print(sampleV.out)
  names(params.out) <- basejson.sheet.n

return(params.out)
}
#########
# call:
#params.out <- create.samples(basejson.sheet=basejson.sheet, samp.list=samp.list)
#                           
#params.out.l <- sapply(params.out, function(x) length(x))
#length(unique(params.out.l)) == 1
#lapply(params.out, function(x) head(x))
#lapply(params.out, function(x) tail(x))
#length(params.out)
  
  
### CREATE JSONS

# create lfd numbering with leading zeros to maintain length of the number
convert.ID.to.zeroID <- function(lfd)
{
  lfd.nc <- nchar(lfd)
  lfd.nc.max <- max(lfd.nc)
  lfd.nc.inv <- lfd.nc.max - lfd.nc
  lfd.nc.inv.filled <- sapply(lfd.nc.inv, function(x) paste(rep("0",x),collapse=""))
  res.merged <- sapply(seq_along(1:length(lfd)), function(x)
  {
    paste(lfd.nc.inv.filled[x], lfd[x], sep="")
  })
return(res.merged)
}
# call:
#numbering <- convert.ID.to.zeroID(1:Nsize)
#
#head(numbering)
#tail(numbering)

# create jsons from params.out list
create.jsons <- function(basejson.sheet=NULL,
                         params.out=NULL,
                         Nsize=NULL, # sample size over all files taken from the params.out object
                         each=2, # number of variations per file
                         fnamlist=NULL, # list of filenames
                         prefix="ntsc-rs", # prefix for all files IF we do not use the filename itself
                         WRITE=FALSE,
                         VERBOSE=FALSE,
                         OVERWRITE=TRUE)
{
  basejson.sheet.l <- dim(basejson.sheet)[1]
  params.out.l <- length(params.out[[1]])
  if(! is.null(fnamlist) )
  {
    fnamlist.l <- length(fnamlist)
    if( (fnamlist.l*each) > params.out.l) stop("(fnamlist.l * each) > params.out sample.")
    Nsize <- fnamlist.l*each # multiply by variations per file
    prefix <- fnamlist
  } else
  {
    # fnamlist == NULL
    if(! is.null(Nsize))
    {
      # Nsize == NULL
      if( (Nsize*each) > params.out.l ) stop("(Nsize * each) > params.out sample.")
      Nsize <- Nsize*each
    } else
    {
      if( params.out.l > 1 && params.out.l < each ) stop("params.out.l > 1 & params.out.l < each.")
      if(params.out.l == 1)
      {
        # single case
        Nsize <- params.out.l * each
      } else
      {
        Nsize <- params.out.l %/% each
      }
    }
    prefix <- rep(prefix, Nsize)
    fnam.list.l <- Nsize
  }

  # numbering ONLY per sub ie. file ie. prefix stays constant
  numbering <- convert.ID.to.zeroID(1:each)
  
  # all json names, no need to go via loop
  # json and outjson.nam have nothing to do with each other(!!)
  OUTjson.nam <- paste(prefix,"_",rep(numbering,each=(Nsize/each)),".json",sep="")

  # create jsons and save if required and name the list accordingly
  if(params.out.l == 1)
  {
    # single case
    sek.end <- 1
  } else
  {
    sek.end <- Nsize
  }
  
  params.out.jsons <- lapply(seq_along(1:sek.end), function(i)
  {
    element <- lapply(params.out, "[[",i)
    names.element <- names(element)
    
    # create json
    OUTjson <- paste("{",paste(sapply(seq_along(1:basejson.sheet.l), function(j)
    {
      paste("\"",names.element[j],"\":",element[[j]],sep="")
    }),collapse=","),"}",sep="")
    
    # write json to file
    print(OUTjson.nam[i])
    cat("\nwrite to file with WRITE = ",WRITE,sep="")
    if(WRITE == TRUE)
    {
      fex <- file.exists(OUTjson.nam[i])
      cat("\nfile exists = ",fex,sep="")
      cat("\noverwrite file, OVERWRITE = ",OVERWRITE,"\n",sep="")
      #fileConn <- file(OUTjson.nam[i]); writeLines(OUTjson, fileConn); close(fileConn)
      if( fex == FALSE || (fex == TRUE && OVERWRITE == TRUE) )
      {
        sink(OUTjson.nam[i])
        cat(OUTjson)
        sink()
      }
    }

    if(VERBOSE == TRUE) print(OUTjson)
    names(OUTjson) <- OUTjson.nam[i]
    OUTjson
  })

return(params.out.jsons)
}
#########
# call:
#params.out.jsons <- create.jsons(basejson.sheet=basejson.sheet, params.out=params.out)
#
#head(params.out.jsons)
#tail(params.out.jsons)
## sanity check
#unique(sapply(params.out.jsons, length))


### CREATE COMPLETE RANDOM VALUES FROM SEQUENCE

# create complete random values based on samp.list ie. sample space
create.fullrandom <- function(basejson.sheet=NULL,
                              samp.list=NULL,
                              #Nsize=1,
                              each=1,
                              files.l=NULL,
                              seed=996677
                              )
{
  set.seed(seed)
  samp.list.l <- length(samp.list)
  basejson.sheet.n <- basejson.sheet[,"configname"]
  fullrandom.params <- lapply(seq_along(1:samp.list.l), function(j)
  {
    print(j)
    # bootstrap
    fullrandom.params[[j]] <- sample(samp.list[[j]], size=each, replace=TRUE)
  })
  
  # fix logical values
  logi.ids <- which( sapply(fullrandom.params, is.logical) == TRUE )
  logi.ids.l <- length(logi.ids)
  for(i in 1:logi.ids.l)
  {
    fullrandom.params[[logi.ids[i]]] <- tolower( fullrandom.params[[logi.ids[i]]] )
  }    
  names(fullrandom.params) <- basejson.sheet.n
  fullrandom.params

return(fullrandom.params)
}
#########
# call:
#fullrandom.sample <- create.fullrandom(basejson.sheet=basejson.sheet, samp.list=samp.list)
#fullrandom.sample.json <- create.jsons(basejson.sheet=basejson.sheet, params.out=fullrandom.sample)
#
#length(fullrandom.sample)
#length(fullrandom.sample.json)
#fullrandom.sample
#fullrandom.sample.n <- sort(sapply(fullrandom.sample.json,names))



### GET IMAGES and calc sample space, 
apply.ntscrs <- function(basejson.sheet=NULL,
                         params.out=NULL,
                         each=1,
                         startfolder=getwd(),
                         singleframe=TRUE,
                         smaterial="image",
                         pathtontscrs="",
                         sourcefolder="images",
                         outfolder="ntsc-rs-OUT",
                         OVERWRITE=TRUE,
                         fps=25,
                         encodingspeed=5,
                         bitdepth=8,
                         duration=c("00:05.00"),
                         compressionlevel=6,
                         quality=50,
                         DO=FALSE,
                         VERBOSE=TRUE,
                         seed=996677,
                         fullrandom=FALSE,
                         other="",
                         archive=FALSE,
                         valid.endings=NULL
                         )
{
  setwd(startfolder)
  ourfolder <- system("realpath .", intern=TRUE)

  if(is.null(valid.endings))
  {
    if(smaterial == "image")
    {
      valid.endings <- c("jpg","JPG","TIF","tif","BMP","bmp","PNG","png")
    } else if(smaterial == "video")
    {
      valid.endings <- c("avi","AVI","mp4","MP4","mkv","MKV","mpg","MPG","mpeg","MPEG","vob","VOB") # TODO extend
    }
  }
  
  sourcefolder.full <- paste(ourfolder,sourcefolder,sep="/")
  pattern <- paste("+.(?:",paste(valid.endings, collapse="|"),")",sep="") # regexpr
  
  # read file list
  files <- list.files(path=sourcefolder.full, pattern=pattern, all.files=TRUE, full.names=TRUE, rec=TRUE)
  files.l <- length(files)

  if(VERBOSE) print(files)

  # create samp.list
  samp.list <- create.seqs(basejson.sheet=basejson.sheet, seed=seed)
  
  # create params.out
  if(fullrandom == TRUE)
  {
    cat("\n'Full random mode' overrides everything.")
    params.out <- create.fullrandom(basejson.sheet=basejson.sheet,
                                 samp.list=samp.list,
                                 files.l=files.l,
                                 each=each,
                                 seed=seed
                                )
  } else if(is.null(params.out))
  {
    params.out <- create.samples(basejson.sheet=basejson.sheet,
                                 samp.list=samp.list,
                                 Nsize=files.l*each,
                                 seed=seed
                                )
  }
  
  # create jsons
  files.out.jsons <- create.jsons(basejson.sheet=basejson.sheet,
                                  params.out=params.out,
                                  each=each,
                                  fnamlist=gsub(pattern,"",files),
                                  WRITE=DO)

  files.out.jsons.fnams <- sapply(files.out.jsons,names)
  files.out.jsons
  sort(files.out.jsons.fnams)
  length(files.out.jsons)

  ### CREATE SVHS simulated images base on image file list

  # full oath out folder target images
  outfolder <- paste(ourfolder,outfolder,sep="/")
  # fix possible leading './' in the targetfolder
  outfolder <- gsub("./","",outfolder, fixed=TRUE)

  if(! dir.exists(outfolder)) dir.create(outfolder, rec=TRUE)
  if(OVERWRITE)
  {
    overwrite <- c("--overwrite")
    overwrite2 <- c("-y")
  } else
  {
    overwrite <- c("")
    overwrite2 <- c("")
  }

  if(smaterial == "image" && singleframe == FALSE || smaterial == "video")
  {
    if(smaterial == "image")
    {
      # video made from single image
      other <- paste("--duration", duration, "--fps", fps, other, sep=" ")
    } else if(smaterial == "video")
    {
      # video made from video
    }
    
    if(archive == TRUE)
    {
      o.codec <- "ffv1"
      o.fending <- ".mkv"
      other <- paste("--bit-depth", bitdepth, other, sep=" ")
    } else if(archive == FALSE)
    {
      o.codec <- "h264"
      o.fending <- ".mp4"
      other <- paste("--quality",quality, "--encoding-speed", encodingspeed, other, sep=" ")
    }

  } else if(smaterial == "image" && singleframe == TRUE)
  {
    o.codec <- "png"
    o.fending <- ".png"
    other <- paste("--single-frame-time 1", "--compression-level", compressionlevel, other, sep=" ")
  }
  # fix
  other <- paste(unique(unlist(strsplit(other," ", fixed=TRUE))), collapse=" ")
  
  files.each <- rep(files,each)
  files.each.l <- length(files.each)
  
  # for manual step-by-step
  f <- 1
  
  for(f in 1:files.each.l)
  {
    print(f)
    filetoprocess <- files.each[f]
    filetoprocess.jsonfnam <- files.out.jsons.fnams[f]
    targetfile <- paste(outfolder,gsub(".json",o.fending,basename(filetoprocess.jsonfnam),fixed=TRUE),sep="/")
    
    ntscrs.call <- paste(pathtontscrs," -i \"",filetoprocess,"\"", # input image
                         " -p \"",filetoprocess.jsonfnam,"\"", # associated json
                         " -o \"",targetfile,"\"",
                         " ",overwrite,
                         " --codec ",o.codec,
                         " ",other,
                         sep=""
                         )

    if(VERBOSE)
    {
      cat("\nfile to process: ",filetoprocess,"\n",sep="")
      print(ntscrs.call)
    }
  
    if(DO)
    {
      cat("\noverwrite = ",OVERWRITE,"\n",sep="")
      system(ntscrs.call, intern=TRUE)
    } else
    {
      cat("\ndry run only - do nothing.")
    }
  }

  ret <- list(files=files,
              files.each=files.each,
              params.out=params.out,
              files.out.jsons=files.out.jsons)  
return(ret)
}
#########
# call:
#apply.ntscrs(basejson.sheet=basejson.sheet,
#             params.out=params.out,
#             startfolder="/mnt/library/ntsc-rs",
#             sourcefolder="Gji_photos",
#             DO=TRUE,
#             VERBOSE=TRUE
#)

 
######################################## GET PRESETS FROM GITHUN REPO
svsh_sim_scrape_presets <- function(
    baseurl=NULL,
    file.exts=c("zip","json"),
    outputfolder=NULL,
    presets.fnam=presets.fnam,
    UNZIP=TRUE,
    forcedownload=FALSE
)
{
  
  # check number of subpages visible
  lynx.call <- paste("lynx --listonly --nonumbers --dump \"",baseurl,"\" | grep '?page='",sep="")
  pages.url <- unique(system(lynx.call, intern=TRUE))
  
  # use max. number and go there
  number.pages <- as.integer(sapply(lapply(strsplit(pages.url, "?page=", fixed=TRUE),rev),"[[",1))
  max.no.p.old <- max(number.pages)
  
  go.on <- FALSE  
  while(go.on == FALSE)
  {  
    # re-check number of sub pages visible
    lynx.call <- paste("lynx --listonly --nonumbers --dump \"",baseurl,"\" | grep '?page=",max.no.p.old,"'",sep="")
    pages.url <- unique(system(lynx.call, intern=TRUE))
    number.pages <- as.integer(sapply(lapply(strsplit(pages.url, "?page=", fixed=TRUE),rev),"[[",1))
    max.no.p.new <- max(number.pages)
    
    # if previous max = new max don't go further  
    if(max.no.p.new == max.no.p.old)
    {
      go.on <- TRUE
    } else
    {
      max.no.p.old <- max.no.p.new
    }
  }
  # print out max. number of pages to check
  cat("\nmax number of pages to check for preset discussions = ",max.no.p.new,"\n",sep="")
  
  # calc number of overview sub pages
  subpages.with.urls <- sapply(seq_along(1:max.no.p.new), function(x)
  {
    sub.baseurl <- paste(baseurl,"?page=",x,sep="")
    lynx.call <- paste("lynx --listonly --nonumbers --dump \"",sub.baseurl,"\"  | grep /discussions/",sep="")
    system(lynx.call, intern=TRUE)
  })
  
  # ignore warnings, we use brute force
  subpages.with.urls.sort <- sort(unique(unlist(subpages.with.urls)))
  subpages.with.no.int <- as.integer( sapply( lapply( strsplit( subpages.with.urls.sort, "/discussions/", fixed=TRUE), rev), "[[", 1) )
  subpages.with.urls.sort.DL <- subpages.with.urls.sort[ is.na(subpages.with.no.int) == FALSE]
  
  # crawl through all sub pages
  subpages.with.urls.sort.DL.l <- length(subpages.with.urls.sort.DL)
  # ignore warnings of pages without zip or json files
  links.to.DL <- sapply(seq_along(1:subpages.with.urls.sort.DL.l), function(x)
  {
    cat("\nno = ",x," (",subpages.with.urls.sort.DL.l,")",sep="")
    # check for http code ie. page exists
    # if page exists extract urls
    
    # filter for file extensions
    lynx.call <- paste("lynx --listonly --nonumbers --dump \"",subpages.with.urls.sort.DL[x],"\" | grep -E '",paste(file.exts,collapse="|"),"'",sep="")
    system(lynx.call, intern=TRUE)
  })  
  
  # remove empty pages without any of the relevant file extensions
  links.to.DL.l <- sapply(links.to.DL, length)
  links.to.DL <- links.to.DL[links.to.DL.l > 0]
  
  # extract actual filename from URL
  links.to.DL.fnams <- sapply(links.to.DL, basename)
  
  # make a list for each page and file(s) and format it as output for Readme.md ie. markdown
  
  # download all relevant files and move to outputfolder and here into subfolders based on (sub) url
  DL.list <- unlist(links.to.DL)
  DL.list.l <- length(DL.list)
  
  # create output folder
  if(! dir.exists(outputfolder)) dir.create(outputfolder)
  dummy <- sapply(seq_along(1:DL.list.l), function(x)
  {
    cat("\nno = ",x," (",DL.list.l,")\t name = ",DL.list[x],sep="")
    if(! file.exists(paste(outputfolder,"/",basename(DL.list[x]),sep="")) || forcedownload == TRUE )
    {
      wget.call <- paste("wget -c \"",DL.list[x],"\" -P ",outputfolder, sep="")
      system(wget.call, intern=TRUE)
    } else cat("\nfile '",basename(DL.list[x]),"' already exists - no download.\n",sep="")
  })
  
  # unzip files and look for json in it, otherwise give out an error message and remove zip
  if(UNZIP == TRUE)
  {
    # be aware we overwrite(!)
    unzip.call <- paste("unzip -o \"./",outputfolder,"/*.zip\" -d ./",outputfolder, sep="")  
    system(unzip.call, intern=TRUE)
  }
  
  # write out list for Readme.md
  dummy <- sapply(seq_along(1:DL.list.l), function(x)
  {
    paste("- [",basename(DL.list[x]),"](",DL.list[x],")", sep="")
  })
  fileConn <- file(paste(outputfolder,presets.fnam,sep="/"))
  writeLines(dummy, fileConn)
  close(fileConn)
  
  # maybe TODO
  # if there is a json, just remove the zip
  
  res <- list(subpages.with.urls.sort.DL=subpages.with.urls.sort.DL,
              DL.list=DL.list)
  
  return(res)
}
#########
# call:
#output <- svsh_sim_scrape_presets(
#           baseurl=baseurl,
#           file.exts=file.exts,
#           outputfolder=outputfolder,
#           presets.fnam=presets.fnam,
#           UNZIP=UNZIP,
#           forcedownload=forcedownload
#           )


########################################


