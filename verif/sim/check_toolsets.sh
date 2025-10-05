# List available toolsets
ls -la /opt/rh/

# For each toolset, check if it includes GCC and what version
for toolset in /opt/rh/*; do
    if [ -d "$toolset" ]; then
        echo "Checking $toolset..."
        if [ -f "$toolset/enable" ]; then
            # Source the enable script to set up the environment
            source "$toolset/enable" 2>/dev/null
            # Check if gcc is available and what version it is
            if command -v gcc &>/dev/null; then
                echo "  GCC version: $(gcc --version | head -1)"
                # Check if libstdc++ has the required symbol
                LIBSTDC_PATH=$(gcc -print-file-name=libstdc++.so.6)
                if strings "$LIBSTDC_PATH" | grep -q "GLIBCXX_3.4.29"; then
                    echo "  ✓ Has GLIBCXX_3.4.29 in $LIBSTDC_PATH"
                else
                    echo "  ✗ Does not have GLIBCXX_3.4.29"
                fi
            else
                echo "  No GCC found in this toolset"
            fi
            # Reset the environment
            source /etc/profile
        else
            echo "  No enable script found"
        fi
    fi
done