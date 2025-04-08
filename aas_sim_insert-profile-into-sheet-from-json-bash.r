#!/usr/bin/env Rscript

# URL
# https://github.com/abcnorio/aas-sim-mult

# (C) by abcnorio 2024-2025

# licence
# GPL v3
# https://www.gnu.org/licenses/gpl-3.0.en.html

# required libs - install them separately
libs <- c("argparse","openxlsx","jsonlite")

# https://cran.r-project.org/web/packages/argparse/vignettes/argparse.html
none <- lapply(libs, suppressPackageStartupMessages(library), quietly=TRUE, warn.conflicts=FALSE, verbose=FALSE, character.only=TRUE )
#invisible(lapply(libs, library, character.only=TRUE))

# manual
basejson.empty.nam <- c("aas_basejson_empty_extended.xlsx")
# default
# basejson.profile <- c("preset.json")
basejson.profile <- c("nanda_initial.json")
basejson.filled.nam <- c("aas_basejson_profile-nanda-initial.xlsx")
profile.nam <- c("nanda")
ignore <- FALSE

parser <- ArgumentParser()
# specify our desired options 
# by default ArgumentParser will add an help option 
parser$add_argument("-b", "--basesheet", type="character", default=basejson.empty.nam,
                    help="empty sheet name to fill presets/ profile in [default: %(default)s]")

parser$add_argument("-j", "--basejsonprofile", type="character", default=basejson.profile,
                    help="name of json profile file [default: %(default)s]")

parser$add_argument("-o", "--output", type="character", default=basejson.filled.nam,
                    help="output filename for sheet and tab limited table [default: %(default)s]")

parser$add_argument("-p", "--profile", type="character", default=profile.nam,
                    help="profile name [default: %(default)s]")

parser$add_argument("-i", "--ignore", action="store_true", default=ignore,
                    help="ignore if there is a mismatch of json profile and empty sheet [default: %(default)s]")

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults
args <- parser$parse_args()
print(args)

# matching args and vars
basejson.empty.nam <- args$basehseet
basejson.profile <- args$basejsonprofile
basejson.filled.nam <- args$output
profile.nam <- args$profile
ignore <- args$ignore

# open control sheet for randomness
basejson.sheet.empty <- read.xlsx(basejson.empty.nam,
                            sheet="sorted",
                            skipEmptyRows=TRUE, 
                            check.names=FALSE,
                            skipEmptyCols=FALSE,
                            colNames=TRUE,
                            rowNames=FALSE)
# get names for json
config.nams <- basejson.sheet.empty$configname

# read preset/ profile in json
profile.json <- read_json(basejson.profile)
profile.json.nams <- names(profile.json)

# manual check
# profile.json

# compare config names sheet vs json
# note:
# the empty sheet has more entries than the json
#
# but the json names MUST be 100% present in the config

# COMP 1
# json config within empty sheet
comp.json.vs.confignams <- profile.json.nams %in% config.nams

# COMP 2
# empty sheet within json config
comp.confignams.vs.json <- config.nams %in% profile.json.nams

cat("Comparison sheet config names vs. json names:\n",sep="")
print(comp.json.vs.confignams)

cat("\nComparison json names vs. sheet config names:\n",sep="")
print(comp.json.vs.confignams)

cat(config.nams[comp.confignams.vs.json == FALSE],sep="\n")
cat(profile.json.nams[comp.json.vs.confignams == FALSE],sep="\n")

# NOTE
# print(profile.json.nams[comp.json.vs.confignams == FALSE])
# new with v0.9.2
# [1] "scale_settings"        "scale_with_video_size" "vertical_scale"     

# print out discrepancies
if( sum((!comp.json.vs.confignams)+0) != 0 )
{
  cat("\nThe following names of json are *not present* in the empty sheet config:\n",sep="")
  print(profile.json.nams[comp.json.vs.confignams == FALSE])
  # check whether to stop the script
  if(ignore == FALSE)
  {
    stop("The json names do not match config names - please check.")
  } else
  {
    cat("\nWork wll continue, because ignore == ",ignore,".\nWait for 5 sec before continue.",sep="")
    z <- 0
    while(z != 5)
    {
      Sys.sleep(1)
      cat(".")
      z <- z + 1 
    }
  }
}

# write in anchorPR profile
profile.json.nams.l <- length(profile.json.nams)
# we clone the sheet and just replace important parts
basejson.sheet.filled <- basejson.sheet.empty

for(x in 1:profile.json.nams.l)
{
  # get ID to replace
  replace.ID <- which( profile.json.nams[x] == basejson.sheet.empty[,"configname"] )
  # check
  #basejson.sheet.filled[replace.ID,"configname"]
  # replace to create an anchor based on the profile
  basejson.sheet.filled[replace.ID,"anchorPR"] <- profile.json[[x]]
}

# change profile name
basejson.sheet.filled[,"namePR"] <- profile.nam

# write out sheet
wb <- createWorkbook()
addWorksheet(wb=wb, sheetName = "preset")
writeData(wb, sheet=1, basejson.sheet.filled)
saveWorkbook(wb=wb, file=basejson.filled.nam, overwrite=TRUE)

# write our tab limited file
write.table(x=basejson.sheet.filled,
            file=gsub(".xlsx",".tab",basejson.filled.nam, fixed=TRUE),
            sep="\t",
            col.names=TRUE,
            na="")

cat("\nThe script went successful. Sheet created as \n\n'",basejson.filled.nam,"'.\n\nThe table has the same name with ending '.tab'.\n",sep="")

 