. ./tests/config.sh

echo "Run all tests"

fails=0
green="\033[32m"
red="\033[31m"
reset="\033[0m"
export PGUSER=openbill-test

for test in ./tests/test*.sh
do
  echo -e "\nRun test: $test"
  if $test && echo "TEST PASSED" && ./tests/assert_balance.sh && echo "BALANCE PASSED"; then
    echo -e "${green}CONTROL PASSED."
    echo -e $reset
  else
    fails=`echo 1 + $fails | bc`
    echo -e "${red}FAIL! ($fails)"
    echo -e $reset
  fi
done

if [ $fails == 0 ]; then
  echo -e "${green}ALL DONE!"
  echo -e $reset
else
  echo -e "\n${red}FAIL: $fails tests are failed"
  echo -e $reset
  exit 1
fi
