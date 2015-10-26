#!/bin/bash

for f in fastafiles2/*.fa
do
  echo $f 
  qsub script2 $f
done
