#/usr/bin/env bash

# * Prepend the following line to all Python files of the target program.
#
#   from otkt.otelinit import tracer
#
sed -i '1 i\from otkt.instrument import instrument' **/*py

# * Prepend the following line before all Python method definitions:
#
#   @instrument
#
sed -i 's/^\([\ \t]*\)\(def \)\(.*\)$/\1@instrument\n\1\2\3/g' **/*py
