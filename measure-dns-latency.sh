#!/bin/bash

set -ue -o pipefail

# Uncomment to see each command executed
#set -x

trap 'echo An error occurred! Quitting prematurely.' ERR

# Get a relative path to the domain list, no matter where the script is called from.
domainList="$(dirname $0)/public-domain-lists/opendns-random-domains.txt"
numberOfDomains=100
timeStamp="$( date '+%F_%H_%M_%S' )"
dataFile="results-$timeStamp.txt"

echo "Using the domain list located at $domainList"
echo "Saving to $dataFile"

domains="$(shuf -n $numberOfDomains $domainList)"
i=0
for domain in $domains
do
  echo "Trying $domain"
  # There are some dead domains in our domain list, so we have to be prepared to break
  # out if nslookup fails
  lookupTime="$( ( time nslookup $domain ) |& awk '$1=="real"{print $2}' )" || continue
  echo "$i $domain $lookupTime" | tee --append "$dataFile"
  i=$(( i + 1 ))
done
