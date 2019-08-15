// Copyright by Adam Kinsman and Henry Ko and Nicola Nicolici
// Developed for the Digital Systems Design course (COE3DQ4)
// Department of Electrical and Computer Engineering
// McMaster University
// Ontario, Canada

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

// This module generates the address for reading the SRAM
// in order to display the image on the screen
module milestone2 (

   input  logic            clock,
   input  logic            Resetn,
   output logic   [17:0]   M2_SRAM_address,
   
   input  logic   [15:0]   SRAM_read_data,
   input  logic            M2_start,
   
   output logic            SRAM_we_n,
   output logic   [15:0]   SRAM_write_data,
   
  // input  logic   [7:0]    DPRAM_address_a, 
//   output logic   [7:0]    DPRAM_address_b,
   
   output logic            M2_end
	
	
);
logic [6:0] address_a [2:0];
logic [6:0] address_b [2:0];
logic [31:0] write_data_a [2:0];
logic [31:0] write_data_b [2:0];
logic write_enable_a [2:0];
logic write_enable_b [2:0];
logic [31:0] read_data_a [2:0];
logic [31:0] read_data_b [2:0];
	// Instantiate RAM0
	dual_port_RAM0 dual_port_RAM_inst0 (
		.address_a ( address_a[0] ),
		.address_b ( address_b[0] ),
		.clock ( clock ),
		.data_a ( write_data_a[0]),
		.data_b ( write_data_b[0] ),
		.wren_a ( write_enable_a[0]),
		.wren_b ( write_enable_b[0] ),
		.q_a ( read_data_a[0] ),
		.q_b ( read_data_b[0] )
	);
	// Instantiate RAM1
	dual_port_RAM1 dual_port_RAM_inst1 (
		.address_a ( address_a[1] ),
		.address_b ( address_b[1] ),
		.clock ( clock ),
		.data_a ( write_data_a[1]),
		.data_b ( write_data_b[1] ),
		.wren_a ( write_enable_a[1]),
		.wren_b ( write_enable_b[1] ),
		.q_a ( read_data_a[1] ),
		.q_b ( read_data_b[1] )
	);
	// Instantiate RAM2
	dual_port_RAM2 dual_port_RAM_inst2 (
		.address_a ( address_a[2] ),
		.address_b ( address_b[2] ),
		.clock ( clock ),
		.data_a ( write_data_a[2]),
		.data_b ( write_data_b[2] ),
		.wren_a ( write_enable_a[2]),
		.wren_b ( write_enable_b[2] ),
		.q_a ( read_data_a[2] ),
		.q_b ( read_data_b[2] )
	);
	/*
		// RAM0
	 logic   [6:0]    RAM0_Address_0;
	  logic   [31:0]   Data_in_0;
	 logic            Write_en_0;
	 logic   [6:0]    RAM0_Address_1;
	  logic   [31:0]   Data_in_1;
	 logic            Write_en_1;
	 logic  [31:0]    Data_out_r0_1;
	 logic  [31:0]    Data_out_r0_2;
	
	//  RAM1
	 logic   [6:0]    RAM1_Address_2;
	  logic   [31:0]   Data_in_2;
	 logic            Write_en_2;
	 logic   [31:0]   Data_out_2;
	 logic   [6:0]    RAM1_Address_3;
	  logic   [31:0]   Data_in_3;
	 logic            Write_en_3;
	 logic   [31:0]   Data_out_3;
	
	//  RAM2
	 logic   [6:0]    RAM2_Address_4;
	  logic   [31:0]   Data_in_4;
	 logic            Write_en_4;
	 logic   [31:0]   Data_out_4;
	 logic   [6:0]    RAM2_Address_5;
	  logic   [31:0]   Data_in_5;
	 logic            Write_en_5;
	 logic   [31:0]   Data_out_5;
	
	
	*/
/* //when Y is done just go to next 2 states
enum logic [1:0]{
	Y_block,
	U_block,
	V_block
} plane_state;
*/
parameter 

pre_IDCT_Y =18'd76800, //offset for Y
pre_IDCT_U =18'd153600,
pre_IDCT_V =18'd192000;




logic [5:0] s_counter  ;  //6 bits?- 0 to 39
logic [2:0] row_index  ;
logic [2:0] column_index ;
 
logic [5:0] col_block ;
logic [4:0] row_block ;
logic [8:0] column_address;
logic [7:0] row_address;
logic [63:0] write_counter, write_counter2;
logic [100:0] write_counter3;
logic [63:0] adress_counter, adress_counter2, adress_counter3;
logic [31:0] result;
logic flag1;
logic [8:0] tempCounter;
//as diagram shown in class
//assign row_index =  s_counter [5:3] ;//fedding mul wires
//assign column_index = s_counter [2:0] ; 


assign s_counter = {row_index [2:0], column_index[2:0]};

assign column_address =  ((col_block)<<<3) + column_index;
assign row_address = ((row_block)<<<3) + row_index;


//assign column_address = {col_block, column_index}; //<<<8
//assign row_address = {row_block, row_index};


logic S_flag, V_flag, U_flag, donef;
logic last_block;

		
milestone2_state_type M2_state;
milestone2_state_type M2_OverallState;

