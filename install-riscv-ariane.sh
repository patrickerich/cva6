#!/bin/bash

#############################################################################
#
# RISC-V GCC 14 Bare-metal Toolchain Installation for CVA6 (Ariane)
# Installs RISC-V toolchain to /opt/ariane/riscv
#
# This script works around vendor script limitations without modifying them
#
#############################################################################

set -e  # Exit on any error

echo "=== RISC-V GCC 14 Bare-metal Toolchain Installation for CVA6 (Ariane) ==="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Target installation directory
TARGET_INSTALL_DIR="/opt/ariane/riscv"

# Set up environment
export INSTALL_DIR="$TARGET_INSTALL_DIR"
export NUM_JOBS=$(nproc)
export CC_FOR_TARGET=riscv-none-elf-gcc

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
REQUIRED_PACKAGES="autoconf automake git libmpc-devel mpfr-devel gmp-devel gawk bison flex texinfo gcc gcc-c++ zlib-devel libtool gperf make"
echo "Required packages: $REQUIRED_PACKAGES"
echo "If any are missing, run: sudo dnf -y install $REQUIRED_PACKAGES"
echo ""

# Create target directory if it doesn't exist and ensure proper ownership
sudo mkdir -p "$TARGET_INSTALL_DIR"
sudo chown "$(whoami):$(id -gn)" "$TARGET_INSTALL_DIR"

# Clean up previous build if it exists
if [ -n "$(ls -A "$TARGET_INSTALL_DIR" 2>/dev/null)" ]; then
    echo "=== Cleaning previous installation ==="
    rm -rf "$TARGET_INSTALL_DIR"/*
fi

# Check if toolchain builder scripts exist
if [ ! -f "util/toolchain-builder/get-toolchain.sh" ] || [ ! -f "util/toolchain-builder/build-toolchain.sh" ]; then
    echo "ERROR: Toolchain builder scripts not found"
    echo "Please run this script from the CVA6 root directory"
    exit 1
fi

# Change to toolchain builder directory
cd util/toolchain-builder

# Fetch sources
echo "=== Fetching GCC 14 sources ==="
bash get-toolchain.sh gcc-14.1.0-baremetal

# Build with vendor script (allow it to fail on libgcc/newlib)
echo "=== Building toolchain (initial pass, expected to fail on libgcc/newlib) ==="
set +e  # Don't exit on error for this command
bash build-toolchain.sh -f gcc-14.1.0-baremetal "$INSTALL_DIR"
BUILD_EXIT_CODE=$?
set -e  # Resume exit on error

echo "Initial build exit code: $BUILD_EXIT_CODE (failures on libgcc/newlib are expected)"

# Check if GCC compiler was built successfully
if [ ! -f "$INSTALL_DIR/bin/riscv-none-elf-gcc" ]; then
    echo "ERROR: GCC compiler was not built successfully"
    exit 1
fi

echo "=== GCC compiler built successfully ==="

# Create the cc symlink that newlib expects
echo "=== Creating cc symlink for newlib ==="
ln -sf "$INSTALL_DIR/bin/riscv-none-elf-gcc" "$INSTALL_DIR/bin/riscv-none-elf-cc"
echo "Created symlink: riscv-none-elf-cc -> riscv-none-elf-gcc"

# Build and install newlib
echo "=== Building and installing newlib ==="
export PATH="$INSTALL_DIR/bin:$PATH"

if [ -d "build/newlib-riscv-none-elf" ]; then
    cd build/newlib-riscv-none-elf
    echo "Building newlib with $(nproc) jobs..."
    make -j"$(nproc)"
    echo "Installing newlib..."
    make install
    cd ../..
    echo "Newlib built and installed successfully"
else
    echo "ERROR: newlib build directory not found"
    exit 1
fi

# Finish GCC target libgcc installation
echo "=== Building and installing target libgcc ==="
if [ -d "build/gcc" ]; then
    cd build/gcc
    echo "Building target libgcc..."
    make all-target-libgcc -j"$(nproc)"
    echo "Installing target libgcc..."
    make install-target-libgcc
    cd ../..
    echo "Target libgcc built and installed successfully"
else
    echo "ERROR: gcc build directory not found"
    exit 1
fi

# Return to script directory
cd "$SCRIPT_DIR"

# Verification
echo "=== Verification ==="
echo "GCC version:"
"$INSTALL_DIR/bin/riscv-none-elf-gcc" --version

echo ""
echo "Checking for newlib header:"
if [ -f "$INSTALL_DIR/riscv-none-elf/include/newlib.h" ]; then
    echo "✓ newlib.h found"
else
    echo "✗ newlib.h not found"
    exit 1
fi

echo ""
echo "Checking for libgcc:"
LIBGCC_PATH=$(find "$INSTALL_DIR/lib/gcc/riscv-none-elf" -name "libgcc.a" 2>/dev/null | head -1)
if [ -n "$LIBGCC_PATH" ]; then
    echo "✓ libgcc.a found at: $LIBGCC_PATH"
else
    echo "✗ libgcc.a not found"
    exit 1
fi

echo ""
echo "=== Installation completed successfully! ==="
echo "RISC-V toolchain installed in: $INSTALL_DIR"
echo ""
echo "To use the toolchain:"
echo "  export PATH=\"$INSTALL_DIR/bin:\$PATH\""
echo "  riscv-none-elf-gcc --version"
echo ""
echo "Or add to your shell profile (.bashrc/.zshrc):"
echo "  echo 'export PATH=\"$INSTALL_DIR/bin:\$PATH\"' >> ~/.bashrc"