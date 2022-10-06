#!/usr/bin/env bash
set -e

cat lambda-8cc.lam \
| tr "\n" "@" \
| LC_ALL=C sed 's/f@/f/g' \
| LC_ALL=C sed 's/@/\n/g' \
| LC_ALL=C sed -e "s/^/@_ $/g" \
| LC_ALL=C sed -e "s/$/$ @/g" \
| LC_ALL=C sed -e "s/\\\\/@\\\\allowbreak \\\\lambda /g" \
| LC_ALL=C sed -e "s/(/@\\\\allowbreak (/g" \
| LC_ALL=C sed -e "s/)/@) \\\\allowbreak /g" \
| LC_ALL=C sed -e "s/\./.\\\\allowbreak /g" \
| LC_ALL=C tr "@" "\n" \
| LC_ALL=C sed -e "s/_/\\\\noindent/g" \
> lambda-8cc.tex
