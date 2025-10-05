#!/bin/bash
# questa_cva6_wrapper.sh

# Use the system's libstdc++ which has the GLIBCXX_3.4.29 symbol
export LD_PRELOAD=/usr/lib64/libstdc++.so.6.0.29

# Set the simulator to Questa
export DV_SIMULATORS=questa-testharness

# Run the CVA6 simulation command with all arguments passed to this script
echo "Running cva6.py with Questa simulator..."
python3 cva6.py --iss=questa-testharness "$@"
RESULT=$?

# Clean up
unset LD_PRELOAD

exit $RESULT
