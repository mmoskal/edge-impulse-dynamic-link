#!/bin/sh
set -x
set -e
rm -rf build edge-impulse-sdk model-parameters tflite-model
7z x "$1"
cd edge-impulse-sdk
patch -p1 < ../eidsp-small-fft.patch
