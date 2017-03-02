#!/bin/sh

# usage is: validate_db_connection 2 50 pg_isready

SLEEP=$1
TRIES=$2
PG_ISREADY=$3

STATE=1

c=1

while [ $c -le $TRIES ]
do
  echo $c
  if [ $c -gt 1 ]
  then
    echo 'sleeping'
    sleep $SLEEP
  fi

  $PG_ISREADY
  STATE=$?

  if [ $STATE -eq 0 ]
  then
    exit 0
  fi
$c++
done

echo 'Unable to connect to edbas'

exit 1
