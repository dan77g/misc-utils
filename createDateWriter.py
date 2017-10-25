#!/usr/bin/python3

########################################################
## XXXXX.py -- written by danryu

#########################################################

import sys
import magic
import glob
import os
import pyexifinfo as p
import json
import piexif

walk_dir = sys.argv[1]
rename = False
FTYPES = {
    'JPEG' : 'jpg',
    'GIF' : 'gif',
    'PNG' : 'png',
    'Adobe' : 'psd'
}

if len(sys.argv) > 2:
    if sys.argv[2] == "-rename":
        rename = True
        print ("Rename option enabled. Will rename files.")

def get_file_type(fname):
    ftype = magic.from_file(fname).split()[0]
    return FTYPES.get(ftype)

for filename in glob.iglob(walk_dir + "/**/*", recursive=True):
    if not (os.path.isdir(filename)):
        print (">>>>>>>>>>>>>>>>>>>>>>>>>>>>")

        ## Run suffix check and filetype check, rename if so wished
        print (">>> FILE: ", filename)
        magik = magic.from_file(filename)
        print (">>> FILE MAGIC: ", magik)
        filetype = get_file_type(filename)
        print (">>> CORRECT FILE SUFFIX: ", filetype)
        if filetype is not None and not filename.lower().endswith(filetype): # case insensitive
            print("BLIMEY, THERE'S NO SUFFIX.....")
            if (rename):
                print("ADDING SUFFIX TO FILE!")
                os.rename(filename, filename + "." + filetype)

        # ## Get ALL the metadata from the file
        data = p.get_json(filename)
        print( json.dumps(data, sort_keys=True,
                            indent=4, separators=(',', ': ')) )
        #
        # ## DUMP again with piexif
        # exif_dict = piexif.load(filename)
        # for ifd in ("0th", "Exif", "GPS", "1st"):
        #     for tag in exif_dict[ifd]:
        #         print(piexif.TAGS[ifd][tag]["name"], exif_dict[ifd][tag])

        # Reading any of:
        # VIDEO: 3ga, 3gp, avi, dv, flv, m4v, mkv, mov, mp4, mpg, webm, wmv
        # AUDIO: amr, m4a, mp3
        # IMAGE: bmp, gif, jpg, png, pnm, tif

        # do roughly as in https://github.com/danryu/misc-utils/blob/master/metaDateFix.sh

        # 1)
        # run exiftool on file
        # Parse:
        # "^File Modification"
        # "^Create Date"
        # "^Date/Time Orig"
        # others??

        # 2) # if no good date tag - qu: which to test? need to look at examples read-only first
        # Take Date Options:
        # a) take Earliest  Date of all in exifdata ?
        # b) takeDateFromFile()  # this should test for eg 2004-01-04..08-23:21 etc, heavily fuzzy
        # c) take date from input arg ?

        # 3)
        # if we want to write:
        # ifImageFile:
        #   writeDateWithExifTool()
        # ifVideoFile:
        #   writeDateWithFFmpeg()






        print ("\n")
