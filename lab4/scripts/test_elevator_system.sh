#!/bin/bash

# Compile and simulate the complete elevator system using GHDL and GTKWave

echo "Compiling elevator system with GHDL..."

# Clean previous compilation
rm -f *.o *.cf tb_elevator_system elevator_system.vcd

# Change to src directory
cd ../src || exit 1

# Compile sources in dependency order
echo "Compiling timer..."
ghdl -a --std=08 timer.vhd

echo "Compiling elevator_controller..."
ghdl -a --std=08 elevator_controller.vhd

echo "Compiling request_handler..."
ghdl -a --std=08 request_handler.vhd

echo "Compiling elevator_system..."
ghdl -a --std=08 elevator_system.vhd

echo "Compiling testbench..."
ghdl -a --std=08 ./testbenches/tb_elevator_system.vhd

# Elaborate the testbench
echo "Elaborating testbench..."
ghdl -e --std=08 tb_elevator_system

# Run simulation and generate VCD file
echo "Running simulation..."
ghdl -r --std=08 tb_elevator_system --vcd=elevator_system.vcd --stop-time=300us

echo "Done!"
