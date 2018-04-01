#!/bin/bash
cd "$(dirname -- "$(readlink -fn -- "${0}")")"

cc -c mylibrary.c
ld -r mylibrary.o -o mylibrary.a
rm mylibrary.o