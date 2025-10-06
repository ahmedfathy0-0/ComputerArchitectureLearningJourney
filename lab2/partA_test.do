# Compile the VHDL files
vcom -2008 full_adder.vhd
vcom -2008 partA.vhd

# Start simulation
vsim -gui work.partA_alsu -g n=8

# Add waves to the waveform viewer
add wave -position insertpoint \
sim:/partA_alsu/A \
sim:/partA_alsu/B \
sim:/partA_alsu/cin \
sim:/partA_alsu/selector \
sim:/partA_alsu/F \
sim:/partA_alsu/Cout

# Configure radix for hex display
radix hex

# Test Case 1: F = A (S1S0=00, Cin=0)
# A=0F, B=don't care, Cin=0, Expected F=0F, Cout=0
force -freeze sim:/partA_alsu/A 16#0F
force -freeze sim:/partA_alsu/B 16#00
force -freeze sim:/partA_alsu/cin 0
force -freeze sim:/partA_alsu/selector 2#00
run 10ns

# Test Case 2: F = A + B (S1S0=01, Cin=0)
# A=0F, B=0001, Cin=0, Expected F=10, Cout=0
force -freeze sim:/partA_alsu/A 16#0F
force -freeze sim:/partA_alsu/B 16#01
force -freeze sim:/partA_alsu/cin 0
force -freeze sim:/partA_alsu/selector 2#01
run 10ns

# Test Case 3: F = A + B (S1S0=01, Cin=0)
# A=FF, B=0001, Cin=0, Expected F=00, Cout=1
force -freeze sim:/partA_alsu/A 16#FF
force -freeze sim:/partA_alsu/B 16#01
force -freeze sim:/partA_alsu/cin 0
force -freeze sim:/partA_alsu/selector 2#01
run 10ns

# Test Case 4: F = A - B - 1 (S1S0=10, Cin=0)
# A=FF, B=0001, Cin=0, Expected F=FD, Cout=1
force -freeze sim:/partA_alsu/A 16#FF
force -freeze sim:/partA_alsu/B 16#01
force -freeze sim:/partA_alsu/cin 0
force -freeze sim:/partA_alsu/selector 2#10
run 10ns

# Test Case 5: F = A - 1 (S1S0=11, Cin=0)
# A=FF, B=don't care, Cin=0, Expected F=FE, Cout=1
force -freeze sim:/partA_alsu/A 16#FF
force -freeze sim:/partA_alsu/B 16#00
force -freeze sim:/partA_alsu/cin 0
force -freeze sim:/partA_alsu/selector 2#11
run 10ns

# Test Case 6: F = A + 1 (S1S0=00, Cin=1)
# A=0E, B=don't care, Cin=1, Expected F=0F, Cout=0
force -freeze sim:/partA_alsu/A 16#0E
force -freeze sim:/partA_alsu/B 16#00
force -freeze sim:/partA_alsu/cin 1
force -freeze sim:/partA_alsu/selector 2#00
run 10ns

# Test Case 7: F = A + B + 1 (S1S0=01, Cin=1)
# A=FF, B=0001, Cin=1, Expected F=01, Cout=1
force -freeze sim:/partA_alsu/A 16#FF
force -freeze sim:/partA_alsu/B 16#01
force -freeze sim:/partA_alsu/cin 1
force -freeze sim:/partA_alsu/selector 2#01
run 10ns

# Test Case 8: F = A - B (S1S0=10, Cin=1)
# A=0F, B=0001, Cin=1, Expected F=0E, Cout=1
force -freeze sim:/partA_alsu/A 16#0F
force -freeze sim:/partA_alsu/B 16#01
force -freeze sim:/partA_alsu/cin 1
force -freeze sim:/partA_alsu/selector 2#10
run 10ns

# Test Case 9: F = 0 (S1S0=11, Cin=1)
# A=F0, B=don't care, Cin=1, Expected F=00, Cout=0
force -freeze sim:/partA_alsu/A 16#F0
force -freeze sim:/partA_alsu/B 16#00
force -freeze sim:/partA_alsu/cin 1
force -freeze sim:/partA_alsu/selector 2#11
run 10ns

wave zoom full

echo "Expected Results:"
echo "  Test 1: F=0F, Cout=0"
echo "  Test 2: F=10, Cout=0"
echo "  Test 3: F=00, Cout=1"
echo "  Test 4: F=FD, Cout=1"
echo "  Test 5: F=FE, Cout=1"
echo "  Test 6: F=0F, Cout=0"
echo "  Test 7: F=01, Cout=1"
echo "  Test 8: F=0E, Cout=1"
echo "  Test 9: F=00, Cout=0"
