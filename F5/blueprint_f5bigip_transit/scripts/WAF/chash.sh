#!/bin/bash

#cat forchildhash | jq -r .generalReference | awk -F ":" '{print $3}' | awk -F "/" '{print $8}' > hashc
cat forchildhash | jq -r .id > hashc
#sed -i '1d;$d' hashc
#rm forchildhash