logic [31:0] Mult_1_op1, Mult_2_op1, Mult_3_op1, Mult_4_op1 ;
logic [31:0] Mult_1_op2, Mult_2_op2, Mult_3_op2, Mult_4_op2 ; 
logic [63:0] Mult_result_1, Mult_result_2, Mult_result_3, Mult_result_4;



assign
	Mult_result_1 = (Mult_1_op1) * (Mult_1_op2),
	Mult_result_2 = (Mult_2_op1) * (Mult_2_op2),
	Mult_result_3 = (Mult_3_op1) * (Mult_3_op2),
	Mult_result_4 = (Mult_4_op1) * (Mult_4_op2);




logic [63:0] data, data2, data3, data4, data5;
logic [31:0] data_buff1, data_buff2, data_buff3, data_buff4,data_buff5, data_buff6, data_buff7, data_buff8;
logic [15:0] compute_T_x, compute_T_y;
always_comb begin
	if(SRAM_we_n == 1'b1)
		if(S_flag)
			M2_SRAM_address = (((row_address<<8) + (row_address<<6) + column_address)  + pre_IDCT_Y);
		else if(U_flag)
			M2_SRAM_address = (((row_address<<7) + (row_address<<5) + column_address)  + pre_IDCT_U);
		else
			M2_SRAM_address = (((row_address<<7) + (row_address<<5) + column_address)  + pre_IDCT_V);
//		else if(U_flag)
//			M2_SRAM_address = (((row_address<<8) + (row_address<<6) + column_address)  + pre_IDCT_U);
//		else
//			M2_SRAM_address = (((row_address<<8) + (row_address<<6) + column_address)  + pre_IDCT_V);
	else
		M2_SRAM_address = write_counter3 - 1'b1;
		
		data_buff1 = ((data) + (Mult_result_1));
		data_buff2 = ((data2) + (Mult_result_2));
		data_buff3 = ((data3) );
		data_buff4 = ((data4) );
		
		data_buff5 = data_buff1[31] ? 8'b0:(|data_buff1[30:24]? 8'd255:data_buff1[23:16]) ;//clipping
		data_buff6 = data_buff2[31] ? 8'b0:(|data_buff2[30:24]? 8'd255:data_buff2[23:16]) ;
		data_buff7 = data_buff3[31] ? 8'b0:(|data_buff3[30:24]? 8'd255:data_buff3[23:16]) ;
		data_buff8 = data_buff4[31] ? 8'b0:(|data_buff4[30:24]? 8'd255:data_buff4[23:16]) ;
	
	//data_buff1 = ($signed($signed(data) + $signed(Mult_result_1)) < 1'b0)? 63'b0: ((data) + (Mult_result_1))>>> 16;
	//data_buff2 = ($signed($signed(data2) + $signed(Mult_result_2))< 1'b0)? 63'b0:((data2) + (Mult_result_2))>>> 16;
	//data_buff3 = ($signed(data3)< 1'b0)? 63'b0:((data3))>>> 16;
	//data_buff4 = ($signed(data4)< 1'b0)? 63'b0:((data4))>>> 16;
