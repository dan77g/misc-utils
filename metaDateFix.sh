#!/bin/sh

##############################
# This tool will search a directory for AVI, MP4 or 3GP video files.
# It will use exiftool to see if each video has a "sane" creation date.
# If it doesn't, it will write (using ffmpeg) the creation date based on the static file format: video-YYYY-MM-DD-HH-MM-SS.*
##############################

usage()
{  
  echo "Usage: metaDateFix.sh -report|-fix <directory> "
  echo "  You need these tools installed: exiftool ffmpeg awk"
  echo "  -report:  changes nothing, just shows you the files which are broken"
  echo "  -fix:  fixes the broken files' metadata"
}

if [ $# -eq 0 ] ;
then
  usage
  exit 1
fi

arg="$1"

if [ "$arg" != "-report" ] && [ "$arg" != "-fix" ]
then
    usage
    exit 1
fi

if [ ! -d "$2" ]
then
  echo "======>  Directory: \"$2\" not found"
  usage
  exit 1
else 
    DIR=$2
fi

action=$arg
export action

########################    AWK LAND ######################################
awkfix='
BEGIN {
  missFiles=0
  miss[0] = ""
  brokenFiles=0
  broken[0] = ""
}
{
  file[""] = ""
  file["path"] = $0
  exout = "exiftool \"" file["path"] "\""
  while ((exout | getline line) > 0) {
    if (match(line, "^File Name")) {  # this should be in EVERY video file
      file["name"] = substr(line, 35)
    }
    if (match(line, "^File Type")) {
      file["type"] = substr(line, 35)
      if (match(file["type"], "AVI")) {
        file["ctr"] = "avi"
      } else if ( (match(file["type"], "MP4")) || (match(file["type"], "3GP")) ) {
        file["ctr"] = "mp4"
      }
    }
    if (match(line, "^File Modification")) {
      file["mod"] = substr(line, 35)
      file["modYr"] = substr(filemod,1,4)
      file["modMon"] = substr(filemod,5,2)
      file["modDay"] = substr(filemod,9,2)
      file["modHr"] = substr(filemod,12,2)
      file["modMin"] = substr(filemod,15,2)
      file["modSec"] = substr(filemod,18,2)
      file["modZon"] = substr(filemod,21,3)
    }
    if (match(line, "^Create Date")) {
      creStr = substr(line, 35)
      file["createYr"] = substr(creStr,1,4)
      file["createMon"] = substr(creStr,5,2)
      file["createDay"] = substr(creStr,9,2)
      file["createHr"] = substr(creStr,12,2)
      file["createMin"] = substr(creStr,15,2)
      file["createSec"] = substr(creStr,18,2)
    }
    if (match(line, "^Date/Time Orig")) {
      file["dateOrig"] = substr(line, 35)
    }
  }
  close(exout)
# Now deal with different potential file types. 
  print "-->Filename: " file["name"]
  print "FileType: " file["type"]
  print "FilePath: " file["path"]
  print "FileMod: " file["mod"]

  formatweird=0
  if (file["createYr"]) {  # we have a Create Date tag, probably mp4
    print "Create Yr: " file["createYr"]
    if (1980>file["createYr"] || file["createYr"]>2020) {  # this is where we fix stuff
      brokenFiles++
      broken[brokenFiles] = file["path"]
      print "METADATA BROKEN!"
      # use filename to get create date
      if (!match(file["name"], "^video*")) {
        print "Unknown filename format! Leaving alone ...."
        formatweird=1
      }

      if (!formatweird) {
        file["fnYr"] = substr(file["name"],7,4)
        file["fnMon"] = substr(file["name"],12,2)
        file["fnDay"] = substr(file["name"],15,2)
        file["fnHr"] = substr(file["name"],18,2)
        file["fnMin"] = substr(file["name"],21,2)
        file["fnSec"] = substr(file["name"],24,2)
        print "Filename Date --> " file["fnYr"] "-" file["fnMon"] "-"  file["fnDay"] " " file["fnHr"] ":" file["fnMin"] ":" file["fnSec"]
      }

      ## Fix ? Or just report?
      if ( (ENVIRON["action"] = "-fix") && (!formatweird) ) {
        newfile = file["path"] "_metafixd"
        # run FFMPEG to write tags, as exiftool cannot do it. involves writing a copy and then managing the original. Add "z" to timestamp to indicate local time (ie UTC time, no offset)
        # the next line is savagely ugly. The octal sequence "\47" is used instead of the single quote char, because that screws with the awk embedding in the script
        system("ffmpeg -i " file["path"] " -acodec copy -vcodec copy -timestamp \47" file["fnYr"] "-" file["fnMon"] "-" file["fnDay"] " " file["fnHr"] ":" file["fnMin"] ":" file["fnSec"] "z\47" " -f " file["ctr"] " " newfile " > /dev/null 2>&1" )
        print "New metadata written to file: " newfile
        system("mv " file["path"] " " file["path"] "_broken")
        print "Broken file saved to " file["path"] "_broken"
        system("mv " file["path"] "_metafixd " file["path"])
        print "Fixed file saved to " file["path"]
      } 
    } else {
      print "METADATA FINE"
    }
  } else if (file["dateOrig"]) {
    print "Date/Time Original: " file["dateOrig"]
    print "FILE OK"
  } else {
    missFiles++
    miss[missFiles] = file["path"]
    print "File has fallen through the gap. No date anywhere."
  }
  print "\n"
  delete file
}
END {
  for (i=1; i<=missFiles; i++)
    print "Missed up file: " i " " miss[i]
  for (i=1; i<=brokenFiles; i++)
    print "Broken File: " i " " broken[i]
  print "Total Files processed: " NR 
  print "Total Broken Files: " brokenFiles
}

'   # end of awk prog definition

find "$DIR" -iname '*.mp4' -o -iname '*.avi' -o -iname '*.3gp' | awk "$awkfix"

if [ "${action}" != '-report' ]
then
  tmpdir=$HOME/"tmp".`date +%s`
  mkdir $tmpdir
  find "$DIR" -iname '*_broken' -exec mv '{}' $tmpdir \;
  echo "All broken files moved to $tmpdir. Goodbye."
else 
  echo "Thanks. Bye."
fi

