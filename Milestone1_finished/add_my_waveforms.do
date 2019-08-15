

# add waves to waveform
add wave Clock_50
add wave -divider {some label for my divider}
add wave uut/SRAM_we_n
add wave -decimal uut/SRAM_write_data
add wave -decimal uut/SRAM_read_data
add wave -hexadecimal uut/SRAM_address
add wave -hexadecimal uut/M1_start
add wave -hexadecimal uut/top_state

add wave -hexadecimal uut/M1_unit/M1_state
add wave -unsigned uut/M1_unit/SRAM_we_n
add wave -unsigned uut/M1_unit/SRAM_address
add wave -hexadecimal uut/M1_unit/SRAM_read_data

add wave -hexadecimal uut/M1_unit/U_register
add wave -hexadecimal uut/M1_unit/V_register
add wave -hexadecimal uut/M1_unit/Y_register
add wave -unsigned uut/M1_unit/RGB_address
add wave -hexadecimal uut/M1_unit/SRAM_write_data


add wave -unsigned uut/M1_unit/U_prime_buf
add wave -unsigned uut/M1_unit/V_prime_buf

add wave -unsigned uut/M1_unit/Mult_result_1
add wave -unsigned uut/M1_unit/Mult_result_2
add wave -unsigned uut/M1_unit/Mult_result_3

add wave -unsigned uut/M1_unit/Mult_1_op1
add wave -unsigned uut/M1_unit/Mult_1_op2
add wave -unsigned uut/M1_unit/Mult_2_op1
add wave -unsigned uut/M1_unit/Mult_2_op2
add wave -unsigned uut/M1_unit/Mult_3_op1
add wave -unsigned uut/M1_unit/Mult_3_op2

add wave -unsigned uut/M1_unit/U_shift_reg
add wave -unsigned uut/M1_unit/V_shift_reg

add wave -hexadecimal uut/M1_unit/R_register
add wave -hexadecimal uut/M1_unit/G_register
add wave -hexadecimal uut/M1_unit/B_register

add wave -unsigned uut/M1_unit/Common_Y_Value

add wave -hexadecimal uut/M1_unit/Y_address
add wave -hexadecimal uut/M1_unit/V_address
add wave -hexadecimal uut/M1_unit/U_address











