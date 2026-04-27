#!/usr/bin/bash

# Called a basic binary planting attack

mkdir -p ./malicious

echo -e '#!/bin/bash\necho "MALICIOUS CODE EXECUTED"' > ./malicious/ls
chmod +x ./malicious/ls

export PATH=.:$PATH

ls
