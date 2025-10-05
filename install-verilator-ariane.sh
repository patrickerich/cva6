#!/bin/bash

#############################################################################
#
# Verilator Installation Wrapper for CVA6 (Ariane)
# Installs Verilator v5.008 to /opt/ariane/verilator
#
#############################################################################

set -e  # Exit on any error

echo "=== Verilator Installation Wrapper for CVA6 (Ariane) ==="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Target installation directory
TARGET_INSTALL_DIR="/opt/ariane/verilator"

# Set up environment variables for the vendor script
export VERILATOR_INSTALL_DIR="$TARGET_INSTALL_DIR"
export NUM_JOBS=$(nproc)

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
echo "Required packages for Verilator:"
echo "  - autoconf, automake, make, g++, flex, bison, git"
echo "  - For AlmaLinux/RHEL: sudo dnf -y install autoconf automake make gcc-c++ flex bison git"
echo ""

# Create target directory if it doesn't exist
sudo mkdir -p "$TARGET_INSTALL_DIR"
sudo chown "$(whoami):$(id -gn)" "$TARGET_INSTALL_DIR"

# Check if verilator script exists
VERILATOR_SCRIPT="verif/regress/install-verilator.sh"
if [ ! -f "$VERILATOR_SCRIPT" ]; then
    echo "ERROR: Verilator installation script not found at: $VERILATOR_SCRIPT"
    echo "Please run this script from the CVA6 root directory"
    exit 1
fi

echo "=== Running Verilator installation script ==="
echo "This will install Verilator v5.008 to: $TARGET_INSTALL_DIR"
echo ""

# Run the vendor installation script
bash "$VERILATOR_SCRIPT"

# Verification
echo ""
echo "=== Verification ==="
if [ -f "$TARGET_INSTALL_DIR/bin/verilator" ]; then
    echo "✓ Verilator installed successfully"
    echo "Version: $("$TARGET_INSTALL_DIR/bin/verilator" --version)"
else
    echo "✗ Verilator installation failed"
    exit 1
fi

echo ""
echo "=== Installation completed successfully! ==="
echo "Verilator installed in: $TARGET_INSTALL_DIR"
echo ""
echo "To use Verilator:"
echo "  export PATH=\"$TARGET_INSTALL_DIR/bin:\$PATH\""
echo "  verilator --version"
echo ""
echo "Or add to your shell profile (.bashrc/.zshrc):"
echo "  echo 'export PATH=\"$TARGET_INSTALL_DIR/bin:\$PATH\"' >> ~/.bashrc"