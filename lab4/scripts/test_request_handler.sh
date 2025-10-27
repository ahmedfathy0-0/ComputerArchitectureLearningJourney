#!/bin/bash

echo "Compiling Request_handler..."
ghdl -a --std=08 ./src/request_handler.vhd || exit 1

echo "Compiling testbench..."
ghdl -a --std=08 ./src/testbenches/tb_request_handler.vhd || exit 1

echo "Elaborating testbench..."
ghdl -e --std=08 tb_request_handler || exit 1  # Use 'tb_request_handler' without the path

echo "Running simulation..."
ghdl -r --std=08 tb_request_handler --wave=./wave.ghw --stop-time=2us || exit 1  # Run with 'tb_request_handler' directly

echo ""
echo "Done! Open waveforms with:"
echo "  gtkwave wave.ghw"