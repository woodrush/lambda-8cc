#!/usr/bin/env bash
set -e

printf '(def-lazy usage (string-concatenator nil ';

cat usage.txt \
| tr "\n" "N" \
| rev \
| sed -e 's/\(.\)/"\1" /g' \
| sed -e 's/\\/\\\\/g' \
| sed -e 's/ "N"/\n  "\\\\n"/g'

echo 'nil))';
