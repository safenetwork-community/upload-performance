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

#TODO   Improve logging, accept input parameters

#Setup
DEST_DIR=/home/$USER/tmp/testnet-file-uploads-$(date +%Y%m%d_%H%M)
if [[ -d  $DEST_DIR ]]
    then
    rm -rf $DEST_DIR
fi
mkdir -p $DEST_DIR && cd $DEST_DIR

# Make sure we don't run out of coins on a long test run
safe keys create --test-coins --for-cli --preload 10000

#get parameters
echo "======================================================================================================="
echo ""
echo "This test will upload random data of size S a total of N times with a delay of D between each test run"
read -p "What size of file do you want to test with?   Units in kb " INPUT_S
echo " The test file will be "$INPUT_S" kb."
echo ""
echo ""
# TODO    input validation, default size in, no input case
echo ""
echo ""
read -p "How many times should we repeat this test?    " INPUT_N
echo "This test will be repeated "$INPUT_N" times."
# TODO    input validation
#period of time to wait before repeating the test runs
echo ""
echo ""
read -p "How many seconds should we wait between test runs?     " INPUT_D
echo "This test will be repeated after a delay of "$INPUT_D" seconds."
# TODO    input validation

SAFE_VERSION=`safe -V`
NODE_VERSION=`safe node bin-version`


echo "========  SAFE Network testnet PUT files test  ====================================================="
echo ""
echo "          output files will be written to " $DEST_DIR
echo ""
echo "          "$SAFE_VERSION
echo "          "$NODE_VERSION
#echo "         "$AUTH_VERSION
echo ""
echo ""

echo "Before starting tests, check there is sufficient balance in the account to be used"
OPEN_BALANCE=`safe keys balance --json|tail -n1|cut -f2 -d':'`
echo ""
echo "This account has a balance of "$OPEN_BALANCE
echo ""
echo "==============================================================="

loop=1
while [ $loop -le $INPUT_N ]
do
    dd if=/dev/urandom of=$loop_random$INPUT_S.dat bs=1024 count=$INPUT_S > /dev/null
    time safe files put $DEST_DIR/$INPUT_S.dat |tee -a -i $INPUT_N-data.txt
    sleep $INPUT_D
    echo "sleeping for "$INPUT_D" seconds"
    rm -v $DEST_DIR/$INPUT_S.dat
    ((loop++))           
done

CLOSE_BALANCE=`safe keys balance|tail -n1|cut -f2 -d':'`
echo  "    Test complete for " $INPUT_N " runs of file size " $INPUT_S "kb with delay of " $INPUT_D " seconds between each run"
echo ""
echo "=========================================================================================================================="
exit
