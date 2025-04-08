# URL
# https://github.com/abcnorio/aas-sim-mult

# (C) by abcnorio 2024-2025

# licence
# GPL v3
# https://www.gnu.org/licenses/gpl-3.0.en.html

# path?
getwd()

# get functions
source("aas_sim_helper.r")

########################################

# manual values
pathtontscrs <- "/usr/local/bin/ntsc-rs-cli"
basejson <- "example/aas_basejson_profile-nanda.xlsx"
startfolder <- "./"
outfolder <- "aas_ntsc-rs-OUT"
sourcefolder <- "image_source"

# add switch and choose between valid.endings unless given explicitly
# source material
valid.endings <- c("jpg","JPG","TIF","tif","BMP","bmp","PNG","png")
#valid.endings <- c("avi","AVI","mp4","MP4","mkv","MKV","mpg","MPG","mpeg","MPEG","vob","VOB")
singleframe <- TRUE

smaterial <- "image"
#smaterial <- "video"

DO <- FALSE  #!dry
OVERWRITE <- TRUE
each <- 1
compressionlevel <- 6
quality <- 50
encodingspeed <- 5
bitdepth <- 8
fps <- 25
duration <- "00:05.00"
archive <- FALSE
seed <- 996677
fullrandom <- FALSE
other <- "" 
VERBOSE <- TRUE


######### actual run

# open control sheet for randomness
basejson.sheet <- read.xlsx(basejson,
                            sheet="sorted",
                            skipEmptyRows=TRUE, 
                            check.names=FALSE,
                            skipEmptyCols=FALSE,
                            colNames=TRUE,
                            rowNames=FALSE
                            )

# calls
# we go from scratch and skip any params.out

basejson.sheet
each
startfolder
smaterial
pathtontscrs
sourcefolder
outfolder
OVERWRITE
fps
duration
compressionlevel
quality
DO
VERBOSE
seed
fullrandom
other
archive

# image based on image
apply.ntscrs(basejson.sheet=basejson.sheet,
             each=each,
             startfolder=startfolder,
             singleframe=TRUE,
             smaterial="image",
             pathtontscrs=pathtontscrs,
             sourcefolder=sourcefolder,
             outfolder=paste(outfolder,"_image-single",sep=""),
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration=duration,
             compressionlevel=compressionlevel,
             quality=quality,
             DO=TRUE,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=FALSE,
             other=other,
             archive=archive
             )

# image based on image
# create each = 10 images
apply.ntscrs(basejson.sheet=basejson.sheet,
             each=10,
             startfolder=startfolder,
             singleframe=TRUE,
             smaterial="image",
             pathtontscrs=pathtontscrs,
             sourcefolder=sourcefolder,
             outfolder=paste(outfolder,"_image-multi",sep=""),
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration=duration,
             compressionlevel=compressionlevel,
             quality=quality,
             DO=TRUE,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=FALSE,
             other=other,
             archive=archive
             )

# full random image
apply.ntscrs(basejson.sheet=basejson.sheet,
             each=each,
             startfolder=startfolder,
             singleframe=TRUE,
             smaterial="image",
             pathtontscrs=pathtontscrs,
             sourcefolder=sourcefolder,
             outfolder=paste(outfolder,"_image-rnd-single",sep=""),
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration=duration,
             compressionlevel=compressionlevel,
             quality=quality,
             DO=TRUE,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=TRUE,
             other=other,
             archive=archive
             )

# full random image
# create each = 10 images
apply.ntscrs(basejson.sheet=basejson.sheet,
             each=10,
             startfolder=startfolder,
             singleframe=TRUE,
             smaterial="image",
             pathtontscrs=pathtontscrs,
             sourcefolder=sourcefolder,
             outfolder=paste(outfolder,"_rnd-multi",sep=""),
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration=duration,
             compressionlevel=compressionlevel,
             quality=quality,
             DO=TRUE,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=TRUE,
             other=other,
             archive=archive
             )

# video based on image
apply.ntscrs(basejson.sheet=basejson.sheet,
             each=each,
             startfolder=startfolder,
             singleframe=FALSE,
             smaterial="image",
             pathtontscrs=pathtontscrs,
             sourcefolder=sourcefolder,
             outfolder=paste(outfolder,"_video-from-image-h254",sep=""),
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration=duration,
             compressionlevel=compressionlevel,
             quality=quality,
             DO=TRUE,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=FALSE,
             other=other,
             archive=FALSE
             )

# video based on image with archive codec ffv1
apply.ntscrs(basejson.sheet=basejson.sheet,
             each=each,
             startfolder=startfolder,
             singleframe=FALSE,
             smaterial="image",
             pathtontscrs=pathtontscrs,
             sourcefolder=sourcefolder,
             outfolder=paste(outfolder,"_video-from-image-ffv1",sep=""),
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration="00:10.00",
             compressionlevel=compressionlevel,
             quality=quality,
             DO=TRUE,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=FALSE,
             other=other,
             archive=TRUE
             )


# video based on video
smaterial <- "video"
sourcefolder <- "video_source"

# h264
apply.ntscrs(basejson.sheet=basejson.sheet,
             each=each,
             startfolder=startfolder,
             smaterial="video",
             pathtontscrs=pathtontscrs,
             sourcefolder="video_source",
             outfolder=paste(outfolder,"_video-from-video-264",sep=""),
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration=duration,
             compressionlevel=compressionlevel,
             quality=quality,
             DO=TRUE,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=FALSE,
             other=other,
             archive=FALSE
             )

# ffv1
apply.ntscrs(basejson.sheet=basejson.sheet,
             each=each,
             startfolder=startfolder,
             smaterial="video",
             pathtontscrs=pathtontscrs,
             sourcefolder="video_source",
             outfolder=paste(outfolder,"_video-from-video-ffv1",sep=""),
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration=duration,
             compressionlevel=compressionlevel,
             quality=quality,
             DO=TRUE,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=FALSE,
             other=other,
             archive=TRUE
             )

