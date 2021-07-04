#!/bin/bash

#Southside 
#July 2021

#script to PUT a series of standard size files to exercise the SAFENetwork  testnet
#inspired by @Vort of safenetworkforum.org
#See https://safenetforum.org/t/offline-fleming-testnet-v6-2-release-general-cli-support/35138/140?u=southside
#test (S, N, D):
#  write test parameters to log file (S, N, D)
#  loop N times:
#    generate random file of S KiB in size
#    start stopwatch
#    start upload process for generated file
#    stop stopwatch
#    append measured time to the end of log file
#   wait D milliseconds

#Arguments
FILESIZE=$1
ITERATIONS=$2
DELAY=$3

if [ $# -ne 3 ];
    then
    echo " You must supply arguments for testfile size, no of iterations and delay between test runs."
    echo " Example: random-files-upload-test.sh 100 10 30  will run the test with a filesize of 100k random bytes"
    echo " 15 iterations with a delay of 30 seconds between each run."
    exit 1
fi    

#Setup
DEST_DIR=/home/$USER/tmp/testnet-file-uploads-$(date +%Y%m%d_%H%M)
if [[ -d  $DEST_DIR ]]
    then
    rm -rf $DEST_DIR
fi
mkdir -p $DEST_DIR && cd $DEST_DIR


SAFE_VERSION=`safe -V`
NODE_VERSION=`safe node bin-version`
SAFE_COMMAND=put
#safe setup

#safe keys create --test-coins --for-cli --preload 10000

#logging setup
touch output.json
echo '{"testrun":"' `date`'",' \
    '"safe_version": "'$SAFE_VERSION'", "node_version":"'$NODE_VERSION'", "safe_command":"'$SAFE_COMMAND'",'\
     '"filesize":"'$FILESIZE'", "no_of_iterations": "'$ITERATIONS'", "delay": "'$DELAY'" , "data":[{' >>output.json
echo "======================================================================================================="
echo ""
echo "This test will upload random data of size "$FILESIZE" kb for a total of "$ITERATIONS" iterations with a delay of "$DELAY" seconds between iterations."

echo ""
echo "          output files will be written to " $DEST_DIR
echo ""
echo "          "$SAFE_VERSION
echo "          "$NODE_VERSION
#echo "         "$AUTH_VERSION
echo ""
echo ""

# ################ Next two lines commented out for compatabilty with sn_node0.7.n ###############

#OPEN_BALANCE=`safe keys balance --json|tail -n1|cut -f2 -d':'`
#echo "This account has a balance of "$OPEN_BALANCE

# #################################################################################################
echo ""
echo "==============================================================="

loop=1
while [ $loop -le $ITERATIONS ]
do
    echo '"iteration": "'$loop'", "elapsed time": " ' >> output.json
    dd if=/dev/urandom of=test.dat bs=1024 count=$FILESIZE >/dev/null
    /usr/bin/time -a -o output.json -f "\t%e" safe files $SAFE_COMMAND $DEST_DIR/test.dat > /dev/null 
    #/usr/bin/time -a -o out.json -f '"elapsed time":"\t%E","user time":"\t%U","system time": "\t%S"}' safe files $SAFE_COMMAND $DEST_DIR/$FILESIZE.dat > /dev/null 
    
    sleep $DELAY
    echo "sleeping for "$DELAY" seconds until the next iteration"
    rm  $DEST_DIR/test.dat
    ((loop++))           
done

 #CLOSE_BALANCE=`safe keys balance|tail -n1|cut -f2 -d':'`

echo '"}' >> output.json
echo  "    Test complete for " $ITERATIONS " runs of file size " $FILESIZE "kb with delay of " $DELAY " seconds between each run"
echo ""
echo "=========================================================================================================================="
exit 0
