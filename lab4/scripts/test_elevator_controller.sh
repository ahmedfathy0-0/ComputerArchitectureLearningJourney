#!/bin/bash

# Script to compile and run elevator controller simulation with GHDL
# View waveforms with GTKWave

echo "===== Elevator Controller Simulation ====="
echo ""

# Clean previous compilation
echo "Cleaning previous build..."
rm -f *.o *.cf *.vcd elevator_ctrl_tb work-obj93.cf

# Create work directory if needed
mkdir -p work

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
ghdl -a --std=08 --work=work elevator_ctrl_tb.vhd
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to compile elevator_ctrl_tb.vhd"
    exit 1
fi

echo ""
echo "===== Elaborating design ====="
ghdl -e --std=08 --work=work elevator_ctrl_tb
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to elaborate testbench"
    exit 1
fi

echo ""
echo "===== Running simulation ====="
echo "(Generating VCD waveform file: elevator_ctrl_tb.vcd)"
ghdl -r --std=08 --work=work elevator_ctrl_tb --vcd=elevator_ctrl_tb.vcd --stop-time=10ms
if [ $? -ne 0 ]; then
    echo "ERROR: Simulation failed"
    exit 1
fi

echo ""
echo "===== Simulation complete ====="
echo ""
echo "VCD file generated: elevator_ctrl_tb.vcd"
echo ""
echo "To view waveforms, run:"
echo "  gtkwave elevator_ctrl_tb.vcd"
echo ""

echo ""
echo "Done!"