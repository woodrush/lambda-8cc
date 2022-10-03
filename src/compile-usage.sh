#!/usr/bin/env bash
set -e

printf '(def-lazy usage-base (string-concatenator nil';

cat usage.txt \
| tr "\n" "@" \
| rev \
| sed -e 's/\(.\)/"\1" /g' \
| sed -e 's/\\/\\\\/g' \
| sed -e 's/"@"/\n  "\\\\n"/g' \
| sed -e 's/ $//g' \

echo ' nil))';
