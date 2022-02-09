#!/bin/bash

cd ./ios/Classes
rm -f ../../macos/Classes/*
for d in *
do
  cd ../../macos/Classes/
  ln -s "../../ios/Classes/$d" "$d"
  (echo "Linking $d to ../../ios/Classes/$d")
done

