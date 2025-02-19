#/usr/bin/env bash

sed -i '1 i\from otkt.instrument import instrument' **/*py
sed -i 's/^\([\ \t]*\)\(def \)\(.*\)$/\1@instrument\n\1\2\3/g' **/*py
