#!/usr/bin/bash

get_top_cpu_json()
{
ps -eo pid=,comm=,state=,%cpu=,%mem= --sort=-%cpu |  awk '
$2 != "ps" {
count++
data[count]= sprintf("{\"pid\": %s, \"cmd\": \"%s\", \"state\": \"%s\", \"cpu\": %s, \"mem\": %s}",$1, $2, $3, $4, $5)
    }
 END {
    for (i=1; i<=count && i<=5; i++) {
        printf "%s", data[i]
        if (i < 5 && i < count) printf ",\n"
    }
}'
}

get_top_mem_json()
{
ps -eo pid=,comm=,state=,%cpu=,%mem=  --sort=-%mem | awk '
 $2 != "ps" {
 count++
      data[count]= sprintf( "{\"pid\": %s, \"cmd\": \"%s\", \"state\": \"%s\", \"cpu\": %s, \"mem\": %s}",$1, $2, $3, $4, $5)
}
 END {
    for (i=1; i<=count && i<=5; i++) {
        printf "%s", data[i]
        if (i < 5 && i < count) printf ",\n"
    }
}'
}


main_json() {
    echo "{"
    echo "\"top_cpu\": ["
    get_top_cpu_json
    echo "],"

    echo "\"top_mem\": ["
    get_top_mem_json
    echo "]"
    echo "}"
}


main_cli()
{
echo " =================================================="
echo  "                    PROCESS MONITOR               "
echo " ================================================="

echo ""
echo "-----------------------"
echo "[TOP CPU PROCESSES] "
echo '-----------------------'
ps -eo pid=,comm=,state=,%cpu=,%mem= --sort=-%cpu | head -n 6

echo ""
echo "--------------------------"
echo "[TOP MEMORY PROCESSES]"
echo '-------------------------'
ps -eo pid=,comm=,state=,%cpu=,%mem= --sort=-%mem | head -n 6


echo ""
echo "[PROCESS STATES]: "
echo '-----------------------'
ps -eo pid=,comm=,state=,%cpu=,%mem= --sort=-%cpu | grep -v ps |  head -n 11

echo ""
echo "[ZOMBIES PROCESS]"
echo "-----------------------"

zombies=$(ps -eo pid=,comm=,state= | awk '$3 ~ /Z/')

if [ -z "$zombies" ];then
echo "none detected"
else 
echo "$zombies"
fi
echo "========================================="
echo  "      PROCESS MONITOR COMPLETE          "
echo "========================================="
}

# control flow
if [ "$1" == "--json" ]; then
main_json
else
main_cli
fi
