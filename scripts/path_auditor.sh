#!/usr/bin/bash

declare -a issues

collect_path_issues() {
    AUDIT_PATH="$PATH"
    IFS=':' read -ra PATH_DIRS <<< "$AUDIT_PATH"

    seen_dirs=()

    for dir in "${PATH_DIRS[@]}"; do

        if [ "$dir" = "." ]; then
            issues+=("CRITICAL: '.' in PATH allows command hijacking")

        elif [ -z "$dir" ]; then
            issues+=("CRITICAL: empty PATH entry")

        elif [ ! -d "$dir" ]; then
            issues+=("WARN: $dir does not exist")

        # Normalize path
        norm_dir="$(realpath -m "$dir" 2>/dev/null || echo "$dir")"

# Ignore virtualenv directories
        if [[ "$norm_dir" == *"/venv/"* || "$norm_dir" == *"/.venv/"* ]]; then
            if [ -w "$dir" ]; then
        issues+=("INFO: $dir is writable (expected virtualenv behavior)")
            fi
             else
                 if [ -w "$dir" ]; then
                    issues+=("CRITICAL: $dir is writable")
                  fi
                    fi

        # Duplicate detection
        if [[ " ${seen_dirs[*]} " =~ " $dir " ]]; then
            issues+=("WARN: duplicate PATH entry $dir")
        else
            seen_dirs+=("$dir")
        fi

    done
}

output_path_json() {
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
        safe_issue=${issues[j]//\"/\\\"}
        printf "\"%s\"" "$safe_issue"
        if [ $j -lt $((${#issues[@]} - 1)) ]; then
            printf ",\n"
        fi
    done

    echo "]"
    echo "}"
    echo "}"
}

collect_path_issues

if [ "$1" == "--json" ]; then
    output_path_json
else
 echo "PATH AUDIT RESULT"

    if [ ${#issues[@]} -eq 0 ]; then
    echo "No issues detected"
    else
        for i in "${issues[@]}"; do
            echo "$i"
        done
    fi
fi












