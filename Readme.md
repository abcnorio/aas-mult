# (S)VHS simulation on a large number of images/ videos using ntsc-rs

## TOC


## Advance Organizer


## Goal

The `R` script provided allows to script [`ntsc-rs`](https://ntsc.rs) for an arbitrary number of iamges + videos based on a profile using the `.json` format of `ntsc-rs`. It introduces a certain amount of variation arranged by the user using a simple spreadsheet. In the spreadsheet the user can configure how the variation should take place for *every parameter* possibly by `ntsc-rs`.


## Use case

Simulating old analogue artifacts can be used for various purposes (images, videos):

- Fun
- Art
- Layout and professional graphics
- Fine-tuning of AI/ML models (creation of a training sample based on hi-res material)
	- upscale based on various model archs (e.g. [real-esrgan](https://github.com/xinntao/Real-ESRGAN)), suitable to be used with [neosr](https://github.com/neosr-project/neosr)
	- remove old analogue/ (S)VHS)/ betacam, ... artifacts from images or videos without upscaling

For AI/ML inference the [vsgan-tensorrt docker](https://github.com/styler00dollar/VSGAN-tensorrt-docker) engine is suitable. It uses docker and the installation is therefor pretty straightforward. It requires a huge GPU whereas `ntsc-rs-cli` works multithreaded with CPU.


## Overview

The software [`ntsc-rs`](https://ntsc.rs) written in [`Rust`](https://www.rust-lang.org) allows users to tweak videos and images to simulate old analogue TV, (S)VHS, betacam, and other associated artifacts. As a consequence the outcome looks like an old VHS tape with all visible and known artifacts in dependence to the degree previously configured. This work is based on [composite-video-simulator](https://github.com/joncampbell123/composite-video-simulator) and [ntscqt](https://github.com/JargeZ/ntscqt) which contains a short outline of typical artifacts along with screenshots. Amongst those are(dot crawl, ringing, chroma/ luma delay error aka color bleeding, rainbow effects, chrominance noise, head switching noise, long/ extended play, luminance noise, oversaturation - to name only the most predominant artifacts. An extensive overview about video artficats can be found on the [AV artifact atlas](http://www.avartifactatlas.com/tags.html#video).

`ntsc-rs` has a GUI and a cli version. Configurations are stored in `.json` files. On the discussion forum of the github repo one can find profiles for certain historical environments like VHS, SVHS, betacam, analogue TV and much more - carefully selected and developed by users. Further down you can find a selection of published profiles. All can be used for simulation.

So this setup allows to script the unattended generation of a large number of images or videos within a certain variation based on probabilities. The scripts were developed and tested under [Debian Linux](https://www.debian.org) (`bookworm`, 12.9).


## Implementation

The `R` script is separated into

- Creation of `.json` profile(s) based on statistics per image/ video by reading a base profile (spreadsheet, `.xlsx` format) which contains all statistical input
- Call of `ntsc-rs-cli` along with its usual parameters (see `ntsc-rs-cli --help` for more)

All options not covered by the `R` script call can be passthroughed via the '-g OPTIONS' or '--other OPTIONS' so `ntsc-rs-cli` can make use of them.


## Call

To call the `R` script via `Rscript` is straightforward with several options:

<details>

```bash
$ ./svhs_sim_bash.r --help
usage: ./svhs_sim_bash.r [-h] [-n NTSCRS]
                              [-b BASEJSON]
                              [-s STARTFOLDER]
                              [-t TYPE]
			      [-j]
                              [-i SOURCEFOLDER]
                              [-m SMATERIAL]
                              [-x TARGETFOLDER]
                              [-r TEMPFOLDER]
                              [-d]
                              [-o]
                              [-u EACH]
                              [-c COMPRESSIONLEVEL]
                              [-q QUALITY]
                              [-e ENCODINGSPEED]
                              [-p BITDEPTH]
                              [-f FPS]
                              [-l LENGTH]
                              [-a]
                              [-z SEED]
                              [-g OTHER]
                              [-v]

options:
  -h, --help            show this help message and exit
  -n NTSCRS, --ntscrs NTSCRS
                        path to ntsc-rs-cli binary [default:
                        /home/leo/library/DHAMMA/ntsc-rs/ntsc-rs/ntsc-
                        rs/target/release/ntsc-rs-cli]
  -b BASEJSON, --basejson BASEJSON
                        basejson xlsx sheet [default:
                        /home/leo/library/DHAMMA/ntsc-rs/ntsc-
                        rs/BASEjson_defaults_v3.xlsx]
  -s STARTFOLDER, --startfolder STARTFOLDER
                        set start folder as a base [default:
                        /home/leo/library/DHAMMA/ntsc-rs]
  -t TYPE, --type TYPE  valid file endings (image: png, jpg, ... | video: mp4,
                        mkv, ...) [default: ('jpg', 'JPG', 'TIF', 'tif',
                        'BMP', 'bmp', 'PNG', 'png')]
  -j, --single          create only single frame as png [default: True]
  -i SOURCEFOLDER, --sourcefolder SOURCEFOLDER
                        relative path to source files [default: Gji_photos]
  -m SMATERIAL, --smaterial SMATERIAL
                        source material (images, videos) [default: image]
  -x TARGETFOLDER, --targetfolder TARGETFOLDER
                        relative path to images [default:
                        /home/leo/library/DHAMMA/ntsc-rs/ntsc-rs-OUT]
  -r TEMPFOLDER, --tempfolder TEMPFOLDER
                        temporary folder for intermediate videos (can be a
                        ramdisk/ ramfs) [default: /tmp]
  -d, --DRXRUN          do not process anything / dry-run [default: False]
  -o, --overwriteNO     do not overwrite existent files [default: True]
  -u EACH, --each EACH  image variations per image [default: 1]
  -c COMPRESSIONLEVEL, --compressionlevel COMPRESSIONLEVEL
                        compression level png (0=fast to 9=small) [default: 6]
  -q QUALITY, --quality QUALITY
                        video quality level h264 (max. 50) [default: 50]
  -e ENCODINGSPEED, --encodingspeed ENCODINGSPEED
                        encoding speed h264 (0-8) [default: 5]
  -p BITDEPTH, --bitdepth BITDEPTH
                        bit depth ffv1 codec h264 (8, 10, 12) [default: 8]
  -f FPS, --fps FPS     frames per second for (intermediate) video (h264)
                        [default: 25]
  -l LENGTH, --length LENGTH
                        length of intermediate video (h264) in HH:MM:SS.MS
                        [default: 00:00:00.10]
  -a, --archive         use ffvq archive codec [default: False]
  -z SEED, --seed SEED  seed for randomness [default: 996677]
  -g OTHER, --other OTHER
                        options to passthrough to ntsc-rs-cli [default: ]
  -v, --verbose         show more infos [default: False]
```

</details>

The `R` script works with [`Rscript`](https://search.r-project.org/R/refmans/utils/html/Rscript.html) so it can be called from the terminal.

## Options

The explanations of the options of the `R` script are:

<details>

| Switch | Description | Default value | Notes |
| --- | --- | --- | --- |
| `-n`, `--ntscrs` | path to `ntsc-rs-cli` | `~/ntsc-rs/ntsc-rs-cli`|
| `-b`, `--basejson` | path to control sheet | `` |
| `-s`, `--startfolder` | base folder of image(s) or video(s) | `` |
| `-t`, `--type` | enabled file-endings for image/ video [image: jpg,JPG,tif,TIF,bmp,BMP,png,PNG , video: avi,AVI, mp4, MP4, mkv, MKV, vob, VOB | image file endings |
| `-j`, `--singleframeNO` | create only single frame as png | TRUE |
| `-i`, `--sourcefolder` | relative path to source files | `` |
| `-m`, `--smaterial` | source material (video, image) | image |
| `-x`, `--targetfolder` | relative path to output folder | `` |
| `-d`, `--dry` | do a dry-run | FALSE |
| `-o`, `--overwriteNO` | do not overwrite existent files | TRUE |
| `-u`, `--each` | number of variations per image/ video | 1 |
| `-c`, `--compressionlevel` | only png (0=fastest, 9=smallest) | 6 |
| `-q`, `--quality` | h264 quality level (max. 50) | 50 |
| `-e`, `--encodingspeed` | h264 encoding speed (0...8) | 5 |
| `-p`, `--bitdepth` | ffv1 bit depth (8, 10, 12) | 8 |
| `-f`, `--fps` | framerate | 25 |
| `-l`, `--length` | duration in MM:SS.MS | 00:05.00 |
| `-a`, `--archive` | use ffv1 archive codec | FALSE |
| `-z`, `--seed` | seed for randomness | 996677 |
| `-g`, `--other` | pass through further options to `ntsc-rs-cli` | |
| `-v`, `--verbose` | put out more infos | FALSE |

</details>


## Artifact profiles

The following profiles can be found on the [github repo]() of `ntsc-rs`. The credit goes to the selected users who developed and kindly published it:

- VHS [DL]()
- SVHS [DL]()
- betacam [DL]()
- analogue TV [DL]()
-
-
-
-
-

All those profiles can be used as a starting point for simulation.


## Statistics and handling the spreadsheet

The number of possibilities `ntsc-rs` offers is huge:

``

The following screenshot shows the sheet for the profile SVHS.

<details>
![sheet example](basejsonsheet.png)
</details>

The options to tweak the profile via sheet are below. For the statistical part there are different cases:

- logical (uniform distribution)
- linear (normal truncated distribution)
- nonlinear (beta distribution)
- random seed (random value)

The configuration names match the GUI version of `ntsc-rs`. Each `X` in the first colum marks whether the value can be changed to tweak the profile.

<details>

| Tweak | Column | Description | Explanation | Notes |
| --- | --- | --- | --- | --- |
| | `lfd` | original counter | sheet is ordered alphabetically, this is the original order |
| | `subref.lfd` | counter of sub categories | |
| | `lfdnam` | counter | alphabetic order |
| | `configname` | config name in `ntsc-rs` GUI | |
| X | `CH` | changeable | can a value be changed by the script? Allows to fix values incl. sub-categories. |
| | `development` | description of value development | |
| X | `LOW` | lower limit | |
| X | `UP` | upper limit | |
| (X) | `METHOD` | reference anchor used | mode |
| X | `SD` | standard deviation chosen | |
| X | `probs` | probabilities in case of logical values | |
| | `probcalc` | reference which type of distribution used | |
| | `DONE` | internal ie. ignore | |
| X | `anchorPR` | profile values | |
| X | `namePR` | profile name | |
| | `default` | default value | |
| | `min` | minimum value | |
| | `max` | maximum value | |
| | `type` | type of variable | |
| | `digits` | number of digits after comma | |
| | `categories` | possible values | |

</details>

## Tweaking profiles via spreadsheet

Relevant columns for the profile allow to change the statistical appearance of each of `ntsc-rs` configs. The following describes details as they appear in everyday work:

- `namePR` - just give your profile a name. This is only for your reference if you store more than one profile.
- `anchorPR` - put in the original values of your initial profile. This acts as an anchor for everything that comes afterwards. This column is used for every category (ie. row).
- `probcalc` - the `R` script is fixed at the moment to use one of those distribution functions. In theory one can put in every possible probability distribution to calculate statistical variance. This requires changes in the script.

We deal now in accordance with the type of variable.

Important is to understand the values in column `subref.lfd`. A value in this column refers to the value in column 'lfd` which means if for this main category the value in column `CH` is set to `FALSE`, then all those values associated with it cannot be changed. That's just a hierarchical system (see GUI). If the value is set to `TRUE`, all chances below that category are taken into account for statistical variation, otherwise not.

### Statistical background (short)

The idea is simple - the script works for each category by drawing a value from a probability space based on a random draw from a chosen probability distribution:

- analyis of `ntsc-rs` and its possible values
- create a complete probability space of all possible values
- put one's own probability distribution over the probability space and draw a random value from that (per category)

It is possible to use other probability distributions than the ones mentioned here. This requires some changes in the script that every R user with enough knowledge can do. Or one could add a general function to passthrough `R` code directly.

#### Categories (multiple, logical)

Categories can be either `multiple` (categories) or `logical` (two values possible). The handling is identical.

- `probs` - this puts weight on the possible values. Weights are re-calculated as probabilities by the script that sum up to 1.

#### Linear increase (integer, float)

Linear increasing values of type `integer` or `float` use the distribution outline in the column `probcalc` which is a truncated normal distribution. This allows - as the name says - to truncate the normal distribution which fits the needs here perfectly well.

- `SD` - standard deviation of the truncated normal distribution
- `SD` - if `EQUAL` is set and column `probcalc` contains `uniform`, a uniform distribution is applied. Then all values have the same probability 1/length(prob space).

#### Non-linear increase

Non-linear increasing values of type `percent` have a range between 0 and 1 and can be handled like probabilities. Their nature is non-linear and one has to use the GUI practically to understand the non-linear nature and its visual impact on the output. To introduce statistical variation a [beta](https://en.wikipedia.org/wiki/Beta_distribution) distribution offers a range of variation that fits, mostly because it is very flexible in the way it [looks](https://en.wikipedia.org/wiki/Beta_distribution#/media/File:PDF_of_the_Beta_distribution.gif) and it is easy to create the parameters of a beta distribution by getting some values.

- `LOW` - choose a lower bound
- `UP` - choose an uppper bound
- `METHOD` - only `mode` is possible at the moment, ie. the mode of the distributon is chosen.


## Files

| Filename | Description |
| --- | --- |
| [`svhs_basejson_empty.xlsx`]() | empty base `.json` sheet to use for statistical variation |
| [`svhs_basejson_svhs-example.xlsx`]() | example profile sheet with pre-defined variation for [SVHS]() |
| [`svhs_sim_helper.r`]() | contains all helper scripts |
| [`svhs_sim_bash.r`]() | [`Rscript`](https://search.r-project.org/R/refmans/utils/html/Rscript.html) call, suitable for `bash` under Linux, enable with `chmod +x svhs_sim_bash.r` |
| [`svhs_sim_manual.r`]() | manual running the `R` script under various scenarios (see comments in the script), should be used for Windows |


## `R` and its dependencies

`R` on Linux is best installed from the `[r-project](https://cloud.r-project.org/bin/linux)` page. There are instructions for various  distributions.
Under Linux packages are compiled and not downloaded as binaries. For that one needs a basic compilation environment and if `dev' packages are missing, the `R` package install routine usually give out error messages that contain helpful information which package is missing exactly. So installation is in most cases straightforward.
Normally under windows binaries are downloaded and installed from an `R` repo (mirror). Then no compilation is necessary.

The script requires several `R` packages: `openxlsx`, `jsonlite`, `EnvStats`, `DescTools`, `prevalence`, and `argparse`. The best is to install them on the terminal by just running `R`. Do not use a GUI like `rstudio` because although as an IDE it is great, for installation of `R` packages it is buggy which means it often breaks with strange errors whereas `R` on the terminal does not break during install. Within `R` the packages can be installed along with their dependencies typing

```R
packs <- c("openxlsx",
          "jsonlite",
          "EnvStats",
          "DescTools",
          "prevalence",
          "argparse")
sapply(packs, function(x) install.packages(x, dep=T))
```


## Usage and Procedure

A best practice can observe some guidelines:

- One should start to use the GUI to get comfortable with it. Nothing should be imagined if one can just try it out on real material. Only then switch to the cli version.
- Have a look on the links and on the github repo of `ntsc-rs` to explore the various pre-defined profiles to get an idea what they do to the material and what they do not.
- If one finds good anchor points ie. a suitable profile, save it as `.json` with a proper filename. Now anchor points are saved.
- Proceed to tweak the lower and upper bounds of each parameter in the GUI to get a feeling what is within a personal accepted tolerance space. For some parameters this can make a huge difference, for others less, and some more one may not want to change at all.
- Try the script for one or two images (videos) but with at least 10 or more variations. Compare the output for visible changes. If there are no real changes visible, go back to the sheet and increase e.g. the lower and upper bounds. If the changes are too much, go back to the GUI and try to udnerstand which parameters caused this and change them accordingly. Double-check whether all parameters that are allowed to be changed can actually be changed and vice versa.
- Take some time, this is nothing one can or should rush through.
- If the outputs and trials look good, try it on a larger bunch of images (videos). Videos naturally take much longer time. Before switching to video it makes sense to extract some frames from the video in question and use those as examples before applying profiles to the whole video. One can use `[ffmpeg](https://ffmpeg.org)` to extract frames or `[vlc player](https://www.videolan.org/vlc)`.


## Limitations

The `R` script was developed under Linux. In `theory` it works under windows as well, but may require some tweaks for the windows specific way to use paths in contrast to Linux. But as there are windows ports of `ntsc-rs` as well as all `R` packages should be available as binaries under windows, there is no real hindrance to try it out and change the `R` script to work under windows as well.

The `R` script allows to work on an arbitrary number of images + videos + different variations for each type. But it does not mix or allows to use multiple profiles, For that one can write a wrapper that calls the R script and just hands over the `.json` profile(s).

The probablity distributions are fixed (see explanations). One can change the script to allow for a selection of distributions to draw values from it. The `create.samples()` function is the one where to look at.


## DISCLAIMER

Although the tutorial was tested under varying conditions, we cannot rule out any possible errors. So we do not guarantee anything but to advice that users should use their common sense along with their intelligence and experience whether a result makes sense and is done properly or not. Thus, it is provided "as is". Use common sense to compare what is meant to do and you do and what is your computer setup (network, etc.).

NO WARRANTY of any kind is involved here. There is no guarantee that the software is free of error or consistent with any standards or even meets your requirements. Do not use the software or rely on it to solve problems if incorrect results may lead to hurting or injurying living beings of any kind or if it can lead to loss of property or any other possible damage to the world, living beings, non-living material or society as such. If you use the software in such a manner, you are on your own and it is your own risk.


## TODOs


## License

- R script [GPL v3](https://www.gnu.org/licenses/gpl-3.0.html)
- every other software cited has its own licence - see links below for details


## Cited software

- [`ntsc-rs`](https://ntsc.rs)
- [`R`](https://www.r-project.org)
- [`rstudio`](https://posit.co/downloads)
- [Debian Linux](https://www.debian.org)





######################

"-b", "--basejson", type="character", default="/home/leo/library/DHAMMA/ntsc-rs/ntsc-rs/BASEjson_defaults_v3.xlsx",
                    basejson xlsx sheet

"-s", "--startfolder", type="character", default=c("/home/leo/library/DHAMMA/ntsc-rs"),
                    set start folder as a base

"-t", "--type", type="character", default=c("jpg","JPG","TIF","tif","BMP","bmp","PNG","png"),
                    valid file endings (image: png, jpg, ... | video: mp4, mkv, ...) # c("mp4","MP4","mkv","MKV","mpg","MPG","mpeg","MPEG","vob","VOB")

"-j", "--single", action="store_false", default=TRUE,
                    create only a single frame as png [default: %(default)")

"-i", "--sourcefolder", type="character", default=c("Gji_photos"),
                    relative path to source files

"-m", "--smaterial", type="character", default="image", # video
                    source material (images, videos)

"-x", "--targetfolder", type="character", default=c("/home/leo/library/DHAMMA/ntsc-rs/ntsc-rs-OUT"),
                    relative path to images

"-r", "--tempfolder", type="character", default=c("/tmp"),
                    temporary folder for intermediate videos (can be a ramdisk/ ramfs)

"-d", "--dry", action="store_true", default=FALSE,
                    do not process anything / dry-run

"-o", "--overwriteNO", action="store_false", default=TRUE,
                    do not overwrite existent files

"-u", "--each", type="integer", default=1,
                    image variations per image

"-c", "--compressionlevel", type="integer", default=6,
                    compression level png (0=fast to 9=small)
                    
"-q", "--quality", type="integer", default=50,
                    video quality level h264 (max. 50)

"-e", "--encodingspeed", type="integer", default=5,
                    encoding speed h264 (0-8)

"-p", "--bitdepth", type="integer", default=8,
                    bit depth ffv1 codec h264 (8, 10, 12)

"-f", "--fps", type="integer", default=25,
                    frames per second for (intermediate) video (h264)

"-l", "--length", type="character", default=c("00:00:00.10"),
                    length of intermediate video (h264) in HH:MM:SS.MS

"-a", "--archive", action="store_true", default=FALSE,
                    use ffv1 archive codec (lossless) instead of h264 for video [default: %(default)")

"-z", "--seed", type="integer", default=996677,
                    seed for randomness

"-O", "--other", type="character", default=c(""),
                    other options - passthrough! - pls see 'ntsc-rs-cli --help' [default: %(default)")

"-v", "--verbose", action="store_true", default=FALSE,
                    show more infos
