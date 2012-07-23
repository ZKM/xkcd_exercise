#!/bin/bash

add_items() {
  ITEMTOTAL=0
  local INDEX=-1
  local x=0
  local y=${#VAR_INDEX[@]}
  while [ $x -lt $y ]
  do
    local x=$(($x + 1))
    local INDEX=$((${INDEX} + 1))
    ITEMTOTAL=`echo "${ITEMTOTAL} + ${VAR_INDEX[INDEX]} * ${VAR_DATA[INDEX]}" | bc`
  done
}

add_index() {
  INDEXTOTAL=0
  local INDEX=-1
  local x=0
  local y=${#VAR_INDEX[@]}
  while [ $x -lt $y ]
  do
    local x=$(($x + 1))
    local INDEX=$((${INDEX} + 1))
    INDEXTOTAL=`echo "${INDEXTOTAL} + ${VAR_INDEX[INDEX]}" | bc`
  done
}

display_index() {
  local INDEX=-1
  local x=0
  while [ $x -lt ${#VAR_INDEX[@]} ]
  do
    local x=$(($x + 1))
    local INDEX=$((${INDEX} + 1))
    echo "  # of ${VAR_NAME[INDEX]} = ${VAR_INDEX[INDEX]}"
  done
}

do_special_count() {
  SPECIAL=0
  local x=-1
  while [ $x -lt ${MAX_INDEX} ]
  do
    local x=$(($x + 1))
    if [ ${VAR_INDEX[x]} -eq 0 ]; then
      SPECIAL=$((${SPECIAL} + 1))
    else
      break
    fi
  done
  local x=-1
  while [ $x -lt ${SPECIAL} ]
  do
    local x=$(($x + 1))
    VAR_INDEX[x]=${VAR_MAX[x]}
  done
}

find_max() {
  local x=0
  while [ 1 ]
  do
    local x=$(($x + 1))
    local y=`echo "$x * ${LOWEST_PRICED_ITEM} + ${VAR_DATA[$1]}" | bc`
    local z=`echo "$y > ${TOTAL}" | bc`
    if [ $z -eq 1 ]; then
      break
    fi
  done
  VAR_MAX[$1]=$x
}

swap() {
  local temp1=${VAR_NAME[$1]}
  local temp2=${VAR_DATA[$1]}
  VAR_NAME[$1]=${VAR_NAME[$2]}
  VAR_DATA[$1]=${VAR_DATA[$2]}
  VAR_NAME[$2]=$temp1
  VAR_DATA[$2]=$temp2
  return
}

INDEX=-1
LOWEST_PRICED_ITEM=0
x=0
while read LINE
do
  x=$(($x + 1))
  if [ $x -eq 1 ]; then
    TOTAL=`echo "${LINE}" | awk -F '$' '{ print $2 }'`
  fi
  if [ $x -ne 1 ]; then
    INDEX=$((${INDEX} + 1))
    y=`echo "${LINE}" | awk -F ',' '{ print $1 }'`
    z=`echo "${LINE}" | awk -F ',' '{ print $2 }' | awk -F '$' '{ print $2 }'`
    VAR_NAME[INDEX]="$y"
    VAR_DATA[INDEX]="$z"
    l=`echo "${LOWEST_PRICED_ITEM} == 0" | bc`
    if [ ${l} -eq 1 ]; then
      LOWEST_PRICED_ITEM="$z"
    fi
    l=`echo "${VAR_DATA[INDEX]} < ${LOWEST_PRICED_ITEM}" | bc`
    if [ ${l} -eq 1 ]; then
      LOWEST_PRICED_ITEM="$z"
    fi
  fi
done < np-complete.xkcd.menu

NUMBER_OF_ELEMENTS=${#VAR_DATA[@]}
x=$((${NUMBER_OF_ELEMENTS} - 1))
while [ $x -gt 0 ]
do
  INDEX1=0
  INDEX2=1

  while [ ${INDEX1} -lt $x ]
  do
    y=`echo "${VAR_DATA[$INDEX1]} > ${VAR_DATA[INDEX2]}" | bc`
    if [ $y -eq 1 ]; then
      swap ${INDEX1} ${INDEX2}
    fi
    INDEX1=$((${INDEX1} + 1))
    INDEX2=$((${INDEX2} + 1))
  done

  x=$(($x - 1))
done

echo "Total = ${TOTAL}"
echo "Lowest Price = ${LOWEST_PRICED_ITEM}"
echo "Items:"
INDEX=-1
x=0
y=${#VAR_DATA[@]}
while [ $x -lt $y ]
do
  x=$(($x + 1))
  INDEX=$((${INDEX} + 1))
  echo "  ${VAR_NAME[INDEX]} = ${VAR_DATA[INDEX]}"
done

echo "Max number of per item:"
INDEX=-1
x=0
y=${#VAR_DATA[@]}
while [ $x -lt $y ]
do
  x=$(($x + 1))
  INDEX=$((${INDEX} + 1))
  find_max "${INDEX}"
  echo "  ${VAR_NAME[INDEX]} = ${VAR_MAX[INDEX]}"
done

INDEX=-1
x=0
y=${#VAR_DATA[@]}
z=1
while [ $x -lt $y ]
do
  x=$(($x + 1))
  INDEX=$((${INDEX} + 1))
  z=`echo "$z * ${VAR_MAX[INDEX]}" | bc`
done
echo "Max number of combinations: $z"

INDEX=-1
x=0
while [ $x -lt ${#VAR_DATA[@]} ]
do
  x=$(($x + 1))
  INDEX=$((${INDEX} + 1))
  VAR_INDEX[INDEX]=0
done

COMBINATIONS=0
COUNT_INDEX=0
MATCHES=0
MAX_INDEX=0

while [ 1 ]
do
  VAR_INDEX[0]=$((${VAR_INDEX[0]} + 1))
  if [ ${VAR_INDEX[0]} -gt ${VAR_MAX[0]} ]; then
    VAR_INDEX[0]=0
    COUNT_INDEX=1

    while [ ${COUNT_INDEX} -lt ${#VAR_INDEX[@]} ]
    do
      VAR_INDEX[COUNT_INDEX]=$((${VAR_INDEX[COUNT_INDEX]} + 1))
      t=$((${COUNT_INDEX} - 1))
      if [ ${MAX_INDEX} -eq $t ]; then
        MAX_INDEX=${COUNT_INDEX}
      fi
      if [ ${VAR_INDEX[COUNT_INDEX]} -gt ${VAR_MAX[COUNT_INDEX]} ]; then
        VAR_INDEX[COUNT_INDEX]=0
        COUNT_INDEX=$((${COUNT_INDEX} + 1))
      else
        break
      fi
    done
  fi
  if [ ${COUNT_INDEX} -eq ${#VAR_INDEX[@]} ]; then
    break
  fi
  COMBINATIONS=$((${COMBINATIONS} + 1))
  #echo ${VAR_INDEX[0]} ${VAR_INDEX[1]} ${VAR_INDEX[2]} ${VAR_INDEX[3]} ${VAR_INDEX[4]} ${VAR_INDEX[5]} ${VAR_INDEX[6]} combinations: ${COMBINATIONS} matches: ${MATCHES}
  add_items
  add_index
  t=`echo "${ITEMTOTAL} == ${TOTAL}" | bc`
  if [ $t -eq 1 ]; then
    MATCHES=$((${MATCHES} + 1))
    echo "Solution: ${MATCHES}"
    display_index
  fi
  if [ ${INDEXTOTAL} -ge ${VAR_MAX[MAX_INDEX]} ]; then
    do_special_count
  else
    t=`echo "${ITEMTOTAL} > ${TOTAL}" | bc`
    if [ $t -eq 1 ]; then
      do_special_count
    fi
  fi
done

echo "Total number of solutions: ${MATCHES} out of ${COMBINATIONS} possibilities."
