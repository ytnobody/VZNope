export VZNOPE_ROOT=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
export VZNOPE=$VZNOPE_ROOT/bin/vzn
alias vzn="sudo $VZNOPE"
