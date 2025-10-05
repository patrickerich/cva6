#!/bin/bash

# Test script to check if a toolset's libstdc++ can be used with Questa

# Choose a toolset to test
TOOLSET="/opt/rh/gcc-toolset-12"

if [ ! -f "$TOOLSET/enable" ]; then
    echo "Error: Toolset enable script not found at $TOOLSET/enable"
    exit 1
fi

# Source the toolset environment
source "$TOOLSET/enable"

# Find the libstdc++ path
LIBSTDC_PATH=$(gcc -print-file-name=libstdc++.so.6)
echo "Using libstdc++ from: $LIBSTDC_PATH"

# Create a simple test program that uses C++
cat > test_cpp.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello from C++" << std::endl;
    return 0;
}
EOF

# Compile it
g++ -o test_cpp test_cpp.cpp
if [ $? -ne 0 ]; then
    echo "Error: Failed to compile test program"
    exit 1
fi

echo "Test program compiled successfully"

# Now try to run Questa with this environment
echo "Attempting to run Questa with $TOOLSET environment..."

# Set LD_LIBRARY_PATH to prioritize the toolset's libraries
export LD_LIBRARY_PATH=$(dirname "$LIBSTDC_PATH"):$LD_LIBRARY_PATH

# Try to run a simple Questa command (adjust as needed for your installation)
vsim -version
RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo "Success: Questa ran successfully with $TOOLSET environment"
else
    echo "Error: Questa failed to run with $TOOLSET environment"
fi

# Clean up
rm -f test_cpp test_cpp.cpp

exit $RESULT

