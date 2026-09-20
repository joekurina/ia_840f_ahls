#!/bin/bash
# BMC card power cycle (Off 12s, On), wait, then reboot host for clean PERST/POST.
# Log everything. tmux window: pristine_cycle
set -x
export PATH=$HOME/.local/bin:$PATH
export PP=$HOME/.local/lib/python3.9/site-packages
date
echo "=== POWER OFF ==="
sudo -n env PYTHONPATH=$PP PATH=$PATH bw_bmc_configure -i USB -d USB:0 power -p Off
sleep 12
echo "=== POWER ON ==="
sudo -n env PYTHONPATH=$PP PATH=$PATH bw_bmc_configure -i USB -d USB:0 power -p On
sleep 20
date
echo "CYCLE_DONE"
sleep 10
echo "=== REBOOTING HOST ==="
sudo -n reboot
