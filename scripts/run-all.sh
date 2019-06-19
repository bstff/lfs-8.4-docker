#!/bin/bash
set -e
echo "Start.."

# prepare to build
sh /tools/run-prepare.sh

# execute rest as root
exec sudo -E -u root /bin/sh - <<EOF
#  change ownership
chown -R root:root $LFS/tools
# prevent "bad interpreter: Text file busy"
sync
# continue
sh /tools/run-build.sh
sh /tools/run-image.sh
EOF

# sudo chown -R root:root $LFS/tools
# sudo -E -u root /bin/sh -c "sh /tools/run-build.sh"
# sudo -E -u root /bin/sh -c "sh /tools/run-image.sh"
