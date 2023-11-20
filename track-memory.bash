#!/bin/bash

DIR=$(dirname "$0")

if [ ! -d "$DIR/data" ]; then
    mkdir -p "$DIR/data"
fi

JSONFILE="$DIR/data/$(date +%Y-%m-%d).json"

if [ ! -f "$JSONFILE" ]; then
    echo "[]" > $JSONFILE
fi

topOutput=$(top -l 1)

memRegions=$(echo "$topOutput" | grep "MemRegions:" | awk '{print "{\"total\": \"" $2 "\", \"resident\": \"" $4 "\", \"private\": \"" $6 "\", \"shared\": \"" $8 "\"}"}')

physMem=$(echo "$topOutput" | grep "PhysMem:" | awk '{
    gsub(/[^0-9MKG]+/, "", $2); gsub(/[^0-9MKG]+/, "", $4);
    gsub(/[^0-9MKG]+/, "", $6); gsub(/[^0-9MKG]+/, "", $8);
    print "{\"used\": \"" $2 "\", \"wired\": \"" $4 "\", \"compressor\": \"" $6 "\", \"unused\": \"" $8 "\"}"
}')


echo "$topOutput" | grep "VM:"

vm=$(echo "$topOutput" | grep "VM:" | awk '{
    print "{\"vsize\": \"" $2 "\", \"framework_vsize\": \"" $4 "\", \"swapins\": \"" $7 "\", \"swapouts\": \"" $9 "\"}"
}' | sed 's/([^)]*)//g')

customString1=$(echo "$topOutput" | grep '[custom_string_1]' | awk '{mem += $8; cpu += $9} END {print mem, cpu}')
#customString2=$(echo "$topOutput" | grep '[custom_string_2]' | awk '{mem += $8; cpu += $9} END {print mem, cpu}')

jsonObject=$(cat <<-END
{
  "datetime": "$(date +"%Y-%m-%dT%H:%M:%S")",
  "memRegions": $memRegions,
  "physMem": $physMem,
  "vm": $vm,
  "custom_strings": [
    { "string": "OrbStack", "memory": "$(echo $customString1 | awk '{print $1}')", "cpu": "$(echo $customString1 | awk '{print $2}')" }
  ]
}
END
)

echo "$jsonObject"
echo "$JSONFILE"

tmp=$(mktemp)

jq --argjson obj "$jsonObject" '. += [$obj]' $JSONFILE > "$tmp" && mv "$tmp" $JSONFILE

