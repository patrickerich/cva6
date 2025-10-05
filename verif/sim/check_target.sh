#!/bin/bash

# Check if the Makefile has a questa-testharness target
cd /home/patrick/Projects/cva6/verif/sim
echo "Checking for questa-testharness target in Makefile..."

if grep -q "questa-testharness:" Makefile; then
    echo "Found questa-testharness target in Makefile"
    # Extract the target definition
    echo "Target definition:"
    grep -A 20 "questa-testharness:" Makefile
else
    echo "questa-testharness target not found in Makefile"
    # Check if there are any questa-related targets
    echo "Checking for any questa-related targets:"
    grep -i "questa" Makefile
fi

# Check if the make command exists and can be executed
echo "Checking make command..."
if command -v make &> /dev/null; then
    echo "make command found"
    # Try to run make with --just-print to see what it would do
    echo "Trying make --just-print questa-testharness..."
    make --just-print questa-testharness 2>&1 | head -20
else
    echo "make command not found"
fi

# Check if vsim (Questa simulator) is installed and accessible
echo "Checking for Questa simulator..."
if command -v vsim &> /dev/null; then
    echo "vsim command found"
    vsim -version
else
    echo "vsim command not found"
    # Check common installation locations
    for path in /opt/intelFPGA_pro/*/questa_fse/bin /opt/mentor/questasim/bin /usr/local/questasim/bin; do
        if [ -f "$path/vsim" ]; then
            echo "Found vsim at: $path/vsim"
            "$path/vsim" -version
            break
        fi
    done
fi

