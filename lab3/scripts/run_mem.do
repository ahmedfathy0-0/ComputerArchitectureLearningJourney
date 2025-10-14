quit -sim
catch {vdel -all -lib work}

vlib work

vcom -2008 src/register_file_mem.vhd

vsim -gui work.register_file_mem

add wave -position insertpoint \
sim:/register_file_mem/clk \
sim:/register_file_mem/rst \
sim:/register_file_mem/write_enable \
sim:/register_file_mem/address_write \
sim:/register_file_mem/address_read_a \
sim:/register_file_mem/address_read_b \
sim:/register_file_mem/data_in \
sim:/register_file_mem/data_out_a \
sim:/register_file_mem/data_out_b \
sim:/register_file_mem/ram_array ;# Add the internal RAM signal to waves

radix hex

force -deposit sim:/register_file_mem/clk 0 0, 1 {5 ns} -repeat 10ns

echo "=========================================="
echo "Register File Test Cases - Based on Expected Table"
echo "=========================================="

force sim:/register_file_mem/rst 1 ;# Assert reset
force sim:/register_file_mem/write_enable 0
force sim:/register_file_mem/address_read_a B"000"
force sim:/register_file_mem/address_read_b B"000"
force sim:/register_file_mem/address_write B"000"
force sim:/register_file_mem/data_in X"00"
run 1ns ;# Let forces propagate before the first clock edge

# --- Cycle 1 ---
# Expected: Read Port 0 = 00, Read Port 1 = 00
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "00"
set expected_b "00"
echo "Cycle 1: Reset"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"

force sim:/register_file_mem/rst 0 ;# De-assert reset after the first cycle


# --- Cycle 2 ---
# Action: Write in Reg(0) 0xFF
# Expected: Read Port 0 = FF, Read Port 1 = FF
force sim:/register_file_mem/write_enable 1
force sim:/register_file_mem/address_write B"000"
force sim:/register_file_mem/data_in X"FF"
force sim:/register_file_mem/address_read_a B"000" ;# Still reading Reg(0)
force sim:/register_file_mem/address_read_b B"000" ;# Still reading Reg(0)
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "FF"
set expected_b "FF"
echo "Cycle 2: Write FF to Reg(0)"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"


# --- Cycle 3 ---
# Action: Write in Reg(1) 0x11
# Expected: Read Port 0 = FF, Read Port 1 = FF
force sim:/register_file_mem/address_write B"001"
force sim:/register_file_mem/data_in X"11"
force sim:/register_file_mem/address_read_a B"000" ;# Still reading Reg(0)
force sim:/register_file_mem/address_read_b B"000" ;# Still reading Reg(0)
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "FF"
set expected_b "FF"
echo "Cycle 3: Write 11 to Reg(1)"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"


# --- Cycle 4 ---
# Action: Write in Reg(7) 0x90
# Expected: Read Port 0 = FF, Read Port 1 = FF
force sim:/register_file_mem/address_write B"111"
force sim:/register_file_mem/data_in X"90"
force sim:/register_file_mem/address_read_a B"000" ;# Still reading Reg(0)
force sim:/register_file_mem/address_read_b B"000" ;# Still reading Reg(0)
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "FF"
set expected_b "FF"
echo "Cycle 4: Write 90 to Reg(7)"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"


# --- Cycle 5 ---
# Action: Write in Reg(3) 0x08
# Expected: Read Port 0 = FF, Read Port 1 = FF
force sim:/register_file_mem/address_write B"011"
force sim:/register_file_mem/data_in X"08"
force sim:/register_file_mem/address_read_a B"000" ;# Still reading Reg(0)
force sim:/register_file_mem/address_read_b B"000" ;# Still reading Reg(0)
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "FF"
set expected_b "FF"
echo "Cycle 5: Write 08 to Reg(3)"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"


# --- Cycle 6 ---
# Action: Read Reg(1) on port 0, Reg(7) on port 1 AND write 0x03 to Reg(4)
# Expected: Read Port 0 = 11, Read Port 1 = 90
force sim:/register_file_mem/address_read_a B"001" ;# Read Reg(1)
force sim:/register_file_mem/address_read_b B"111" ;# Read Reg(7)
force sim:/register_file_mem/write_enable 1
force sim:/register_file_mem/address_write B"100" ;# Write to Reg(4)
force sim:/register_file_mem/data_in X"03"
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "11"
set expected_b "90"
echo "Cycle 6: Read Reg(1) & Reg(7), Write 03 to Reg(4)"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"


# --- Cycle 7 ---
# Action: Read Reg(2) on port 0, Reg(3) on port 1. (No explicit write operation this cycle)
# Expected: Read Port 0 = 00, Read Port 1 = 08
force sim:/register_file_mem/write_enable 0 ;# No write operation this cycle
force sim:/register_file_mem/address_read_a B"010" ;# Read Reg(2)
force sim:/register_file_mem/address_read_b B"011" ;# Read Reg(3)
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "00"
set expected_b "08"
echo "Cycle 7: Read Reg(2) & Reg(3)"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"


# --- Cycle 8 ---
# Action: Read Reg(4) on port 0, Reg(5) on port 1. (No explicit write operation this cycle)
# Expected: Read Port 0 = 03, Read Port 1 = 00
force sim:/register_file_mem/address_read_a B"100" ;# Read Reg(4) (contains 03 from Cycle 6)
force sim:/register_file_mem/address_read_b B"101" ;# Read Reg(5) (default 00)
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "03"
set expected_b "00"
echo "Cycle 8: Read Reg(4) & Reg(5)"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"


# --- Cycle 9 ---
# Action: Read Reg(6) on port 0, Reg(0) on port 1 AND write 0x01 to Reg(0)
# Expected: Read Port 0 = 00, Read Port 1 = 01
force sim:/register_file_mem/write_enable 1
force sim:/register_file_mem/address_read_a B"110" ;# Read Reg(6) (default 00)
force sim:/register_file_mem/address_read_b B"000" ;# Read Reg(0)
force sim:/register_file_mem/address_write B"000" ;# Write to Reg(0)
force sim:/register_file_mem/data_in X"01"
run 10ns ;# Advance by one clock cycle
set actual_a [examine -radix hexadecimal sim:/register_file_mem/data_out_a]
set actual_b [examine -radix hexadecimal sim:/register_file_mem/data_out_b]
set expected_a "00"
set expected_b "01"
echo "Cycle 9: Read Reg(6) & Reg(0), Write 01 to Reg(0)"
echo "  Actual Port_A: $actual_a, Actual Port_B: $actual_b"
echo "  Expected Port_A: $expected_a, Expected Port_B: $expected_b"
if {$actual_a == $expected_a && $actual_b == $expected_b} { echo "  PASS" } else { echo "  FAIL - Mismatch detected!" }
echo "------------------------------------------"


# Final run to ensure all operations are complete and view final state
run 20ns

echo "=========================================="
echo "All tests completed!"
echo "=========================================="

# Zoom to fit all signals in the waveform window
wave zoom full
