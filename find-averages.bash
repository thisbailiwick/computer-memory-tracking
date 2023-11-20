#!/bin/bash

DIR=$(dirname "$0")
JSONFILE="$DIR/data/$(date +%Y-%m-%d).json"
AVGFILE="$DIR/data/$(date +%Y-%m-%d)_average.json"

if [ ! -f "$JSONFILE" ]; then
    echo "No data for today."
    exit 1
fi

function calc_avg {
    jq -r "[.[].$1 | select(. != null) |
            capture(\"(?<num>[0-9.]+)(?<unit>[KMG]?)\") |
            .num as \$num | .unit as \$unit |
            if \$unit == \"G\" then (\$num | tonumber) * 1024
            elif \$unit == \"T\" then (\$num | tonumber) * 1048576
            elif \$unit == \"K\" then (\$num | tonumber) / 1024
            else (\$num | tonumber) end
           ] | add / length" $JSONFILE
}

avgMemRegionsTotal=$(calc_avg 'memRegions.total')
avgMemRegionsResident=$(calc_avg 'memRegions.resident')
avgMemRegionsPrivate=$(calc_avg 'memRegions.private')
avgMemRegionsShared=$(calc_avg 'memRegions.shared')

avgPhysMemUsed=$(calc_avg 'physMem.used')
avgPhysMemWired=$(calc_avg 'physMem.wired')
avgPhysMemCompressor=$(calc_avg 'physMem.compressor')
avgPhysMemUnused=$(calc_avg 'physMem.unused')

avgVmVsize=$(calc_avg 'vm.vsize')
avgVmFrameworkVsize=$(calc_avg 'vm.framework_vsize')
avgVmSwapins=$(calc_avg 'vm.swapins')
avgVmSwapouts=$(calc_avg 'vm.swapouts')

avgCustomStringMemory=$(calc_avg 'custom_strings[0].memory')
avgCustomStringCpu=$(calc_avg 'custom_strings[0].cpu')

averages=$(jq -n \
  --arg avgMemRegionsTotal "$avgMemRegionsTotal" \
  --arg avgMemRegionsResident "$avgMemRegionsResident" \
  --arg avgMemRegionsPrivate "$avgMemRegionsPrivate" \
  --arg avgMemRegionsShared "$avgMemRegionsShared" \
  --arg avgPhysMemUsed "$avgPhysMemUsed" \
  --arg avgPhysMemWired "$avgPhysMemWired" \
  --arg avgPhysMemCompressor "$avgPhysMemCompressor" \
  --arg avgPhysMemUnused "$avgPhysMemUnused" \
  --arg avgVmVsize "$avgVmVsize" \
  --arg avgVmFrameworkVsize "$avgVmFrameworkVsize" \
  --arg avgVmSwapins "$avgVmSwapins" \
  --arg avgVmSwapouts "$avgVmSwapouts" \
  --arg avgCustomStringMemory "$avgCustomStringMemory" \
  --arg avgCustomStringCpu "$avgCustomStringCpu" \
  '{
     date: "'$(date +"%Y-%m-%d")'",
     average_memRegions: {
       total: $avgMemRegionsTotal,
       resident: $avgMemRegionsResident,
       private: $avgMemRegionsPrivate,
       shared: $avgMemRegionsShared
     },
     average_physMem: {
       used: $avgPhysMemUsed,
       wired: $avgPhysMemWired,
       compressor: $avgPhysMemCompressor,
       unused: $avgPhysMemUnused
     },
     average_vm: {
       vsize: $avgVmVsize,
       framework_vsize: $avgVmFrameworkVsize,
       swapins: $avgVmSwapins,
       swapouts: $avgVmSwapouts
     },
     average_customStrings: {
       OrbStack: {
         memory: $avgCustomStringMemory,
         cpu: $avgCustomStringCpu
    }
  }
   }')

echo "$averages" | jq '.' > $AVGFILE
