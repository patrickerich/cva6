# Questa compilation script for CVA6
puts "Compiling CVA6 for Questa simulation..."

# Create the work library if it doesn't exist
if {![file exists work]} {
  vlib work
}
vmap work work

# Compile the design
vlog -sv -work work \
  +incdir+$env(CVA6_REPO_DIR)/core/include \
  +incdir+$env(CVA6_REPO_DIR)/vendor/pulp-platform/common_cells/include \
  +incdir+$env(CVA6_REPO_DIR)/vendor/pulp-platform/axi/include \
  +incdir+$env(CVA6_REPO_DIR)/corev_apu/register_interface/include \
  +incdir+$env(CVA6_REPO_DIR)/corev_apu/tb/common \
  -f $env(CVA6_REPO_DIR)/core/Flist.cva6 \
  $env(CVA6_REPO_DIR)/corev_apu/tb/ariane_testharness.sv

puts "Compilation complete."
