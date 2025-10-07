quit -sim
vdel -all -lib work

vlib work

vcom -2008 partB_alu8imux.vhd
vcom -2008 partC_alu8imux.vhd
vcom -2008 partD_alu8imux.vhd
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
if {[examine -value sim:/ALU/F] == "A0"} {
    echo "PASS"
} else {
    echo "FAIL - Actual: [examine -value sim:/ALU/F]"
}

# Test Case 11: OR (S=0101)
# A=F5, B=AA, Expected F=FF
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'hAA
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0101
run 10ns
echo "Test 11: F=A OR B | Expected: F=FF"
if {[examine -value sim:/ALU/F] == "FF"} {
    echo "PASS"
} else {
    echo "FAIL - Actual: [examine -value sim:/ALU/F]"
}

# Test Case 12: NOR (S=0110)
# A=F5, B=AA, Expected F=00
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'hAA
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0110
run 10ns
echo "Test 12: F=A NOR B | Expected: F=00"
if {[examine -value sim:/ALU/F] == "00"} {
    echo "PASS"
} else {
    echo "FAIL - Actual: [examine -value sim:/ALU/F]"
}

# Test Case 13: NOT (S=0111)
# A=F5, B=don't care, Expected F=0A
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b0111
run 10ns
echo "Test 13: F=NOT A | Expected: F=0A"
if {[examine -value sim:/ALU/F] == "0A"} {
    echo "PASS"
} else {
    echo "FAIL - Actual: [examine -value sim:/ALU/F]"
}

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
if {[examine -value sim:/ALU/F] == "7A" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 15: Rotate Right (S=1001)
# A=F5, Expected F=FA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1001
run 10ns
echo "Test 15: F=ROR A | Expected: F=FA, Cout=1"
if {[examine -value sim:/ALU/F] == "FA" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 16: Rotate Right with Carry (S=1010, Cin=0)
# A=F5, Cin=0, Expected F=7A, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1010
run 10ns
echo "Test 16: F=RRC A (Cin=0) | Expected: F=7A, Cout=1"
if {[examine -value sim:/ALU/F] == "7A" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 17: Rotate Right with Carry (S=1010, Cin=1)
# A=F5, Cin=1, Expected F=FA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 1
force -freeze sim:/ALU/S 4'b1010
run 10ns
echo "Test 17: F=RRC A (Cin=1) | Expected: F=FA, Cout=1"
if {[examine -value sim:/ALU/F] == "FA" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 18: Arithmetic Shift Right (S=1011)
# A=F5, Expected F=FA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1011
run 10ns
echo "Test 18: F=ASR A | Expected: F=FA, Cout=1"
if {[examine -value sim:/ALU/F] == "FA" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

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
if {[examine -value sim:/ALU/F] == "EA" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 20: Rotate Left (S=1101)
# A=F5, Expected F=EB, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1101
run 10ns
echo "Test 20: F=ROL A | Expected: F=EB, Cout=1"
if {[examine -value sim:/ALU/F] == "EB" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 21: Rotate Left with Carry (S=1110, Cin=0)
# A=F5, Cin=0, Expected F=EA, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1110
run 10ns
echo "Test 21: F=RLC A (Cin=0) | Expected: F=EA, Cout=1"
if {[examine -value sim:/ALU/F] == "EA" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 22: Rotate Left with Carry (S=1110, Cin=1)
# A=F5, Cin=1, Expected F=EB, Cout=1
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 1
force -freeze sim:/ALU/S 4'b1110
run 10ns
echo "Test 22: F=RLC A (Cin=1) | Expected: F=EB, Cout=1"
if {[examine -value sim:/ALU/F] == "EB" && [examine -value sim:/ALU/Cout] == "1"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 23: F=0000 (S=1111)
# A=F5, Expected F=00, Cout=0
force -freeze sim:/ALU/A 8'hF5
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1111
run 10ns
echo "Test 23: F=0000 | Expected: F=00, Cout=0"
if {[examine -value sim:/ALU/F] == "00" && [examine -value sim:/ALU/Cout] == "0"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

# Test Case 24: Additional Rotate Right test (S=1001)
# A=7A, Expected F=3D, Cout=0
force -freeze sim:/ALU/A 8'h7A
force -freeze sim:/ALU/B 8'h00
force -freeze sim:/ALU/Cin 0
force -freeze sim:/ALU/S 4'b1001
run 10ns
echo "Test 24: F=ROR A | Expected: F=3D, Cout=0"
if {[examine -value sim:/ALU/F] == "3D" && [examine -value sim:/ALU/Cout] == "0"} {
    echo "PASS"
} else {
    echo "FAIL - Actual F: [examine -value sim:/ALU/F], Cout: [examine -value sim:/ALU/Cout]"
}

wave zoom full