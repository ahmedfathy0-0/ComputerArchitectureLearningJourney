#!/bin/bash

# Compile and simulate the complete elevator system using GHDL and GTKWave

echo "Compiling elevator system with GHDL..."

# Clean previous compilation
rm -f *.o *.cf tb_elevator_controller elevator_system.vcd

# Change to src directory
cd ../src || exit 1

echo ""
echo "===== Compiling VHDL files ====="

# Compile in dependency order

echo "1. Compiling timer..."
ghdl -a --std=08 --work=work timer.vhd
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to compile timer.vhd"
    exit 1
fi

echo "2. Compiling request_handler..."
ghdl -a --std=08 --work=work request_handler.vhd
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to compile request_handler.vhd"
    exit 1
fi

echo "3. Compiling elevator_controller..."
ghdl -a --std=08 --work=work elevator_controller.vhd
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to compile elevator_controller.vhd"
    exit 1
fi

echo "4. Compiling testbench..."
ghdl -a --std=08 --work=work ./testbenches/tb_elevator_controller.vhd
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to compile tb_elevator_controller.vhd"
    exit 1
fi

echo ""
echo "===== Elaborating design ====="
ghdl -e --std=08 --work=work tb_elevator_controller
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to elaborate testbench"
    exit 1
fi

echo ""
echo "===== Running simulation ====="
echo "(Generating VCD waveform file: tb_elevator_controller.vcd)"
ghdl -r --std=08 --work=work tb_elevator_controller --vcd=./testbenches/tb_elevator_controller.vcd --stop-time=10ms
if [ $? -ne 0 ]; then
    echo "ERROR: Simulation failed"
    exit 1
fi