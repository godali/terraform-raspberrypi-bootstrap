#!/bin/sh

CURRENT_INDEX=$1
HOST_IPS=($2)
HOST_NAMES=($3)

echo $CURRENT_INDEX
echo $HOST_IPS
echo $HOST_NAMES

arrayLength="${#HOST_IPS[@]}"
for ((i = 0 ; i < $arrayLength ; i++ ));
do
  if [ "$i" -ne "$CURRENT_INDEX"  ]
  then
    echo "${HOST_IPS[$i]} ${HOST_NAMES[$i]}" | sudo tee -a /etc/hosts
  fi
done
