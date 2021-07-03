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
INPUT_S=$1
INPUT_N=$2
INPUT_D=$3

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

#safe setup

safe keys create --test-coins --for-cli --preload 10000


echo "======================================================================================================="
echo ""
echo "This test will upload random data of size "$INPUT_S" kb for a total of "$INPUT_N" iterations with a delay of "$INPUT_D" seconds between iterations."

SAFE_VERSION=`safe -V`
NODE_VERSION=`safe node bin-version`
echo ""
echo "          output files will be written to " $DEST_DIR
echo ""
echo "          "$SAFE_VERSION
echo "          "$NODE_VERSION
#echo "         "$AUTH_VERSION
echo ""
echo ""
OPEN_BALANCE=`safe keys balance --json|tail -n1|cut -f2 -d':'`
echo "This account has a balance of "$OPEN_BALANCE
echo ""
echo "==============================================================="

loop=1
while [ $loop -le $INPUT_N ]
do
    dd if=/dev/urandom of=$loop_random$INPUT_S.dat bs=1024 count=$INPUT_S >/dev/null
    (/usr/bin/time -f "\t%e"  safe files put $DEST_DIR/$INPUT_S.dat) |& tee -a -i $INPUT_N-data.txt
    sleep $INPUT_D
    echo "sleeping for "$INPUT_D" seconds until the next iteration"
    rm  $DEST_DIR/$INPUT_S.dat
    ((loop++))           
done

 #CLOSE_BALANCE=`safe keys balance|tail -n1|cut -f2 -d':'`
echo  "    Test complete for " $INPUT_N " runs of file size " $INPUT_S "kb with delay of " $INPUT_D " seconds between each run"
echo ""
echo "=========================================================================================================================="
exit
