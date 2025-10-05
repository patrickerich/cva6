#!/bin/bash

#############################################################################
#
# Spike Installation Wrapper for CVA6 (Ariane)
# Installs Spike RISC-V ISA Simulator to /opt/ariane/spike
#
#############################################################################

set -e  # Exit on any error

echo "=== Spike Installation Wrapper for CVA6 (Ariane) ==="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Target installation directory
TARGET_INSTALL_DIR="/opt/ariane/spike"

# Set up environment variables for the vendor script
export SPIKE_INSTALL_DIR="$TARGET_INSTALL_DIR"
export NUM_JOBS=$(nproc)

# Ensure SPIKE_INSTALL_DIR is not "__local__" which would trigger default behavior
if [ "$SPIKE_INSTALL_DIR" = "__local__" ]; then
    echo "ERROR: SPIKE_INSTALL_DIR cannot be '__local__'"
    exit 1
fi

echo "Target installation directory: $TARGET_INSTALL_DIR"
echo "Using $NUM_JOBS parallel jobs"

# Check if we have write permissions to the target directory
if [ ! -w "$(dirname "$TARGET_INSTALL_DIR")" ]; then
    echo "ERROR: No write permission to $(dirname "$TARGET_INSTALL_DIR")"
    echo "Please run with sudo or ensure $(dirname "$TARGET_INSTALL_DIR") is writable"
    exit 1
fi

# Check prerequisites
echo "=== Checking prerequisites ==="
echo "Required packages for Spike:"
echo "  - autoconf, automake, make, g++, git, device-tree-compiler"
echo "  - For AlmaLinux/RHEL: sudo dnf -y install autoconf automake make gcc-c++ git dtc"
echo ""

# Check for Verilator installation (needed for DPI headers)
VERILATOR_PATHS=(
    "/opt/ariane/verilator"
    "/usr/local"
    "/usr"
)

VERILATOR_ROOT=""
for path in "${VERILATOR_PATHS[@]}"; do
    if [ -f "$path/bin/verilator" ] && [ -f "$path/share/verilator/include/verilated.h" ]; then
        VERILATOR_ROOT="$path"
        echo "Found Verilator at: $VERILATOR_ROOT"
        break
    fi
done

if [ -z "$VERILATOR_ROOT" ]; then
    echo "WARNING: Verilator not found in standard locations."
    echo "Spike may fail to build due to missing SystemVerilog DPI headers."
    echo "Consider installing Verilator first with: ./install-verilator-ariane.sh"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
else
    export VERILATOR_ROOT="$VERILATOR_ROOT"
    echo "Set VERILATOR_ROOT=$VERILATOR_ROOT"
fi

echo ""

# Create target directory if it doesn't exist
sudo mkdir -p "$TARGET_INSTALL_DIR"
sudo chown "$(whoami):$(id -gn)" "$TARGET_INSTALL_DIR"

# Check if spike script exists
SPIKE_SCRIPT="verif/regress/install-spike.sh"
if [ ! -f "$SPIKE_SCRIPT" ]; then
    echo "ERROR: Spike installation script not found at: $SPIKE_SCRIPT"
    echo "Please run this script from the CVA6 root directory"
    exit 1
fi

# Check if vendorized spike source exists
EXPECTED_SPIKE_SRC="verif/core-v-verif/vendor/riscv/riscv-isa-sim"
if [ ! -d "$EXPECTED_SPIKE_SRC" ]; then
    echo "ERROR: Vendorized Spike source not found at: $EXPECTED_SPIKE_SRC"
    echo "You may need to initialize git submodules first:"
    echo "  git submodule update --init --recursive"
    exit 1
fi

# Additional check for DPI-related files that might cause build issues
if [ -f "$EXPECTED_SPIKE_SRC/fesvr/fesvr_dpi.cc" ] && [ -z "$VERILATOR_ROOT" ]; then
    echo "WARNING: Spike source includes SystemVerilog DPI support but Verilator not found."
    echo "This may cause build failures. Consider installing Verilator first:"
    echo "  ./install-verilator-ariane.sh"
    echo ""