end
always_ff @ (posedge clock or negedge Resetn) begin
	if (Resetn == 1'b0) begin
	
		M2_state <= M2_IDLE; //go to Y_block state

		SRAM_write_data <= 16'd0;
		
		col_block  <= 6'd0;
		row_block  <= 5'd0;
	//	s_counter <= 7'd0;
		row_index  <= 3'd0;
		column_index <= 3'd0;

		last_block <= 1'b0;
		S_flag <= 1'b0;
		V_flag <= 1'b0;
		U_flag <= 1'b0;
		SRAM_we_n <= 1'b1;
	
		address_a[0] <= 7'd0;
		address_b[0] <= 7'd0;
		address_a[1] <= 7'd0;
		address_b[1] <= 7'd0;
		address_a[2] <= 7'd0;
		address_b[2] <= 7'd0;
		write_data_a[0] <= 32'd0;
		write_data_b[0] <= 32'd0;
		write_data_a[1] <= 32'd0;
		write_data_b[1] <= 32'd0;
		write_data_a[2] <= 32'd0;
		write_data_b[2] <= 32'd0;
		write_enable_a[0] <= 1'd0;
		write_enable_b[0] <= 1'd0;
		write_enable_a[1] <= 1'd0;
		write_enable_b[1] <= 1'd0;
		write_enable_a[2] <= 1'd0;
		write_enable_b[2] <= 1'd0;
		
		write_counter <= 1'b0;
		write_counter2 <= 1'b0;
		write_counter3 <= 1'b0;
		adress_counter <= 1'b0;
		adress_counter2 <= 1'b0;
		adress_counter3 <= 1'b0;
		data <= 1'b0;
		data2 <= 1'b0;
		data3 <= 1'b0;
		data4 <= 1'b0;
		data5 <= 1'b0;
		flag1<= 1'b0;
		compute_T_x <= 1'b0;
		compute_T_y <= 1'b0;
		tempCounter <= 1'b0;
		donef <= 1'b0;
		result <= 1'b0;
	end else begin
		if (~M2_start) begin
	
			SRAM_write_data <= 16'd0;
			last_block <= 1'b0;
			S_flag <= 1'b0;
			V_flag <= 1'b0;
			U_flag <= 1'b0;
			SRAM_we_n <= 1'b1;
			
			col_block  <= 6'd0;
			row_block  <= 5'd0;
		  //s_counter <= 7'd0;
			row_index  <= 3'd0;
			column_index <= 3'd0;
	
			address_a[0] <= 7'd0;
			address_b[0] <= 7'd0;
			address_a[1] <= 7'd0;
			address_b[1] <= 7'd0;
			address_a[2] <= 7'd0;
			address_b[2] <= 7'd0;
			write_data_a[0] <= 32'd0;
			write_data_b[0] <= 32'd0;
			write_data_a[1] <= 32'd0;
			write_data_b[1] <= 32'd0;
			write_data_a[2] <= 32'd0;
			write_data_b[2] <= 32'd0;
			write_enable_a[0] <= 1'd0;
			write_enable_b[0] <= 1'd0;
			write_enable_a[1] <= 1'd0;
			write_enable_b[1] <= 1'd0;
			write_enable_a[2] <= 1'd0;
			write_enable_b[2] <= 1'd0;
			
			adress_counter <= 1'b0;
			result <= 1'b0;
			M2_state <= M2_IDLE;
			
		end else begin
			case (M2_state)
			M2_IDLE: begin
			  
				last_block <= 1'b0;
				S_flag <= 1'b1;
				//s_counter <= 1'b0;
				M2_state <= M2_DELAY;
				
			end

			M2_DELAY: begin
			
				M2_state <= M2_FETCH0;
			  
			  end

			M2_FETCH0 : begin
				column_index <= column_index + 1'b1;
				write_enable_a[0] <= 1'b0;
				M2_state <= M2_FETCH1;
			//s_counter <= s_counter + 1'd1;
			
			end
			
			M2_FETCH1 : begin
				M2_state <= SRAM_DELAY1;
				// address_a[0] <= 7'b1111111; // we set this to overflow to 0, 2cc write data at 0 location
			end
			
			
			SRAM_DELAY1: begin
			
				data <= SRAM_read_data;
				M2_state <= M2_FETCH2;
			end
			
			M2_FETCH2 : begin
				write_enable_a[0] <= 1'b1;//
				address_a[0] <= write_counter;//dp adress
				write_data_a [0] <= {data[15:0], SRAM_read_data[15:0]}; //go to 16 bit of write data
				column_index <= column_index + 1'b1;
				write_counter <= write_counter + 1'b1;
				
				if(column_index == 3'd7) begin
					row_index <= row_index + 1'b1;
					column_index <= 1'b0;
				end
					
				M2_state <= M2_FETCH0;
				
				if(column_index == 3'd7 && row_index == 3'd7) begin
					M2_state <= M2_COMPUTE_T0; 

					write_counter <= 1'b0;
					column_index <= 1'b0;                //resets
					row_index <= 1'b0;            
					

			    end

		    end
//--------------------------------Compute T----------------------------------
			M2_COMPUTE_T0 : begin
				write_enable_a[0] <= 1'b0;
				
				address_a[0] <= adress_counter; //adress we are reading
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;

				M2_state <= M2_COMPUTE_T1;

			end
			M2_COMPUTE_T1: begin
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
				M2_state <= M2_COMPUTE_T2;
			end
			
			M2_COMPUTE_T2: begin
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
			
				data <= Mult_result_1 + Mult_result_2;
				data2 <= Mult_result_3 + Mult_result_4;
				
				M2_state <= M2_COMPUTE_T3;
			end
			
			M2_COMPUTE_T3: begin 
				write_enable_a[2] <= 1'b0;
				
				address_a[0] <= adress_counter;
			
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter -2'd3;
				adress_counter2 <= adress_counter2 + 4'd5;
				
				data <= data + Mult_result_1 + Mult_result_2;
				data2 <= data2 + Mult_result_3 + Mult_result_4;
				
				M2_state <= M2_COMPUTE_T4;
				
				if(adress_counter == 8'd31&& adress_counter2 == 8'd27)begin  //end of reading
					M2_state <= M2_COMPUTE_T7;
				end
				else if(adress_counter2 == 8'd27) begin
					adress_counter2 <= 1'b0;
					adress_counter <= adress_counter + 1'b1;
				end
				
			end
			
			M2_COMPUTE_T4: begin

				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
				
				data <= data + Mult_result_1 + Mult_result_2;
				data2 <= data2 + Mult_result_3 + Mult_result_4;
				
				M2_state <= M2_COMPUTE_T5;
			end
			M2_COMPUTE_T5: begin
				
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
				
				write_data_a[2] <= $unsigned(data + Mult_result_1 + Mult_result_2);
				address_a[2] <= write_counter;
				write_enable_a[2] <= 1'b1;
				write_counter <= write_counter + 1'b1;
				
				data2 <= data2 +  Mult_result_3 + Mult_result_4;
				
				M2_state <= M2_COMPUTE_T6;
			end
			M2_COMPUTE_T6: begin 
				
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
				
				write_data_a[2] <= $unsigned(data2);
				address_a[2] <= write_counter;
				write_counter <= write_counter + 1'b1;
				
				data <= Mult_result_1 + Mult_result_2;
				data2 <= Mult_result_3 + Mult_result_4;
				
				M2_state <= M2_COMPUTE_T3;
				
			end
			
			M2_COMPUTE_T7: begin
				data <= data + Mult_result_1 + Mult_result_2;
				data2 <= data2 + Mult_result_3 + Mult_result_4;
				
				M2_state <= M2_COMPUTE_T8;
			end
			M2_COMPUTE_T8: begin
				write_data_a[2] <= $unsigned(data + Mult_result_1 + Mult_result_2);
				address_a[2] <= write_counter;
				write_enable_a[2] <= 1'b1;
				write_counter <= write_counter + 1'b1;
				
				data2 <= data2 +  Mult_result_3 + Mult_result_4;
				
				M2_state <= M2_COMPUTE_T9;
			end
			M2_COMPUTE_T9: begin
				write_data_a[2] <= $unsigned(data2);
				address_a[2] <= write_counter;
				
				write_counter <= 1'b0;
				adress_counter <= 1'b0;  //reset
				adress_counter2 <= 1'b0;
				
				M2_state <= Mega1;
			end
//--------------------------------------------------------Fetch S and Compute S----------------------------------------------------------

			Mega1: begin
				if(col_block == 6'd39 && row_block == 6'd29) begin
					col_block <= 1'b0;
					row_block <= 1'b0;
				end
				else if(col_block == 6'd39)begin
						col_block <= 1'b0;
						row_block <= row_block + 1'b1;  //increasing blocks
				end
				else if(col_block == 6'd19 && row_block == 6'd29 && V_flag == 1'b1)begin
					col_block <= 1'b0;
					row_block <= 1'b0;
				end
				else if(col_block == 6'd19 && S_flag == 1'b0) begin
						col_block <= 1'b0;
						row_block <= row_block + 1'b1;  //increasing blocks
				end
				
				else
						col_block <= col_block + 1'b1;
				
//				if(col_block == 6'd39 && row_block == 6'd29)begin
//					col_block <= 1'b0;
//					row_block <= 1'b0;
//					S_flag <= 1'b0;
//					U_flag <= 1'b1;
//				end
				

					
				 if((U_flag == 1'b1 && ~(row_block == 6'd29 && col_block == 6'd39)) || (V_flag == 1'b1 && row_block == 6'd29 && col_block == 6'd19))
					write_counter3 <= (((((row_address<<7) + (row_address<<5) + column_address))>>>1) + 63'd38400); //+ 63'd38400;
				 else if(V_flag == 1'b1 && ~(row_block == 6'd29 && col_block == 6'd19) || (donef == 1'b1 && row_block == 6'd29 && col_block == 6'd19))
					write_counter3 <= (((((row_address<<7) + (row_address<<5) + column_address))>>>1) + 63'd57600);
				 else
					write_counter3 <= (((row_address<<8) + (row_address<<6) + column_address))>>>1;
//				else
//					write_counter3 <= (((row_address<<8) + (row_address<<6) + column_address))>>>1 + 63'd57600;
					
				SRAM_we_n <= 1'b1;
				write_enable_a[0] <= 1'b0;
				write_enable_b[0] <= 1'b0;
				
				write_counter <= 12'd32;
				write_enable_a[2] <= 1'b0;
			
				address_a[1] <= adress_counter; 
				address_b[1] <= adress_counter + 3'd4;
				
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 1'b1;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 5'd8;
				
				M2_state <= Mega2;
			end
			
			Mega2: begin

				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 5'd1;

				adress_counter2 <= adress_counter2 + 8'd8;
				
				M2_state <= Mega3;
				
			end
			Mega3: begin
				address_a[1] <= adress_counter; 
				address_b[1] <= adress_counter + 3'd4;
				
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 5'd1;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 8'd8;
				
				
				data <= (Mult_result_1);
				data2 <= (Mult_result_2);
				data3 <= (Mult_result_3);
				data4 <= (Mult_result_4);
				M2_state <= Mega4;
				
			end
			Mega4: begin
				//fetch s
				column_index <= column_index + 1'b1;
				write_enable_a[0] <= 1'b0;
				//compute s---------------
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 5'd1;

				adress_counter2 <= adress_counter2 + 8'd8;
				
				data <= (data) + (Mult_result_1);
				data2 <= (data2) + (Mult_result_2);
				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
				
				write_enable_b[0] <= 1'b0;
				
				M2_state <= Mega5;
				
			end
			
			Mega5: begin
				
				address_a[1] <= adress_counter; 
				address_b[1] <= adress_counter + 3'd4;
				
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 1'b1;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 5'd8;
				
				data <= (data) + (Mult_result_1);
				data2 <= (data2) + (Mult_result_2);
				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
				
				M2_state <= Mega6;
				
			end
			
			Mega6: begin
				//fetch s
				data5 <= SRAM_read_data;
				//compute s---------------
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 5'd1;

				adress_counter2 <= adress_counter2 + 8'd8;
				
			
				data <= (data) + (Mult_result_1);
				data2 <= (data2) + (Mult_result_2);
				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
				
				M2_state <= Mega7;
			end
			Mega7: begin 
				// Fetch s--------------------------------------
				write_enable_a[0] <= 1'b1;
				address_a[0] <= write_counter2;//dp adress
				write_data_a [0] <= {data5[15:0], SRAM_read_data[15:0]}; //go to 16 bit of write data
				column_index <= column_index + 1'b1;
				write_counter2 <= write_counter2 + 1'b1;
				
				if(column_index == 6'd7) begin
					row_index <= row_index + 1'b1;
					column_index <= 1'b0;
				end

				 
			// Write s--------------------------------------
				
				address_a[1] <= adress_counter; 
				address_b[1] <= adress_counter + 3'd4;
				
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 1'b1;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 5'd8;
				
				data <= (data) + (Mult_result_1);
				data2 <= (data2) + (Mult_result_2);
				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
				
				M2_state <= Mega8;
				
			end
			Mega8: begin
				//fetch s
				column_index <= column_index + 1'b1;
				write_enable_a[0] <= 1'b0;
				//compute s---------------
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 5'd1;

				adress_counter <= adress_counter - 4'd4;
				adress_counter2 <= adress_counter2 - 32'd56 + 3'd2;
				
				write_enable_b[0] <= 1'b0;
				
				M2_state <= Mega9;
				if(adress_counter2 == 32'd62 && adress_counter == 32'd28) begin
					M2_state <= Mega12;
				end
				else if(adress_counter2 == 32'd62)begin
					adress_counter <= adress_counter + 4'd4;
					adress_counter2 <= 1'b0;
				end
			
				data <= (data) + (Mult_result_1);
				data2 <= (data2) + (Mult_result_2);
				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
			
				
			end
			
			Mega9: begin
				address_a[1] <= adress_counter; 
				address_b[1] <= adress_counter + 3'd4;
				
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 1'b1;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 5'd8;
				
				data <= (data) + (Mult_result_1);
				data2 <= (data2) + (Mult_result_2);
				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
				
				M2_state <= Mega10;
			end
			
			Mega10: begin
				//fetch s
				data5 <= SRAM_read_data;
				//compute s---------------
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 5'd1;

				adress_counter2 <= adress_counter2 + 8'd8;
			
				address_b[0] <= write_counter;
				write_enable_b[0] <= 1'b1;
				
					write_data_b[0] <= {8'b0,data_buff5[7:0],8'b0,data_buff6[7:0]};
				//write_data_b[0] <= { 8'b0,data_buff1[31] ? 8'b0 :(|data_buff1[46:8]?8'd255:data_buff1[7:0]),8'b0,data_buff2[47] ? 8'b0 :(|data_buff2[46:8]?8'd255:data_buff2[7:0])};
				//  write_data_b[0] <= { 8'b0,data_buff1[47] ? 8'b0 :(data_buff1[7:0]),8'b0,data_buff2[47] ? 8'b0 :(data_buff2[7:0])};

				//write_data_b[0] <= { 8'b0,data_buff1[7:4] == 4'hf ? 8'b0 : data_buff1[7:4] == 4'b0 ? 8'hff : data_buff1[7:0] ,8'b0,data_buff2[7:4] == 4'hf ? 8'b0 : data_buff2[7:4] == 4'b0 ? 8'hff : data_buff2[7:0]};
				
				
			 
				write_counter <= write_counter + 1'b1;
				

				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
				
				M2_state <= Mega11;
			end
			
			Mega11:begin
			// Fetch s--------------------------------------
				write_enable_a[0] <= 1'b1;
				address_a[0] <= write_counter2;//dp adress
				write_data_a [0] <= {data5[15:0], SRAM_read_data[15:0]}; //go to 16 bit of write data
				column_index <= column_index + 1'b1;
				write_counter2 <= write_counter2 + 1'b1;
				
				if(column_index == 3'd7) begin
					row_index <= row_index + 1'b1;
					column_index <= 1'b0;
				end

				if(column_index == 3'd7 && row_index == 3'd7) begin

					write_counter2 <= 1'b0;
					column_index <= 1'b0;                //resets
					row_index <= 1'b0;            
//					if(col_block == 6'd39)begin
//						col_block <= 1'b0;
//						row_block <= row_block + 1'b1;  //increasing blocks
//					end else
//						col_block <= col_block + 1'b1;

			    end
				 
			       // Write s--------------------------------------
				address_a[1] <= adress_counter; 
				address_b[1] <= adress_counter + 3'd4;
				
				address_a[2] <= adress_counter2;
				address_b[2] <= adress_counter2 + 1'b1;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 5'd8;
				
				write_data_b[0] <= {8'b0,data_buff7[7:0],8'b0,data_buff8[7:0]};
			
			//	write_data_b[0] <= { 8'b0,data_buff3[47] ? 8'b0 :(|data_buff3[46:8]?8'd255:data_buff3[7:0]),8'b0,data_buff4[47] ? 8'b0 :(|data_buff4[46:8]?8'd255:data_buff4[7:0])};
			//	write_data_b[0] <= { 8'b0,data_buff3[47] ? 8'b0 :(data_buff3[7:0]),8'b0,data_buff4[47] ? 8'b0 :(data_buff4[7:0])};

			//	write_data_b[0] <= { 8'b0,data_buff3[7:4] == 4'hf ? 8'b0 : data_buff3[7:4] == 4'b0 ? 8'hff : data_buff3[7:0] ,8'b0,data_buff4[7:4] == 4'hf ? 8'b0 : data_buff4[7:4] == 4'b0 ? 8'hff : data_buff4[7:0]};
					
				address_b[0] <= write_counter;
				write_counter <= write_counter + 1'b1;
				
				data <= (Mult_result_1);
				data2 <= (Mult_result_2);
				data3 <= (Mult_result_3);
				data4 <= (Mult_result_4);
				
				M2_state <= Mega4;
			end
			
			Mega12: begin
				data <= (data) + (Mult_result_1);
				data2 <= (data2) + (Mult_result_2);
				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
				
				M2_state <= Mega13;
			end
			
			Mega13: begin
			//fetch s
				data5 <= SRAM_read_data;
				//compute s---------------
				address_b[0] <= write_counter;
				write_enable_b[0] <= 1'b1;
				
				write_data_b[0] <= {8'b0,data_buff5[7:0],8'b0,data_buff6[7:0]};
			//	write_data_b[0] <= { 8'b0,data_buff1[7:4] == 4'hf ? 8'b0 : data_buff1[7:4] == 4'b0 ? 8'hff : data_buff1[7:0] ,8'b0,data_buff2[7:4] == 4'hf ? 8'b0 : data_buff2[7:4] == 4'b0 ? 8'hff : data_buff2[7:0]};
				
			//	write_data_b[0] <= { 8'b0,data_buff1[47] ? 8'b0 :(|data_buff1[46:8]?8'd255:data_buff1[7:0]),8'b0,data_buff2[47] ? 8'b0 :(|data_buff2[46:8]?8'd255:data_buff2[7:0])};
			//	write_data_b[0] <= { 8'b0,data_buff1[47] ? 8'b0 :(data_buff1[7:0]),8'b0,data_buff2[47] ? 8'b0 :(data_buff2[7:0])};

				write_counter <= write_counter + 1'b1;
				
				data3 <= (data3) + (Mult_result_3);
				data4 <= (data4) + (Mult_result_4);
				
				
				M2_state <= Mega14;
			end
			
			Mega14: begin
				// Fetch s--------------------------------------
				write_enable_a[0] <= 1'b1;
				address_a[0] <= write_counter2;//dp adress
				write_data_a [0] <= {data5[15:0], SRAM_read_data[15:0]}; //go to 16 bit of write data
				column_index <= column_index + 1'b1;
				write_counter2 <= write_counter2 + 1'b1;
				
				if(column_index == 4'd7) begin
					row_index <= row_index + 1'b1;
					column_index <= 1'b0;
				end

				if(column_index == 3'd7 && row_index == 3'd7) begin

					write_counter2 <= 1'b0;
					column_index <= 1'b0;                //resets
					row_index <= 1'b0;            
/*					if(col_block == 6'd39)begin
						col_block <= 1'b0;
						row_block <= row_block + 1'b1;  //increasing blocks
					end else
						col_block <= col_block + 1'b1;*/

			    end
				
				write_data_b[0] <= {8'b0,data_buff7[7:0],8'b0,data_buff8[7:0]};
		//		write_data_b[0] <= { 8'b0,data_buff3[63] ? 8'b0 :(|data_buff3[62:8]?8'd255:data_buff3[7:0]),8'b0,data_buff4[63] ? 8'b0 :(|data_buff4[62:8]?8'd255:data_buff4[7:0])};
		//		write_data_b[0] <= { 8'b0,data_buff3[47] ? 8'b0 :(data_buff3[7:0]),8'b0,data_buff4[47] ? 8'b0 :(data_buff4[7:0])};
		//		write_data_b[0] <= { 8'b0,data_buff3[7:4] == 4'hf ? 8'b0 : data_buff3[7:4] == 4'b0 ? 8'hff : data_buff3[7:0] ,8'b0,data_buff4[7:4] == 4'hf ? 8'b0 : data_buff4[7:4] == 4'b0 ? 8'hff : data_buff4[7:0]};
				
				address_b[0] <= write_counter;
				write_counter <= write_counter + 1'b1;

				adress_counter <= 16'd0;  //reset
				adress_counter2 <= 1'b0;
				adress_counter3 <= 16'd32;
				write_counter <= 1'b0;
				data <= 1'b0;
				data2 <= 1'b0;
				data3 <= 1'b0;
				data4 <= 1'b0;
				data5 <= 1'b0;
				
				M2_state <= Mega15;
			end
			Mega15: begin
				
				 M2_state <= Mega16;
			end
			//-------------------------Write S and Compute T---------------------------------------------//
			Mega16 : begin
				write_enable_a[0] <= 1'b0;
				//Write s--------------------------------
				address_b[0] <= adress_counter3;
				adress_counter3 <= adress_counter3 + 4'd2;
				write_enable_b[0] <= 1'b0;
				//Compute T--------------------------------
				address_a[0] <= adress_counter; //adress we are reading
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;

				M2_state <= Mega17;

			end
			Mega17: begin
				//Write s--------------------------------
				address_b[0] <= adress_counter3;
				adress_counter3 <= adress_counter3 + 4'd2;
				
				//Compute T--------------------------------
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
				M2_state <= Mega18;
			end
			
			Mega18: begin
				//Write s--------------------------------
				address_b[0] <= adress_counter3;
				adress_counter3 <= adress_counter3 + 4'd2;
				
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
				

				write_counter3 <= write_counter3 + 1'b1;
				
				//Compute T--------------------------------
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
			
				data <= $signed(Mult_result_1) + $signed(Mult_result_2);
				data2 <= $signed(Mult_result_3) + $signed(Mult_result_4);
				
				M2_state <= Mega19;
			end
			
			Mega19: begin 
				//Write s--------------------------------
				if(adress_counter3 != 32'd64)begin
					write_counter3 <= write_counter3 + 1'b1;
					address_b[0] <= adress_counter3;
					if(flag1 == 1'b0) begin
						adress_counter3 <= adress_counter3 - 5'd5;
						flag1 <= 1'b1;
					end
					else begin
						adress_counter3 <= adress_counter3 + 1'b1;
						flag1 <= 1'b0;
					end
					SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
					write_counter3 <= write_counter3 + 1'b1;
				end
				else begin
					SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
					write_counter3 <= write_counter3 + 1'b1;
				end
				//Compute T--------------------------------
				write_enable_a[2] <= 1'b0;
				
				address_a[0] <= adress_counter;
			
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter -2'd3;
				adress_counter2 <= adress_counter2 + 4'd5;
				
				data <= $signed(data) + $signed(Mult_result_1) + $signed(Mult_result_2);
				data2 <= $signed(data2) + $signed(Mult_result_3) + $signed(Mult_result_4);
				
				M2_state <= Mega20;
				
				if(adress_counter == 8'd31&& adress_counter2 == 8'd27)begin  //end of reading
					M2_state <= Mega23;
				end
				else if(adress_counter2 == 8'd27) begin
					adress_counter2 <= 1'b0;
					adress_counter <= adress_counter + 1'b1;
				end
				
			end
			
			Mega20: begin
				//Write s--------------------------------
				if(adress_counter3 != 32'd64)begin
					address_b[0] <= adress_counter3;
					adress_counter3 <= adress_counter3 + 4'd2;
					
					SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
					write_counter3 <= write_counter3 + 1'b1;
				end else begin
					SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
					write_counter3 <= write_counter3 + 1'b1;
				end
					

				//Compute T--------------------------------
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
				
				data <= $signed(data) + $signed(Mult_result_1) + $signed(Mult_result_2);
				data2 <= $signed(data2) + $signed(Mult_result_3) + $signed(Mult_result_4);
				
				M2_state <= Mega21;
			end
			Mega21: begin
				//Write s--------------------------------
				if(adress_counter3 != 32'd64)begin
					address_b[0] <= adress_counter3;
					adress_counter3 <= adress_counter3 + 4'd2;
					
					SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
					write_counter3 <= write_counter3 + 1'b1;
				end else begin
					SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
					write_counter3 <= write_counter3 + 1'b1;
				end
				//Compute T--------------------------------
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
				
				write_data_a[2] <= $signed(data) + $signed(Mult_result_1) + $signed(Mult_result_2);
				address_a[2] <= write_counter;
				write_enable_a[2] <= 1'b1;
				write_counter <= write_counter + 1'b1;
				
				data2 <= $signed(data2) + $signed(Mult_result_3) + $signed(Mult_result_4);
				
				M2_state <= Mega22;
			end
			Mega22: begin 
				//Write s--------------------------------
				if(adress_counter3 != 32'd64)begin
					address_b[0] <= adress_counter3;
					adress_counter3 <= adress_counter3 + 4'd2;
				
					SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
					write_counter3 <= (S_flag == 1'b1 || (col_block == 1'b0 && row_block == 1'b0 && V_flag == 1'b0))?  write_counter3 + 32'd157:write_counter3 + 32'd77;
				end else begin
					SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
					write_counter3 <= write_counter3 + 1'b1;
					SRAM_we_n <= 1'b1;
				end
				//Compute T--------------------------------
				address_a[0] <= adress_counter;
				
				address_a[1] <= adress_counter2;
				address_b[1] <= adress_counter2 + 3'd4;
				
				adress_counter <= adress_counter + 2'd1;
				adress_counter2 <= adress_counter2 + 2'd1;
				
				write_data_a[2] <= $signed(data2);
				address_a[2] <= write_counter;
				write_counter <= write_counter + 1'b1;
				
				data <= $signed(Mult_result_1) + $signed(Mult_result_2);
				data2 <= $signed(Mult_result_3) + $signed(Mult_result_4);
				
				M2_state <= Mega19;
				
			end
			
			Mega23: begin
				//Write s--------------------------------
				address_b[0] <= adress_counter3;
				adress_counter3 <= adress_counter3 + 1'b1;
				
				SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
				write_counter3 <= write_counter3 + 1'b1;
				//Compute T--------------------------------
				data <= $signed(data) + $signed(Mult_result_1) + $signed(Mult_result_2);
				data2 <= $signed(data2) + $signed(Mult_result_3) + $signed(Mult_result_4);
				
				M2_state <= Mega24;
			end
			Mega24: begin
				//Write s--------------------------------
				address_b[0] <= adress_counter3;
				adress_counter3 <= adress_counter3 + 1'b1;
				
				SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
				write_counter3 <= write_counter3 + 1'b1;
				//Compute T--------------------------------
				write_data_a[2] <= $signed(data) + $signed(Mult_result_1) + $signed(Mult_result_2);
				address_a[2] <= write_counter;
				write_enable_a[2] <= 1'b1;
				write_counter <= write_counter + 1'b1;
				
				data2 <= $signed(data2) + $signed(Mult_result_3) + $signed(Mult_result_4);
				
				M2_state <= Mega25;
			end
			Mega25: begin
				//Write s--------------------------------
				address_b[0] <= adress_counter3;
				adress_counter3 <= adress_counter3 + 1'b1;
				
				SRAM_write_data <= {read_data_b[0][23:16],read_data_b[0][7:0]};
				write_counter3 <= write_counter3 + 1'b1;
				//Compute T--------------------------------
				write_data_a[2] <= $signed(data2);
				address_a[2] <= write_counter;
				
				write_counter <= 1'b0;
				write_counter2 <= 1'b0;
				adress_counter <= 1'b0;  //reset
				adress_counter2 <= 1'b0;
			
			if(col_block == 6'd39 && row_block == 6'd29 && S_flag == 1'b1)begin
					
					S_flag <= 1'b0;
					U_flag <= 1'b1;
 		   end
			else if(col_block == 6'd19 && row_block == 6'd29 && U_flag == 1'b1) begin
					U_flag <= 1'b0;
					V_flag <= 1'b1;
			end
			else if(col_block == 6'd19 && row_block == 6'd29 && V_flag == 1'b1) begin
					V_flag <= 1'b0;
					donef <= 1'b1;
			end
//				if(tempCounter != 63'd230)begin
					M2_state <= Mega1;
					tempCounter <= tempCounter + 1'b1;
					
			if(donef == 1'b1)
				M2_state <= END;
//				end else
//					M2_state <= END;
			end
			END: begin
				SRAM_we_n <= 1'b1;
				write_enable_a[0] <= 1'b0;
				write_enable_a[2] <= 1'b0;
				write_enable_b[0] <= 1'b0;
				M2_end <= 1'b1;
			
			end

	
			default: M2_state <= M2_IDLE;
			endcase

end

end

end

/*	
			M2_FETCH0: begin
	 
			SRAM_we_n <= 1'b1; 
			M2_SRAM_address <= pre_IDCT_Y+(row_address<<8) + (row_address<<6) + column_address;
			s_counter <= s_counter + 1'd1;
			
			M2_state <= M2_FETCH1;
			
	*/	
	
always_comb begin

case (M2_state)

	default : begin
	
		Mult_1_op1 = 32'd0;
		Mult_2_op1 = 32'd0;
		Mult_3_op1 = 32'd0;
		Mult_4_op1 = 32'd0;
		Mult_1_op2 = 32'd0;
		Mult_2_op2 = 32'd0;
		Mult_3_op2 = 32'd0;
		Mult_4_op2 = 32'd0;

	end 
	M2_COMPUTE_T2: begin    //be ready at M2_COMPUTE_T3
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);
	end
	
	M2_COMPUTE_T3: begin    //be ready at M2_COMPUTE_T3
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);
	end
	
	
	M2_COMPUTE_T4:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);
	end
	M2_COMPUTE_T5:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);
	end
	M2_COMPUTE_T6:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);

	end
	M2_COMPUTE_T7:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);

	end
	M2_COMPUTE_T8:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);

	end
	
	Mega3 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][31:16]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][31:16]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][31:16]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][31:16]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
	end
	
	Mega4 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][15:0]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][15:0]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][15:0]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][15:0]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});

	end
	Mega5 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][31:16]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][31:16]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][31:16]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][31:16]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
	end
	
	Mega6 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][15:0]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][15:0]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][15:0]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][15:0]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});

	end
	Mega7 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][31:16]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][31:16]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][31:16]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][31:16]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
	end
	
	Mega8 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][15:0]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][15:0]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][15:0]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][15:0]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});

	end
	Mega9 :  begin 
				Mult_1_op1 = $signed(read_data_a[1][31:16]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][31:16]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][31:16]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][31:16]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});

	end
	
	Mega10 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][15:0]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][15:0]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][15:0]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][15:0]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
	end
	Mega11 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][31:16]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][31:16]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][31:16]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][31:16]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
	end
	
	Mega12 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][31:16]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][31:16]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][31:16]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][31:16]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
	end
	Mega13 :  begin 
	
				Mult_1_op1 = $signed(read_data_a[1][15:0]);//C
				//Mult_1_op2 = $signed(read_data_a[2]>>>8);//T
				Mult_1_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_2_op1 = $signed(read_data_a[1][15:0]);
				Mult_2_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});
				Mult_3_op1 = $signed(read_data_b[1][15:0]);
				Mult_3_op2 = $signed({read_data_a[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_a[2][31:8]});
				Mult_4_op1 = $signed(read_data_b[1][15:0]);
				Mult_4_op2 = $signed({read_data_b[2][31] == 1'b0 ? 8'b0 : 8'hff, read_data_b[2][31:8]});

	end
	Mega18: begin    //be ready at M2_COMPUTE_T3
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);
	end
	
	Mega19: begin    //be ready at M2_COMPUTE_T3
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);
	end
	
	
	Mega20:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);
	end
	Mega21:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);
	end
	Mega22:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);

	end
	Mega23:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);

	end
	Mega24:  begin 
	
				Mult_1_op1 = $signed(read_data_a[0][31:16]);//S
				Mult_1_op2 = $signed(read_data_a[1][31:16]);//C
				Mult_2_op1 = $signed(read_data_a[0][15:0]);
				Mult_2_op2 = $signed(read_data_a[1][15:0]);
				Mult_3_op1 = $signed(read_data_a[0][31:16]);
				Mult_3_op2 = $signed(read_data_b[1][31:16]);
				Mult_4_op1 = $signed(read_data_a[0][15:0]);
				Mult_4_op2 = $signed(read_data_b[1][15:0]);

	end
	
endcase
	
	end
	
	endmodule
