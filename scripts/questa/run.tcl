# Questa run script for CVA6
puts "Running CVA6 simulation..."

# Get the ELF file from the command line
set elf_file [lindex $argv 0]
set run_opts [lindex $argv 1]

# Run the simulation
vsim -c -do "run -all; quit -f" \
  +elf_file=$elf_file \
  $run_opts \
  work.ariane_testharness

puts "Simulation complete."
