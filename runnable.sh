FOLDER=$1
CMDID=$2
RUN=$3
 
# echo "DEBUG: folder="$FOLDER " cmdId=" $CMDID "run=" $RUN



if [ -z "$1" ]; then
  echo "Runnable - scans README.md files for runnable commands"
  echo "Tag 1.0.0"
  echo "Get the latest from https://github.com/munafsheikh/runnable"
  echo "Usage: ./runnable.sh <folder> <id>"
  echo "       ./runnable.sh .                        -- Lists the runnable commands in . "
  echo "       ./runnable.sh tests                    -- Lists the runnable commands in tests "
  echo ""
  echo "  Generatng the doctest.sh file"
  echo "       ./runnable.sh tests  00             -- generates the test script file containing all commands for the purpose of testing documentation"
  echo "       ./runnable.sh tests  00  -r         -- runs the script file above."
else
  if [ -z "$CMDID" ]; then
    grep "$ " "$1"/README.md | awk -F '[$][ ]' '{ print $0 }'
  elif [ "$CMDID" = "00" ]; then
    echo "Generating... [" doctest.sh "]"
    grep "$ " $FOLDER/README.md | awk -F '[$][ ]' '{
      print ""
      print "echo ========================="
      print "echo " $0
      print "echo ------------------------"
      print $2
     }' > doctest.sh
    chmod 700 doctest.sh
    if [ -z "$RUN" ]; then
      if [ "$RUN" = "-r" ]; then
         echo "Executing... [" doctest.sh "]"
        ./doctest.sh
      fi
    fi
  else
    CMND=`grep "$ " "$1"/README.md | grep "$CMDID" | awk -F '[$][ ]' '{ print $2 }'`
    echo "Running... [" $FOLDER "]/[" $CMND "]"
    eval $CMND
  fi
fi

