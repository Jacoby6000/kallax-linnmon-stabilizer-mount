#!/bin/bash
datetime=$(date +%Y%m%d-%H%M%S)
openscad -o "bracket-$datetime.3mf" bracket.scad
