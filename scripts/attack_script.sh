#!/usr/bin/bash
mkdir -p ./malicious

echo -e '#!/bin/bash\necho "MALICIOUS CODE EXECUTED"' > ./malicious/ls
chmod +x ./malicious/ls

export PATH=.:$PATH

ls