fi

echo "=== Running Spike installation script ==="
echo "This will build and install Spike to: $TARGET_INSTALL_DIR"
echo "Using vendorized source from: $EXPECTED_SPIKE_SRC"

# Debug: Show environment variables that will be passed to vendor script
echo "Environment variables for vendor script:"
echo "  SPIKE_INSTALL_DIR=$SPIKE_INSTALL_DIR"
echo "  NUM_JOBS=$NUM_JOBS"

# Set additional environment variables for Spike build
if [ -n "$VERILATOR_ROOT" ]; then
    echo "Configuring Spike build with Verilator support from: $VERILATOR_ROOT"
    export CPPFLAGS="-I$VERILATOR_ROOT/share/verilator/include -I$VERILATOR_ROOT/share/verilator/include/vltstd"
    export LDFLAGS="-L$VERILATOR_ROOT/lib"
fi

echo ""

# Clean any existing build that might interfere
if [ -d "$SCRIPT_DIR/tools" ]; then
    echo "Cleaning existing tools directory to prevent conflicts..."
    rm -rf "$SCRIPT_DIR/tools"
fi

# Run the vendor installation script with explicit environment
echo "Running: SPIKE_INSTALL_DIR='$SPIKE_INSTALL_DIR' NUM_JOBS='$NUM_JOBS' bash '$SPIKE_SCRIPT'"
SPIKE_INSTALL_DIR="$SPIKE_INSTALL_DIR" NUM_JOBS="$NUM_JOBS" bash "$SPIKE_SCRIPT"

# Verification
echo ""
echo "=== Verification ==="

# Check if spike was installed in the target directory
if [ -f "$TARGET_INSTALL_DIR/bin/spike" ]; then
    echo "✓ Spike installed successfully"
    echo "Spike executable: $TARGET_INSTALL_DIR/bin/spike"
    # Test spike with a simple command
    if "$TARGET_INSTALL_DIR/bin/spike" --help >/dev/null 2>&1; then
        echo "✓ Spike runs correctly"
    else
        echo "⚠ Spike installed but may have runtime issues"
    fi
else
    echo "✗ Spike not found in target directory: $TARGET_INSTALL_DIR/bin/spike"

    # Check if it was installed in the default location instead
    DEFAULT_SPIKE_DIR="$SCRIPT_DIR/tools/spike"
    if [ -f "$DEFAULT_SPIKE_DIR/bin/spike" ]; then
        echo "⚠ Spike was installed in default location: $DEFAULT_SPIKE_DIR"
        echo "Moving to target location..."

        # Move the installation to the correct location
        if [ -d "$DEFAULT_SPIKE_DIR" ]; then
            sudo mkdir -p "$(dirname "$TARGET_INSTALL_DIR")"
            sudo mv "$DEFAULT_SPIKE_DIR" "$TARGET_INSTALL_DIR"
            sudo chown -R "$(whoami):$(id -gn)" "$TARGET_INSTALL_DIR"
            echo "✓ Moved Spike from $DEFAULT_SPIKE_DIR to $TARGET_INSTALL_DIR"

            # Verify the move worked
            if [ -f "$TARGET_INSTALL_DIR/bin/spike" ]; then
                echo "✓ Spike now available at: $TARGET_INSTALL_DIR/bin/spike"
            else
                echo "✗ Failed to move Spike installation"
                exit 1
            fi
        fi
    else
        echo "✗ Spike not found in default location either: $DEFAULT_SPIKE_DIR"
        echo "Build may have failed completely"
        exit 1
    fi
fi

echo ""
echo "=== Installation completed successfully! ==="
echo "Spike installed in: $TARGET_INSTALL_DIR"
echo ""
echo "To use Spike:"
echo "  export PATH=\"$TARGET_INSTALL_DIR/bin:\$PATH\""
echo "  spike --help"
echo ""
echo "Or add to your shell profile (.bashrc/.zshrc):"
echo "  echo 'export PATH=\"$TARGET_INSTALL_DIR/bin:\$PATH\"' >> ~/.bashrc"