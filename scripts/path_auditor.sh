#!/usr/bin/bash

# function no.1 
collect_path_issues()
{
AUDIT_PATH="$PATH"
issues=()

while IFS=  read -r  dir; do

if [ "$dir" = "." ]; then
issues+=("CRITICAL: current directory in path")

elif [ -z "$dir" ]; then
issues+=("CRITICAL: empty PATH entry")

elif [ ! -d "$dir" ]; then
issues+=("WARN: $dir  does not exist.")

else 

OWNER=$(stat -c  %U  "$dir"  2>/dev/null)
        if [ "$OWNER"  != "root" ];then
        issues+=("CRITICAL: $dir owned by $OWNER")
        fi
fi

done <<<  "$(echo "$AUDIT_PATH" |tr  ':'  '\n')"

}

# function no.2

log_path_issues() {
    LOG="$HOME/logs/path_audit.log"
    mkdir -p "$HOME/logs"

    {
        echo "==== PATH AUDIT $(date) ===="
        for i in "${issues[@]}"; do
            echo "$i"
        done
        echo ""
    } >> "$LOG"
}

# function no. 3
output_path_json()
{
    status="ok"
    for i in "${issues[@]}"; do
        [[ $i == CRITICAL* ]] && status="critical"
        [[ $i == WARN* && $status != "critical" ]] && status="warn"
    done

    echo "{"
    echo "\"script\": \"path_auditor\","
    echo "\"data\": {"
    echo "\"status\": \"$status\","

    echo "\"issues\": ["
    for ((j=0; j<${#issues[@]}; j++)); do
        printf "\"%s\"" "${issues[j]}"
        if [ $j -lt $((${#issues[@]} - 1)) ]; then
            printf ",\n"
        fi
    done
    echo "]"

    echo "}"
    echo "}"
}



# function no. 4

output_path_cli()
{
echo "PATH AUDIT RESULT"

if  [ ${#issues[@]} -eq  0 ]; then
echo "no issues detected"
return
fi



for i in  "${issues[@]}"; do
        echo "$i"
        done
        
}

# function no. 5

collect_path_issues
if [ "$1" == "--json" ];then
output_path_json
else
output_path_cli
log_path_issues
fi







