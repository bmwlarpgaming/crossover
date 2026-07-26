#!/bin/bash

crossover_archive=$(curl -fsSL 'https://www.codeweavers.com/crossover/download-now' | grep -F 'cxmac/demo/crossover-' | cut -d '"' -f 2)
wget $crossover_archive -O 'crossover.zip'
unzip 'crossover.zip'
