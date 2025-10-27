#!/bin/bash

echo "Compiling Request_handler..."
ghdl -a --std=08 ./src/Request_handler.vhd || exit 1

echo "Compiling testbench..."
ghdl -a --std=08 ./src/Request_handler_tb.vhd || exit 1

echo "Elaborating testbench..."
ghdl -e --std=08 Request_handler_tb || exit 1  # Use 'Request_handler_tb' without the path

echo "Running simulation..."
ghdl -r --std=08 Request_handler_tb --wave=./wave.ghw --stop-time=2us || exit 1  # Run with 'Request_handler_tb' directly

echo ""
echo "Done! Open waveforms with:"
echo "  gtkwave wave.ghw"