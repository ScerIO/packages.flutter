#!/bin/bash

cd ./ios/Classes
rm -f ../../macos/Classes/*
for d in *
do
  cd ../../macos/Classes/
  ln -s "../../ios/Classes/$d" "$d"
  (echo "$d")
done

