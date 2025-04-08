#!/usr/bin/env Rscript

# URL
# https://github.com/abcnorio/aas-sim-mult

# (C) by abcnorio 2024-2025

# licence
# GPL v3
# https://www.gnu.org/licenses/gpl-3.0.en.html

# get helper scripts
source("aas_sim_helper.r")

# required libs - install them separately
libs <- c("openxlsx",
          "jsonlite",
          "EnvStats",
          "DescTools",
          "prevalence",
          "argparse")
none <- sapply(libs, suppressPackageStartupMessages(library), quietly=TRUE, warn.conflicts=FALSE, verbose=FALSE, character.only=TRUE )


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
duration <- c("00:05.00")
archive <- FALSE
seed <- 996677
fullrandom <- FALSE
other <- "" 
VERBOSE <- TRUE

params.out <- NULL


parser <- ArgumentParser()
# specify our desired options 
# by default ArgumentParser will add an help option 
parser$add_argument("-n", "--ntscrs", type="character", default=pathtontscrs,
                    help="path to ntsc-rs-cli binary [default: %(default)s]")

parser$add_argument("-b", "--basejson", type="character", default=basejson,
                    help="basejson xlsx sheet [default: %(default)s]")

parser$add_argument("-s", "--startfolder", type="character", default=startfolder,
                    help="set start folder as a base [default: %(default)s]")

parser$add_argument("-t", "--validendings", type="character", default=valid.endings,
                    help="valid file endings (image: png, jpg, ... | video: mp4, mkv, ...) [default: %(default)s]")
                    # c("avi","AVI","mp4","MP4","mkv","MKV","mpg","MPG","mpeg","MPEG","vob","VOB")

parser$add_argument("-j", "--NOsingleframe", action="store_true", default=(!singleframe),
                    help="create no single frame as png ie. video [default: %(default)s]")

parser$add_argument("-i", "--sourcefolder", type="character", default=sourcefolder,
                    help="relative path to source files [default: %(default)s]")

parser$add_argument("-m", "--smaterial", type="character", default=smaterial, # video
                    help="source material (images, videos) [default: %(default)s]")

parser$add_argument("-x", "--outfolder", type="character", default=outfolder,
                    help="relative path to output folder [default: %(default)s]")

parser$add_argument("-d", "--NOdryrun", action="store_true", default=(DO),
                    help="do not process anything / dry-run [default: %(default)s]")

parser$add_argument("-o", "--NOoverwrite", action="store_false", default=(!OVERWRITE),
                    help="do not overwrite existent files [default: %(default)s]")

parser$add_argument("-u", "--each", type="integer", default=each,
                    help="image variations per image [default: %(default)s]")

parser$add_argument("-c", "--compressionlevel", type="integer", default=compressionlevel,
                    help="compression level png (0=fast to 9=small) [default: %(default)s]")

parser$add_argument("-q", "--quality", type="integer", default=quality,
                    help="video quality level h264 (max. 50) [default: %(default)s]")

parser$add_argument("-e", "--encodingspeed", type="integer", default=encodingspeed,
                    help="encoding speed h264 (0-8) [default: %(default)s]")

parser$add_argument("-p", "--bitdepth", type="integer", default=bitdepth,
                    help="bit depth ffv1 codec h264 (8, 10, 12) [default: %(default)s]")

parser$add_argument("-f", "--fps", type="integer", default=fps,
                    help="frames per second for (intermediate) video (h264) [default: %(default)s]")

parser$add_argument("-l", "--length", type="character", default=duration,
                    help="length of intermediate video (h264) in MM:SS.MS [default: %(default)s]")

parser$add_argument("-a", "--archive", action="store_true", default=archive,
                    help="use ffv1 archive codec [default: %(default)s]")

parser$add_argument("-z", "--seed", type="integer", default=seed,
                    help="seed for randomness [default: %(default)s]")

parser$add_argument("-g", "--other", type="character", default=other,
                    help="options to passthrough to ntsc-rs-cli [default: %(default)s]")

parser$add_argument("-v", "--verbose", action="store_true", default=VERBOSE,
                    help="show more infos [default: %(default)s]")

parser$add_argument("-y", "--fullrandom", action="store_true", default=FALSE,
                    help="create full random json profile [default: %(default)s]")

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults
args <- parser$parse_args()
print(args)

# matching args and vars
pathtontscrs <- args$ntscrs
basejson <- args$basejson
startfolder <- args$startfolder
valid.endings <- args$validendings
singleframe <- (! args$NOsingleframe)
sourcefolder <- args$sourcefolder
smaterial <- args$smaterial
outfolder <- args$outfolder
DO <- args$NOdryrun
OVERWRITE <- args$NOoverwrite
each <- args$each
compressionlevel <- args$compressionlevel
quality <- args$quality
encodingspeed <- args$encodingspeed
bitdepth <- args$bitdepth
fps <- args$fps
duration <- args$length
archive <- args$archive
seed <- args$seed
other <- args$other
VERBOSE <- args$verbose
fullrandom <- args$fullrandom

# check
basejson
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
#
params.out

# actual call

# open control sheet for randomness
basejson <- read.xlsx(basejson,
                      sheet="sorted",
                      skipEmptyRows=TRUE, 
                      check.names=FALSE,
                      skipEmptyCols=FALSE,
                      colNames=TRUE,
                      rowNames=FALSE)


# image based on image
apply.ntscrs(basejson=basejson,
             params.out=params.out,
             each=each,
             startfolder=startfolder,
             singleframe=singleframe,
             smaterial=smaterial,
             pathtontscrs=pathtontscrs,
             sourcefolder=sourcefolder,
             outfolder=outfolder,
             OVERWRITE=OVERWRITE,
             fps=fps,
             duration=duration,
             compressionlevel=compressionlevel,
             encodingspeed=encodingspeed,
             bitdepth=bitdepth,
             quality=quality,
             DO=DO,
             VERBOSE=VERBOSE,
             seed=seed,
             fullrandom=fullrandom,
             other=other,
             archive=archive
             )


cat("\nDone.\n")
