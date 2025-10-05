# Clean up previous compilation
quit -sim
vdel -all -lib work

# Create work library
vlib work

# Compile all design files in order
echo "Compiling partB_alu8imux..."
vcom -work work -2002 -explicit partB_alu8imux.vhd

echo "Compiling partC_alu8imux..."
vcom -work work -2002 -explicit partC_alu8imux.vhd

echo "Compiling partD_alu8imux..."
vcom -work work -2002 -explicit partD_alu8imux.vhd

echo "Compiling ALU..."
vcom -work work -2002 -explicit ALU.vhd

echo "Compiling testbench..."
vcom -work work -2002 -explicit tb_ALU.vhd

# Start simulation with full visibility
echo "Starting simulation..."
vsim -voptargs=+acc work.tb_ALU

# Add waves
add wave -radix binary -label "A" /tb_alu/a
add wave -radix binary -label "B" /tb_alu/b
add wave -radix binary -label "Cin" /tb_alu/cin
add wave -radix hexadecimal -label "S" /tb_alu/s
add wave -radix binary -label "F" /tb_alu/f
add wave -radix binary -label "Cout" /tb_alu/cout

# Configure wave window
wave zoom full

# Run simulation
echo "Running simulation..."
run -all

# Fit the wave window
wave zoom full

echo "Simulation complete!"