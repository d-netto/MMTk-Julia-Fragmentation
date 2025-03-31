#!/bin/bash

MMTK_JULIA_FRAGMENTATION_ROOT=../..
# Print the full path of the MMTk-Julia-Fragmentation directory
cd $MMTK_JULIA_FRAGMENTATION_ROOT; print_green "MMTK-Julia-Fragmentation path: $(pwd)"; cd - > /dev/null

# Print line in green
function print_green {
    echo -e "\033[0;32m$1\033[0m"
}

# Small function to encapsulate the commands to build Julia (i.e. make -C ../mmtk-julia clean && make cleanall && make -j
function build_julia {
    cd $MMTK_JULIA_FRAGMENTATION_ROOT/$1
    make -C ../mmtk-julia clean
    make cleanall
    make -j
    cd - > /dev/null
}

build_julia julia-stock
$($MMTK_JULIA_FRAGMENTATION_ROOT/julia-stock/build/bin/julia --project=$MMTK_JULIA_FRAGMENTATION_ROOT/julia-stock -e 'using Pkg; Pkg.activate(".."); Pkg.instantiate()')