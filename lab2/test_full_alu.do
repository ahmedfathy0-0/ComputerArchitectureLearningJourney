vcom -2008 full_adder.vhd
vcom -2008 partA.vhd
vcom -2008 partB.vhd
vcom -2008 partC.vhd
vcom -2008 partD.vhd
vcom -2008 ALU.vhd

vsim -gui work.ALU -g n=8

add wave -position insertpoint \
sim:/ALU/A \
sim:/ALU/B \
sim:/ALU/Cin \
sim:/ALU/S \
sim:/ALU/F \
sim:/ALU/Cout

radix hex

echo "=========================================="
echo "PART A (S3=0, S2=0)"
echo "=========================================="

# Test Case 1: F = A (S=0000, Cin=0)
# A=0F, B=don't care, Cin=0, Expected F=0F, Cout=0
force -freeze sim:/ALU/A 8'h0F
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0000
run 10ns
echo "Test 1: F=A | Expected: F=0F, Cout=0"

# Test Case 2: F = A + B (S=0001, Cin=0)
# A=0F, B=0001, Cin=0, Expected F=10, Cout=0
force -freeze sim:/ALU/A 8'h0F
force -freeze sim:/ALU/B 8'h01
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0001
run 10ns
echo "Test 2: F=A+B | Expected: F=10, Cout=0"

# Test Case 3: F = A + B (S=0001, Cin=0)
# A=FF, B=0001, Cin=0, Expected F=00, Cout=1
force -freeze sim:/ALU/A 8'hFF
force -freeze sim:/ALU/B 8'h01
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0001
run 10ns
echo "Test 3: F=A+B (overflow) | Expected: F=00, Cout=1"

# Test Case 4: F = A - B - 1 (S=0010, Cin=0)
# A=FF, B=0001, Cin=0, Expected F=FD, Cout=1
force -freeze sim:/ALU/A 8'hFF
force -freeze sim:/ALU/B 8'h01
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0010
run 10ns
echo "Test 4: F=A-B-1 | Expected: F=FD, Cout=1"

# Test Case 5: F = A - 1 (S=0011, Cin=0)
# A=FF, B=don't care, Cin=0, Expected F=FE, Cout=1
force -freeze sim:/ALU/A 8'hFF
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0011
run 10ns
echo "Test 5: F=A-1 | Expected: F=FE, Cout=1"

# Test Case 6: F = A + 1 (S=0000, Cin=1)
# A=0E, B=don't care, Cin=1, Expected F=0F, Cout=0
force -freeze sim:/ALU/A 8'h0E
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 1
force -freeze sim:/ALU/S 4'b0000
run 10ns
echo "Test 6: F=A+1 | Expected: F=0F, Cout=0"

# Test Case 7: F = A + B + 1 (S=0001, Cin=1)
# A=FF, B=0001, Cin=1, Expected F=01, Cout=1
force -freeze sim:/ALU/A 8'hFF
force -freeze sim:/ALU/B 8'h01
force -freeze sim:/ALU/Cin 1
force -freeze sim:/ALU/S 4'b0001
run 10ns
echo "Test 7: F=A+B+1 | Expected: F=01, Cout=1"

# Test Case 8: F = A - B (S=0010, Cin=1)
# A=0F, B=0001, Cin=1, Expected F=0E, Cout=1
force -freeze sim:/ALU/A 8'h0F
force -freeze sim:/ALU/B 8'h01
force -freeze sim:/ALU/Cin 1
force -freeze sim:/ALU/S 4'b0010
run 10ns
echo "Test 8: F=A-B | Expected: F=0E, Cout=1"

# Test Case 9: F = 0 (S=0011, Cin=1)
# A=F0, B=don't care, Cin=1, Expected F=00, Cout=0
force -freeze sim:/ALU/A 8'hF0
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 1
force -freeze sim:/ALU/S 4'b0011
run 10ns
echo "Test 9: F=0 | Expected: F=00, Cout=0"

echo "=========================================="
echo "PART B (S3=0, S2=1)"
echo "=========================================="

# Test Case 10: AND (S=0100)
# A=F5, B=AA, Expected F=A0
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'hAA
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0100
run 10ns
echo "Test 10: F=A AND B | Expected: F=A0"

# Test Case 11: OR (S=0101)
# A=F5, B=AA, Expected F=FF
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'hAA
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0101
run 10ns
echo "Test 11: F=A OR B | Expected: F=FF"

# Test Case 12: NOR (S=0110)
# A=F5, B=AA, Expected F=00
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'hAA
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0110
run 10ns
echo "Test 12: F=A NOR B | Expected: F=00"

# Test Case 13: NOT (S=0111)
# A=F5, B=don't care, Expected F=0A
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0111
run 10ns
echo "Test 13: F=NOT A | Expected: F=0A"

echo "=========================================="
echo "PART C (S3=1, S2=0)"
echo "=========================================="

# Test Case 14: Logic Shift Right (S=1000)
# A=F5, Expected F=7A, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1000
run 10ns
echo "Test 14: F=LSR A | Expected: F=7A, Cout=1"

# Test Case 15: Rotate Right (S=1001)
# A=F5, Expected F=FA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1001
run 10ns
echo "Test 15: F=ROR A | Expected: F=FA, Cout=1"

# Test Case 16: Rotate Right with Carry (S=1010, Cin=0)
# A=F5, Cin=0, Expected F=7A, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1010
run 10ns
echo "Test 16: F=RRC A (Cin=0) | Expected: F=7A, Cout=1"

# Test Case 17: Rotate Right with Carry (S=1010, Cin=1)
# A=F5, Cin=1, Expected F=FA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 1
force -freeze sim:/ALU/S 4'b1010
run 10ns
echo "Test 17: F=RRC A (Cin=1) | Expected: F=FA, Cout=1"

# Test Case 18: Arithmetic Shift Right (S=1011)
# A=F5, Expected F=FA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1011
run 10ns
echo "Test 18: F=ASR A | Expected: F=FA, Cout=1"

echo "=========================================="
echo "PART D (S3=1, S2=1)"
echo "=========================================="

# Test Case 19: Logic Shift Left (S=1100)
# A=F5, Expected F=EA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1100
run 10ns
echo "Test 19: F=LSL A | Expected: F=EA, Cout=1"

# Test Case 20: Rotate Left (S=1101)
# A=F5, Expected F=EB, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1101
run 10ns
echo "Test 20: F=ROL A | Expected: F=EB, Cout=1"

# Test Case 21: Rotate Left with Carry (S=1110, Cin=0)
# A=F5, Cin=0, Expected F=EA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1110
run 10ns
echo "Test 21: F=RLC A (Cin=0) | Expected: F=EA, Cout=1"

# Test Case 22: Rotate Left with Carry (S=1110, Cin=1)
# A=F5, Cin=1, Expected F=EB, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 1
force -freeze sim:/ALU/S 4'b1110
run 10ns
echo "Test 22: F=RLC A (Cin=1) | Expected: F=EB, Cout=1"

# Test Case 23: F=0000 (S=1111)
# A=F5, Expected F=00, Cout=0
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1111
run 10ns
echo "Test 23: F=0000 | Expected: F=00, Cout=0"

# Test Case 24: Additional Rotate Right test (S=1001)
# A=7A, Expected F=3D, Cout=0
force -freeze sim:/ALU/A 8'h7A
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1001
run 10ns
echo "Test 24: F=ROR A | Expected: F=3D, Cout=0"

wave zoom full
