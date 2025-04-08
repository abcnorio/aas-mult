#!/usr/bin/env Rscript

# URL
# https://github.com/abcnorio/aas-sim-mult

# (C) by abcnorio 2024-2025

# licence
# GPL v3
# https://www.gnu.org/licenses/gpl-3.0.en.html

# get helper functions
source("svhs_sim_helper.r")

# required libs - install them separately
libs <- c("argparse")
none <- sapply(libs, suppressPackageStartupMessages(library), quietly=TRUE, warn.conflicts=FALSE, verbose=FALSE, character.only=TRUE )

# manual
baseurl <- c("https://github.com/valadaptive/ntsc-rs/discussions/categories/presets")
file.exts <- c("zip","json")
outputfolder <- c("ntsc-rs_sim_presets")
presets.fnam <- paste(format(Sys.time(), "%Y-%M-%d"),"_ntsc-rs_presets-from-repo.md",sep="")
UNZIP <- TRUE
forcedownload <- FALSE


parser <- ArgumentParser()
# specify our desired options 
# by default ArgumentParser will add an help option 
parser$add_argument("-b", "--baseurl", type="character", default=baseurl,
                    help="base url for presets [default: %(default)s]")

parser$add_argument("-f", "--fileextensions", type="character", default=file.exts,
                    help="valid file extensions for presets [default: %(default)s]")

parser$add_argument("-o", "--outputfolder", type="character", default=outputfolder,
                    help="relative path to output folder [default: %(default)s]")

parser$add_argument("-p", "--presetsfilename", type="character", default=presets.fnam,
                    help="relative path to output folder [default: %(default)s]")

parser$add_argument("-u", "--unzip", action="store_false", default=UNZIP,
                    help="unzip downloaded zip files to output folder [default: %(default)s]")

parser$add_argument("-x", "--forcedownload", action="store_true", default=forcedownload,
                    help="force download even if preset file exists [default: %(default)s]") 

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults
args <- parser$parse_args()
print(args)

# matching args and vars
baseurl <- args$baseurl
file.exts <- args$fileextensions
outputfolder <- args$outputfolder
presets.fnam <- args$presetsfilename
UNZIP < args$UNZIP
forcedownload <- args$forcedownload

# get presets
output <- svsh_sim_scrape_presets(
                    baseurl=baseurl,
                    file.exts=file.exts,
                    outputfolder=outputfolder,
                    presets.fnam=presets.fnam,
                    UNZIP=UNZIP,
                    forcedownload=forcedownload
                    )

cat("\nThe script went successful.\nIgnore warnings - mostly this means on those pages\nwere no valid file extensions (",paste(file.exts,collapse=","),") to download.\n",sep="")


