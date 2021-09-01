#!/bin/bash
# ------------------------------------------------------------------------------------------------
# Usage: This script calculates the % of the routed sats compared
# to the local channel balance for the last 7 days...
#
# It can be executed as a daily cron job to give a nice history
# The results are written to bos_accounting.log
#
# BOS (Balance of Satoshi) needs to be installed (docker version)
# bc needs to be installed (sudo apt-get bc)
# jq needs to be installed (sudo apt-get jq)

# Version: 0.0.3
# Author: Dirk Krienbuehl https://t.me/Deekee62
# ------------------------------------------------------------------------------------------------


# Check installation: umbrel or native lnd
LNCLI="lncli"
BOS="/opt/homebrew/lib/node_modules/balanceofsatoshis/bos --node=bob"
if uname -a | grep umbrel > /dev/null; then
    LNCLI="docker exec -i lnd lncli"
    BOS="docker run -it --rm --network='host' --add-host=umbrel.local:10.21.21.9 -v $HOME/.bos:/home/node/.bos -v $HOME/umbrel/lnd:/home/node/.lnd:ro alexbosworth/balanceofsatoshis"
fi

# Get local channel balance
#a="$($LNCLI channelbalance | /usr/bin/jq -r '.balance')"
a="$($BOS balance --offchain --confirmed)"
#printf "balance $a"
#
# Get total forwarded amount of sats for the last 7 days
#b="$($BOS chart-fees-earned --forwarded --days 7 | grep 'Total:' | /usr/bin/awk '{print $8}' | /bin/sed -r -e 's/[[:cntrl:]]\[[0-9]{1,3}m//g' -e 's/\n/ /g' | /bin/sed 's/0.//' | tr -d '\r')"
b="$($BOS chart-fees-earned --forwarded --days 7 | grep 'Total:' | /usr/bin/awk '{print $8}' | sed -r -e 's/[[:cntrl:]]\[[0-9]{1,3}m//g' -e 's/\n/ /g' | sed 's/0.//' | tr -d '\r')"
#printf "\nforwarded $b"
#
# Get the total amount of fees earned in the last 7 days
#c="$($BOS chart-fees-earned  --days 7 | grep 'Total:' | /usr/bin/awk '{print $8}' | /bin/sed -r -e 's/[[:cntrl:]]\[[0-9]{1,3}m//g' -e 's/\n/ /g' | /bin/sed 's/0.//' | tr -d '\r')"
c="$($BOS chart-fees-earned  --days 7 | grep 'Total:' | /usr/bin/awk '{print $8}' | sed -r -e 's/[[:cntrl:]]\[[0-9]{1,3}m//g' -e 's/\n/ /g' | sed 's/0.//' | tr -d '\r')"
#printf "\nearned $c"
#
# Get the total amount of fees paid in the last 7 days
#d="$($BOS chart-fees-paid  --days 7 | grep 'Total:' | /usr/bin/awk '{print $9}' | /bin/sed -r -e 's/[[:cntrl:]]\[[0-9]{1,3}m//g' -e 's/\n/ /g' | /bin/sed 's/0.//' | tr -d '\r')"
d="$($BOS chart-fees-paid  --days 7 | grep 'Total:' | /usr/bin/awk '{print $9}' | sed -r -e 's/[[:cntrl:]]\[[0-9]{1,3}m//g' -e 's/\n/ /g' | sed 's/0.//' | tr -d '\r')"
#printf "\npaid $d"
#
# Get the total amount of chain paid in the last 7 days
chain="$($BOS chart-chain-fees  --days 7 | grep 'Total:' | /usr/bin/awk '{print $10}' | sed -r -e 's/[[:cntrl:]]\[[0-9]{1,3}m//g' -e 's/\n/ /g' | sed 's/0.//' | tr -d '\r')"
#printf "\nfees $d"

# Calculate the percentage of the forwared sats compared to the local channel balance for the last 7 days
e=$(echo "scale=2; 100/($a/$b)" | bc -l)
#printf "\nE $e"
#
# Calculate the ppm of the fees earned compared to the local channel balance for the last 7 days
f=$(echo "scale=0; 1000000/($a/$c)" | bc -l)
#printf "\nF $e"
#
# Calculate the ppm of the fees paid compared to the local channel balance for the last 7 days
#
g=$(echo "scale=0; 1000000/($a/$d)" | bc -l)
#printf "\nG $e"
#
# Calculate the ppm of the net fees paid compared to the local channel balance for the last 7 days
#
h=$(echo "scale=0; 1000000/($a/($c-($d+$chain)))" | bc -l)
#printf "\nH $e"
#
# Calculate the sats of net fees earned
#
i=$(echo "scale=0; ($c-($d+$chain))" | bc -l)
#printf "\nI $e"
#
CURRENTDATE=`date +"%Y-%m-%d %T"`
# Print year, time, local channel balance, forwarded amount, % forwarded, fees earned ppm, fees paid ppm, fees net ppm, amount fees earned, amount fees paid, amount fees net
printf "${CURRENTDATE} "$a" "$b" "$e" "$f" "$g" "$h" "$c" "$d" "$i"" >> ~/Downloads/bos_accounting/bos_accounting.log
