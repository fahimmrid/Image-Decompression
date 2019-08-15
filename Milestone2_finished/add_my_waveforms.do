

# add waves to waveform
add wave Clock_50
add wave -divider {some label for my divider}
add wave uut/SRAM_we_n
add wave -decimal uut/SRAM_write_data
add wave -decimal uut/SRAM_read_data
add wave -decimal uut/SRAM_address
add wave -hexadecimal uut/M1_start
add wave -hexadecimal uut/top_state

add wave -hexadecimal uut/M1_unit/M1_state

add wave -hexadecimal uut/milestone2_unit/M2_state
add wave -unsigned uut/milestone2_unit/S_flag
add wave -unsigned uut/milestone2_unit/U_flag
add wave -unsigned uut/milestone2_unit/V_flag
add wave -unsigned uut/milestone2_unit/col_block
add wave -unsigned uut/milestone2_unit/row_block
add wave -unsigned uut/milestone2_unit/row_index
add wave -unsigned uut/milestone2_unit/column_index
add wave -unsigned uut/milestone2_unit/M2_SRAM_address
add wave -unsigned uut/milestone2_unit/s_counter
add wave -unsigned uut/milestone2_unit/column_address
add wave -unsigned uut/milestone2_unit/row_address
add wave -unsigned uut/milestone2_unit/write_counter
add wave -unsigned uut/milestone2_unit/write_counter2
add wave -unsigned uut/milestone2_unit/write_counter3

add wave -hexadecimal uut/milestone2_unit/SRAM_read_data
add wave -signed uut/milestone2_unit/read_data_a
add wave -signed uut/milestone2_unit/read_data_b
add wave -signed uut/milestone2_unit/write_data_a
add wave -signed uut/milestone2_unit/write_data_b
add wave -unsigned uut/milestone2_unit/address_a
add wave -unsigned uut/milestone2_unit/address_b
add wave uut/milestone2_unit/write_enable_a
add wave uut/milestone2_unit/write_enable_b
add wave -unsigned uut/milestone2_unit/adress_counter
add wave -unsigned uut/milestone2_unit/adress_counter2
add wave -unsigned uut/milestone2_unit/adress_counter3
add wave -signed uut/milestone2_unit/data
add wave -signed uut/milestone2_unit/data2
add wave -signed uut/milestone2_unit/data3
add wave -signed uut/milestone2_unit/data4
add wave -signed uut/milestone2_unit/tempCounter
add wave -hexadecimal uut/milestone2_unit/data_buff1
add wave -hexadecimal uut/milestone2_unit/data_buff2
add wave -hexadecimal uut/milestone2_unit/data_buff3
add wave -hexadecimal uut/milestone2_unit/data_buff4

add wave -signed uut/milestone2_unit/Mult_result_1
add wave -signed uut/milestone2_unit/Mult_result_2
add wave -signed uut/milestone2_unit/Mult_result_3
add wave -signed uut/milestone2_unit/Mult_result_4

add wave -unsigned uut/milestone2_unit/Mult_1_op1
add wave -unsigned uut/milestone2_unit/Mult_1_op2
add wave -unsigned uut/milestone2_unit/Mult_2_op1
add wave -unsigned uut/milestone2_unit/Mult_2_op2
add wave -unsigned uut/milestone2_unit/Mult_3_op1
add wave -unsigned uut/milestone2_unit/Mult_3_op2
add wave -unsigned uut/milestone2_unit/Mult_4_op1
add wave -unsigned uut/milestone2_unit/Mult_4_op2

add wave -divider {some label for my divider}


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

add wave -decimal num_mismatches 











