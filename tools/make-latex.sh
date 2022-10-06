#!/usr/bin/env bash
set -e

cat lambda-8cc.lam \
| tr "\n" "@" \
| sed 's/f@/f/g' \
| sed 's/@/\n/g' \
| sed -e "s/^/@_ $/g" \
| sed -e "s/$/$ @/g" \
| sed -e "s/\\\\/@\\\\allowbreak \\\\lambda /g" \
| sed -e "s/(/@\\\\allowbreak (/g" \
| sed -e "s/)/@) \\\\allowbreak /g" \
| sed -e "s/\./.\\\\allowbreak /g" \
| sed -e '0,/@_/ s/@_//' \
| tr "@" "\n" \
| sed -e "s/_/\\\\noindent/g" \
> lambda-8cc.tex
