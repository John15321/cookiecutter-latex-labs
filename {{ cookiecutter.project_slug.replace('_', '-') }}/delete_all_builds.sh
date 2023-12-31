#!/bin/bash

for dir in lab*/report/build/; do
   if [ -d "$dir" ]; then
       rm -r "$dir"
   fi
done
