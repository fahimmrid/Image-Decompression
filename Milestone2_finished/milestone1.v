/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

// This is the top module
// It connects the SRAM and VGA together
// It will first write RGB data of an image with 8x8 rectangles of size 40x30 pixels into the SRAM
// The VGA will then read the SRAM and display the image
module milestone1(

	/*	input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[3:0] PUSH_BUTTON_I,           // pushbuttons
		input logic[17:0] SWITCH_I,               // toggle switches


		/////// VGA interface                     ////////////
		output logic VGA_CLOCK_O,                 // VGA clock
		output logic VGA_HSYNC_O,                 // VGA H_SYNC
		output logic VGA_VSYNC_O,                 // VGA V_SYNC
		output logic VGA_BLANK_O,                 // VGA BLANK
		output logic VGA_SYNC_O,                  // VGA SYNC
		output logic[9:0] VGA_RED_O,              // VGA red
		output logic[9:0] VGA_GREEN_O,            // VGA green
		output logic[9:0] VGA_BLUE_O,             // VGA blue
		

	*/	

		 input logic Clock_50, 
		 input logic Resetn,
		 input logic M1_start,
	    input logic    [15:0]   SRAM_read_data,

  		 output logic   [17:0]   SRAM_address,
		 output logic            SRAM_we_n,
 		 output logic   [15:0]   SRAM_write_data,
 		 output logic            M1_end
		

);

parameter U_OFFSET = 18'd38400,
          V_OFFSET = 18'd57600,
		  RGB_OFFSET = 18'd146944;

/*
NUM_ROW_RECTANGLE = 8,
		  NUM_COL_RECTANGLE = 8,
		  RECT_WIDTH = 40,
		  RECT_HEIGHT = 30,
		  VIEW_AREA_LEFT = 160,
		  VIEW_AREA_RIGHT = 480,
		  VIEW_AREA_TOP = 120,
		  VIEW_AREA_BOTTOM = 360;*/

milestone1_state_type M1_state;


// For Push button
logic [3:0] PB_pushed;

// For VGA
logic [9:0] VGA_red, VGA_green, VGA_blue;
logic [9:0] pixel_X_pos;
logic [9:0] pixel_Y_pos;


/*
// For SRAM
logic [17:0] SRAM_address;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;

logic [2:0] rect_row_count;		// Number of rectangles in a row
logic [2:0] rect_col_count;		// Number of rectangles in a column
logic [5:0] rect_width_count;	// Width of each rectangle
logic [4:0] rect_height_count;	// Height of each rectangle
logic [2:0] color;

logic [15:0] VGA_sram_data [2:0];

//assign resetn = ~SWITCH_I[17] && SRAM_ready;

Push Button unit
PB_Controller PB_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PB_signal(PUSH_BUTTON_I),	
	.PB_pushed(PB_pushed)
);
*/

logic	 [17:0]   Y_address;
logic	 [17:0]   V_address;
logic	 [17:0]   U_address;
logic	 [17:0]   RGB_address;
logic  [7:0]    U_shift_reg [5:0], V_shift_reg [5:0];
logic  [15:0]   Y_register, U_register, V_register;
logic  [31:0]   R_register, B_register, G_register;

logic [31:0]  U_prime_buf, V_prime_buf;
logic [6:0]  Column_counter;
logic [8:0]  Row_counter;


/*
logic Red [7:0]; 
logic Green [7:0];
logic Blue [7:0];


assign Red = R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16]);
assign Green = G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16]);
assign	Blue = B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16]);
*/


logic [31:0] Mult_1_op1, Mult_2_op1, Mult_3_op1 ;
logic [31:0] Mult_1_op2, Mult_2_op2, Mult_3_op2 ; 
//logic [31:0] Mult_result [3:0];
logic [63:0] Mult_result_1, Mult_result_2, Mult_result_3;
logic [31:0] Common_Y_Value;


assign
	Mult_result_1 = Mult_1_op1 * Mult_1_op2,
	Mult_result_2 = Mult_2_op1 * Mult_2_op2,
	Mult_result_3 = Mult_3_op1 * Mult_3_op2;
/*	
assign
	Mult_result[0] = Mult_result_long[0][31:0],
	Mult_result[1] = Mult_result_long[1][31:0],
	Mult_result[2] = Mult_result_long[2][31:0];

*/



always_ff @ (posedge Clock_50 or negedge Resetn) begin
	if (Resetn == 1'b0) begin

		M1_state <= M1_IDLE;
		Y_address <= 18'd0;
       	U_address <= U_OFFSET;
       	V_address <= V_OFFSET;
       		 RGB_address <= RGB_OFFSET;
		
		VGA_red <= 10'd0;
		VGA_green <= 10'd0;
		VGA_blue <= 10'd0;

		U_register <= 16'd0;
		Y_register <= 16'd0;
		V_register <= 16'd0;	
	
		R_register <= 32'd0;
		G_register <= 32'd0;
		B_register <= 32'd0;		

		U_prime_buf  <= 16'b0;
		V_prime_buf  <= 16'b0;
		
		Column_counter <= 7'd0;
		Row_counter <= 9'd0 ;
		
		SRAM_we_n <= 1'b1;
		SRAM_write_data <= 16'd0;
		SRAM_address <= 18'd0;
		Common_Y_Value <= 32'd0;
		M1_end <= 1'b0;//*
	end else begin
		case (M1_state)
		M1_IDLE: begin
		    if (M1_end) begin

			SRAM_we_n <= 1'b1;
			Y_address <= 18'd0;
			U_address <= U_OFFSET;
		    V_address <= V_OFFSET;
		    RGB_address <= RGB_OFFSET;

			U_register <= 16'd0;
			Y_register <= 16'd0;
			V_register <= 16'd0;		
	
			U_prime_buf  <= 32'd0;
		    V_prime_buf  <= 32'd0;
			
		
			SRAM_we_n <= 1'b1;
			SRAM_write_data <= 16'd0;
			SRAM_address <= 18'd0;
			M1_end <= 1'b0;

		 end

   		 SRAM_address <= 18'd0;
          SRAM_write_data <= 16'd0;
          SRAM_we_n <= 1'b1;  


            
        if (M1_start) begin
				
			 M1_state <= M1_LEAD_0;
			 SRAM_address <= U_address;
			 SRAM_we_n <= 1'b1; 
			 Column_counter <= 7'd0;
			
			
        end else begin 
		    M1_state <= M1_IDLE;
            
		 end
  
end

			M1_LEAD_0: begin	
				
				SRAM_address <= V_address;				
				U_address <= U_address + 18'd1;	
				M1_state <= M1_LEAD_1;	
			end
			
			M1_LEAD_1: begin	
				
				SRAM_address <= U_address;				
				V_address <= V_address + 18'd1;
				M1_state <= M1_LEAD_2;
			end
			
			M1_LEAD_2: begin	
				
				SRAM_address <= V_address;				
				U_address <= U_address + 18'd1;		
				U_register <= SRAM_read_data; //the cc before in shift reg
				M1_state <= M1_LEAD_3;
			end
			
			M1_LEAD_3: begin	
				
				SRAM_address <= U_address;				
				V_address <= V_address + 18'd1;
		
				V_register <= SRAM_read_data;
				
				U_shift_reg[0] <= U_register[15:8];         
				U_shift_reg[1] <= U_register[15:8];
				U_shift_reg[2] <= U_register[15:8];
				U_shift_reg[3] <= U_register[7:0];

				M1_state <= M1_LEAD_4;
			end
			
			M1_LEAD_4: begin	
			
				SRAM_address <= V_address;				
				U_address <= U_address + 18'd1;
		
				U_register <= SRAM_read_data;
				
				V_shift_reg[0] <= V_register[15:8];
				V_shift_reg[1] <= V_register[15:8];
				V_shift_reg[2] <= V_register[15:8];
				V_shift_reg[3] <= V_register[7:0];

				M1_state <= M1_LEAD_5;
			end
			
			M1_LEAD_5: begin	
				
				SRAM_address <= Y_address;				
				V_address <= V_address + 18'd1;
		
				V_register <= SRAM_read_data;

				U_shift_reg[5] <= U_register[7:0];
				U_shift_reg[4] <= U_register[15:8];
				
				M1_state <= M1_LEAD_6; 
			end
			
			M1_LEAD_6: begin	
				
				U_register <= SRAM_read_data;		
				Y_address <= Y_address + 18'd1;
				
				V_shift_reg[5] <= V_register[7:0];
				V_shift_reg[4] <= V_register[15:8];

				M1_state <= M1_LEAD_7;
			end

			M1_LEAD_7: begin					
		
				V_register <= SRAM_read_data;
				

				M1_state <= M1_LEAD_8;
			end

			M1_LEAD_8: begin	
					
				Y_register <= SRAM_read_data;
				
				U_prime_buf  <= 32'd128 + $signed(Mult_result_1[31:0])  - $signed(Mult_result_2[31:0])  + $signed(Mult_result_3[31:0]) ;
			

				M1_state <= M1_LEAD_9;
			end
			
			
			M1_LEAD_9:  begin
				
				//SRAM_address <= Y_address;		
				
				U_prime_buf <= {U_prime_buf[31] == 1'b0 ? 8'b0 : 8'hff,U_prime_buf[31:8]}; // for U (dividing by 256)
				
				V_prime_buf  <= 32'd128 + $signed(Mult_result_1[31:0])  - $signed(Mult_result_2[31:0])  + $signed(Mult_result_3[31:0]) ;
				M1_state <= M1_LEAD_10;
			
			end
	
			M1_LEAD_10:  begin
			
				
				V_prime_buf <= {V_prime_buf[31] == 1'b0 ? 8'b0 : 8'hff,V_prime_buf[31:8]}; //clipping for V (dividing by 256)
				 
				
				U_shift_reg[0] <= U_shift_reg[1];
				U_shift_reg[1] <= U_shift_reg[2];
				U_shift_reg[2] <= U_shift_reg[3];
				U_shift_reg[3] <= U_shift_reg[4];
				U_shift_reg[4] <= U_shift_reg[5];
				U_shift_reg[5] <= U_register[15:8];
				
				V_shift_reg[0] <= V_shift_reg[1];
				V_shift_reg[1] <= V_shift_reg[2];
				V_shift_reg[2] <= V_shift_reg[3];
				V_shift_reg[3] <= V_shift_reg[4];
				V_shift_reg[4] <= V_shift_reg[5];
				V_shift_reg[5] <= V_register[15:8];
				
				R_register <= $signed(Mult_result_1[31:0])  + $signed(Mult_result_2[31:0]);
				Common_Y_Value <= $signed(Mult_result_1[31:0]);
				
				M1_state <= M1_COMMON_1;

			
			end
//-----------------------------------------------------------------Common Case--------------------------------------------------------------
			M1_COMMON_1:  begin
				
				G_register <= $signed(Common_Y_Value) - $signed(Mult_result_1[31:0]) - $signed(Mult_result_2[31:0]);
				B_register <= $signed(Common_Y_Value) + $signed(Mult_result_3[31:0]);
				
				SRAM_address <= Y_address; //fixed

				M1_state <= M1_COMMON_2;
				
			end
			
			M1_COMMON_2:  begin
				SRAM_we_n <= 1'b0;
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				Y_address <= Y_address + 18'd1;
				
			  SRAM_write_data <= {R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16]),G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16])} ;//clipping
			 // SRAM_write_data <= {Red,Green};
				
				
				R_register <= $signed(Mult_result_1[31:0])  + $signed(Mult_result_2[31:0]);
				Common_Y_Value <= $signed(Mult_result_1[31:0]);
				
				M1_state <= M1_COMMON_3;
			end
			
			M1_COMMON_3: begin
			
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				G_register <= $signed(Common_Y_Value) - $signed(Mult_result_1[31:0]) - $signed(Mult_result_2[31:0]);
				B_register <= $signed(Common_Y_Value) + $signed(Mult_result_3[31:0]);
				
				SRAM_write_data <= {B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16]), R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16])} ;//clipping
				
				M1_state <= M1_COMMON_4;
				
			end
			
			M1_COMMON_4: begin
			
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;

				Y_register <= SRAM_read_data; //** put in reg here after been read, also dont overright before been used
				
				SRAM_write_data <= {G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16]),B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16])}  ; //clipping
				
				U_prime_buf  <= 32'd128 + $signed(Mult_result_1[31:0])    + $signed(Mult_result_3[31:0]) - $signed(Mult_result_2[31:0]);
				
				M1_state <= M1_COMMON_5;
				
				
			end
			
			M1_COMMON_5: begin
			
				//SRAM_address <= Y_address;				
				SRAM_we_n <= 1'b1;
				
				SRAM_address <= U_address;
				
				U_prime_buf <= {U_prime_buf[31] == 1'b0 ? 8'b0 : 8'hff,U_prime_buf[31:8]}; //clipping for U (dividing by 256) // 31:7
				
				V_prime_buf  <= 32'd128 + $signed(Mult_result_1[31:0])  - $signed(Mult_result_2[31:0])  + $signed(Mult_result_3[31:0]) ;
				
				M1_state <= M1_COMMON_6;
				
			end
			
			M1_COMMON_6: begin
			
			   //Y_address <= Y_address + 1'b1;
				
				//SRAM_address <= U_address;
				
				SRAM_address <= V_address;

			if (Column_counter < 7'd77)
				U_address <= U_address + 1'b1;
			
				V_prime_buf <= {V_prime_buf[31] == 1'b0 ? 8'b0 : 8'hff,V_prime_buf[31:8]}; //clipping for V (dividing by 256)
				
			if (Column_counter < 7'd78) begin
				U_shift_reg[0] <= U_shift_reg[1];
				U_shift_reg[1] <= U_shift_reg[2];
				U_shift_reg[2] <= U_shift_reg[3];
				U_shift_reg[3] <= U_shift_reg[4];
				U_shift_reg[4] <= U_shift_reg[5];
				U_shift_reg[5] <= U_register[7:0];
				
				V_shift_reg[0] <= V_shift_reg[1];
				V_shift_reg[1] <= V_shift_reg[2];
				V_shift_reg[2] <= V_shift_reg[3];
				V_shift_reg[3] <= V_shift_reg[4];
				V_shift_reg[4] <= V_shift_reg[5];
				V_shift_reg[5] <= V_register[7:0];
				
			end else begin
			
				U_shift_reg[0] <= U_shift_reg[1];
				U_shift_reg[1] <= U_shift_reg[2];
				U_shift_reg[2] <= U_shift_reg[3];
				U_shift_reg[3] <= U_shift_reg[4];
				U_shift_reg[4] <= U_shift_reg[5];
				
				V_shift_reg[0] <= V_shift_reg[1];
				V_shift_reg[1] <= V_shift_reg[2];
				V_shift_reg[2] <= V_shift_reg[3];
				V_shift_reg[3] <= V_shift_reg[4];
				V_shift_reg[4] <= V_shift_reg[5];
		
		    end 
				R_register <= $signed(Mult_result_1[31:0])  + $signed(Mult_result_2[31:0]);
				Common_Y_Value <= $signed(Mult_result_1[31:0]);
				
				M1_state <= M1_COMMON_7;
				
			end
			
			M1_COMMON_7: begin
		
				//U_address <= U_address + 1'b1;
				
			if (Column_counter < 7'd77)
				V_address <= V_address + 1'b1;
				
				SRAM_address <= Y_address;
				
				G_register <= $signed(Common_Y_Value) - $signed(Mult_result_1[31:0]) - $signed(Mult_result_2[31:0]);
				B_register <= $signed(Common_Y_Value) + $signed(Mult_result_3[31:0]);
				
				M1_state <= M1_COMMON_8;
				
			end
			
			M1_COMMON_8: begin
			
				U_register <= SRAM_read_data;  //**
			
				Y_address <= Y_address + 1'b1;
				
				SRAM_we_n <= 1'b0;
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				
				SRAM_write_data <= {R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16]),G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16])} ;//clipping
				
				
				R_register <= $signed(Mult_result_1[31:0])  + $signed(Mult_result_2[31:0]);
				Common_Y_Value <= $signed(Mult_result_1[31:0]);
				
				M1_state <= M1_COMMON_9;
				
			end
			
			
			M1_COMMON_9: begin
			
				V_register <= SRAM_read_data; 
				Column_counter <= Column_counter + 7'd1;
			
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				G_register <= $signed(Common_Y_Value) - $signed(Mult_result_1[31:0]) - $signed(Mult_result_2[31:0]);
				B_register <= $signed(Common_Y_Value) + $signed(Mult_result_3[31:0]);
				
				SRAM_write_data <= {B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16]), R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16])} ;//clipping
				
				M1_state <= M1_COMMON_10;
				
			end
			
			M1_COMMON_10: begin
			
				Y_register <= SRAM_read_data;  //**
			
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				SRAM_write_data <= {G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16]),B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16])}  ; ;//clipping
				
				U_prime_buf  <= 32'd128 + $signed(Mult_result_1[31:0])  - $signed(Mult_result_2[31:0])  + $signed(Mult_result_3[31:0]) ;
				
				M1_state <= M1_COMMON_11;
				
			end
			
			M1_COMMON_11: begin
			
				SRAM_we_n <= 1'b1;
				//SRAM_address <= Y U or V //for it to repeat next common?? **
				
				U_prime_buf <= {U_prime_buf[31] == 1'b0 ? 8'b0 : 8'hff,U_prime_buf[31:8]}; //clipping for U (dividing by 128)
				
				V_prime_buf  <= 32'd128 + $signed(Mult_result_1[31:0])  - $signed(Mult_result_2[31:0])  + $signed(Mult_result_3[31:0]) ;
				
				M1_state <= M1_COMMON_12;
				
				
			end
			
			M1_COMMON_12: begin
			
			
				V_prime_buf <= {V_prime_buf[31] == 1'b0 ? 8'b0 : 8'hff,V_prime_buf[31:8]}; //clipping for V (dividing by 128)
				
				if (Column_counter < 7'd78) begin
				
				U_shift_reg[0] <= U_shift_reg[1];
				U_shift_reg[1] <= U_shift_reg[2];
				U_shift_reg[2] <= U_shift_reg[3];
				U_shift_reg[3] <= U_shift_reg[4];
				U_shift_reg[4] <= U_shift_reg[5];
				U_shift_reg[5] <= U_register[15:8];
				
				V_shift_reg[0] <= V_shift_reg[1];
				V_shift_reg[1] <= V_shift_reg[2];
				V_shift_reg[2] <= V_shift_reg[3];
				V_shift_reg[3] <= V_shift_reg[4];
				V_shift_reg[4] <= V_shift_reg[5];
				V_shift_reg[5] <= V_register[15:8];
				
				end else begin 
				
				U_shift_reg[0] <= U_shift_reg[1];
				U_shift_reg[1] <= U_shift_reg[2];
				U_shift_reg[2] <= U_shift_reg[3];
				U_shift_reg[3] <= U_shift_reg[4];
				U_shift_reg[4] <= U_shift_reg[5];
				
				V_shift_reg[0] <= V_shift_reg[1];
				V_shift_reg[1] <= V_shift_reg[2];
				V_shift_reg[2] <= V_shift_reg[3];
				V_shift_reg[3] <= V_shift_reg[4];
				V_shift_reg[4] <= V_shift_reg[5];
				
				end
				
				R_register <= $signed(Mult_result_1[31:0])  + $signed(Mult_result_2[31:0]);
				Common_Y_Value <= $signed(Mult_result_1[31:0]);
				
				if (Column_counter < 7'd79)
				    M1_state <= M1_COMMON_1;
				else 
					M1_state <= M1_OUT_1;
			
			end
			
			M1_OUT_1:  begin
				
				G_register <= $signed(Common_Y_Value) - $signed(Mult_result_1[31:0]) - $signed(Mult_result_2[31:0]);
				B_register <= $signed(Common_Y_Value) + $signed(Mult_result_3[31:0]);
				
				SRAM_address <= Y_address; //fixed

				M1_state <= M1_OUT_2;
				
			end
			
			M1_OUT_2:  begin
				SRAM_we_n <= 1'b0;
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				SRAM_write_data <= {R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16]),G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16])} ;//clipping
				
				
				R_register <= $signed(Mult_result_1[31:0])  + $signed(Mult_result_2[31:0]);
				Common_Y_Value <= $signed(Mult_result_1[31:0]);
				
				M1_state <= M1_OUT_3;
			end
			
			M1_OUT_3: begin
			
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				G_register <= $signed(Common_Y_Value) - $signed(Mult_result_1[31:0]) - $signed(Mult_result_2[31:0]);
				B_register <= $signed(Common_Y_Value) + $signed(Mult_result_3[31:0]);
				
				SRAM_write_data <= {B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16]), R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16])} ;//clipping
				
				M1_state <= M1_OUT_4;
				
			end
			
			M1_OUT_4: begin

				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;

				Y_register <= SRAM_read_data; //** put in reg here after been read, also dont overright before been used
				
				SRAM_write_data <= {G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16]),B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16])}  ; //clipping
				
				U_prime_buf  <= 32'd128 + $signed(Mult_result_1[31:0])  - $signed(Mult_result_2[31:0])  + $signed(Mult_result_3[31:0]) ;
				
				M1_state <= M1_OUT_5;
				
				
			end
			
			M1_OUT_5: begin
				
				SRAM_we_n <= 1'b1;
				
				U_prime_buf <= {U_prime_buf[31] == 1'b0 ? 8'b0 : 8'hff,U_prime_buf[31:8]}; //clipping for U (dividing by 128)
				
				V_prime_buf  <= 32'd128 + $signed(Mult_result_1[31:0])  - $signed(Mult_result_2[31:0])  + $signed(Mult_result_3[31:0]) ;
				
				M1_state <= M1_OUT_6;
				
			end
			
			M1_OUT_6: begin
			
				V_prime_buf <= {V_prime_buf[31] == 1'b0 ? 8'b0 : 8'hff,V_prime_buf[31:8]}; //clipping for V (dividing by 128)
				
				R_register <= $signed(Mult_result_1[31:0])  + $signed(Mult_result_2[31:0]);
				Common_Y_Value <= $signed(Mult_result_1[31:0]);
				
				M1_state <= M1_OUT_7;
				
			end
			
			M1_OUT_7: begin
				
				G_register <= $signed(Common_Y_Value) - $signed(Mult_result_1[31:0]) - $signed(Mult_result_2[31:0]);
				B_register <= $signed(Common_Y_Value) + $signed(Mult_result_3[31:0]);
				
				M1_state <= M1_OUT_8;
				
			end
			
			M1_OUT_8: begin
				
				SRAM_we_n <= 1'b0;
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				
				SRAM_write_data <= {R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16]),G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16])} ;//clipping
				
				
				R_register <= $signed(Mult_result_1[31:0])  + $signed(Mult_result_2[31:0]);
				Common_Y_Value <= $signed(Mult_result_1[31:0]);
				
				M1_state <= M1_OUT_9;
				
			end
			
			
			M1_OUT_9: begin
			
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				G_register <= $signed(Common_Y_Value) - $signed(Mult_result_1[31:0]) - $signed(Mult_result_2[31:0]);
				B_register <= $signed(Common_Y_Value) + $signed(Mult_result_3[31:0]);
				
				SRAM_write_data <= {B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16]), R_register[31] ? 8'b0:(|R_register[30:24]? 8'd255:R_register[23:16])} ;//clipping
				
				M1_state <= M1_OUT_10;
				
			end
			
			M1_OUT_10: begin
			
				SRAM_address <= RGB_address;
				RGB_address <= RGB_address + 1'b1;
				
				SRAM_write_data <= {G_register[31] ? 8'b0:(|G_register[30:24]? 8'd255:G_register[23:16]),B_register[31] ? 8'b0:(|B_register[30:24]? 8'd255:B_register[23:16])}  ; ;//clipping
				
				M1_state <= M1_OUT_11;
				
			end
			
			M1_OUT_11: begin
			
			if(Row_counter == 9'd239) begin	
				   		
					Row_counter <= 9'd0;
					Column_counter <= 7'd0;					
					SRAM_we_n <= 1'b1;
					M1_end <= 1'b1;
					M1_state <= M1_IDLE;
					
				end else begin	
				
					Row_counter <= Row_counter + 9'd1; //keep inc till all finish
					SRAM_address <= U_address; //the beganning
					Y_address <= Y_address + 18'd1;
					//SRAM_address <= Y_address;
					SRAM_we_n <= 1'b1;
					Column_counter <= 7'd0;
					M1_state <= M1_LEAD_0;
					
				end	
			
			end
			
		
			
	//	end		
		default: M1_state <= M1_IDLE;
		endcase
	end
	
end


always_comb begin
		
		 Mult_1_op1 = 32'd0;
		 Mult_1_op2 = 32'd0;
		 
		 Mult_2_op1 = 32'd0;
		 Mult_2_op2 = 32'd0;
		 
		 Mult_3_op1 = 32'd0;
		 Mult_3_op2 = 32'd0;
		
		
		case (M1_state)
		
		M1_LEAD_8: begin 
		
		Mult_1_op1 = (32'd21);
		Mult_1_op2 = (U_shift_reg[0]) + $signed(U_shift_reg[5]);
		
		Mult_2_op1 = (32'd52);
		Mult_2_op2 = (U_shift_reg[0]) + $signed(U_shift_reg[4]);
		
		Mult_3_op1 = (32'd159);
		Mult_3_op2 = (U_shift_reg[0]) + $signed(U_shift_reg[3]);
			
		end
		
		M1_LEAD_9: begin
		
		Mult_1_op1 = (32'd21);
		Mult_1_op2 = (V_shift_reg[0]) + $signed(V_shift_reg[5]);
		
		Mult_2_op1 = (32'd52);
		Mult_2_op2 = (V_shift_reg[0]) + $signed(V_shift_reg[4]);
		
		Mult_3_op1 = (32'd159);
		Mult_3_op2 = (V_shift_reg[0]) + $signed(V_shift_reg[3]);
		
		end
		
		M1_LEAD_10 : begin
		
		Mult_1_op1 = $signed(32'd76284);
		Mult_1_op2 = $signed((Y_register[15:8]) - 32'd16);
		
		Mult_2_op1 = $signed(32'd104595);
		Mult_2_op2 = $signed((V_shift_reg[2]) -32'd128); //[2]
		
		end
		
		M1_COMMON_1 : begin
		
		Mult_1_op1 = $signed(32'd25624);
		Mult_1_op2 = $signed((U_shift_reg[1]) - 32'd128);
	
		Mult_2_op1 = $signed(32'd53281);
		Mult_2_op2 = $signed((V_shift_reg[1]) - 32'd128);
		
		Mult_3_op1 = $signed(32'd132251);
		Mult_3_op2 = $signed((U_shift_reg[1]) - 32'd128);
		
		end
		
		M1_COMMON_2: begin
		
		Mult_1_op1 = $signed(32'd76284);
		Mult_1_op2 = $signed(Y_register[7:0] - 32'd16);
		
		Mult_2_op1 = $signed(32'd104595);
		Mult_2_op2 = $signed(V_prime_buf -32'd128);
		
		end
		
		M1_COMMON_3: begin
					
		Mult_1_op1 = $signed(32'd25624);
		Mult_1_op2 = $signed(U_prime_buf - 32'd128);
	
		Mult_2_op1 = $signed(32'd53281);
		Mult_2_op2 = $signed(V_prime_buf - 32'd128);
		
		Mult_3_op1 = $signed(32'd132251);
		Mult_3_op2 = $signed(U_prime_buf - 32'd128);
			
		end
		
		M1_COMMON_4: begin	
				
		Mult_1_op1 = (32'd21);
		Mult_1_op2 = (U_shift_reg[0]) + (U_shift_reg[5]);
		
		Mult_2_op1 = (32'd52);
		Mult_2_op2 = (U_shift_reg[1]) + (U_shift_reg[4]);
		
		Mult_3_op1 = (32'd159);
		Mult_3_op2 = (U_shift_reg[2])+ (U_shift_reg[3]);
		
		end
		
		M1_COMMON_5: begin
		 			
		Mult_1_op1 = (32'd21);
		Mult_1_op2 = (V_shift_reg[0]) + (V_shift_reg[5]);
		
		Mult_2_op1 = (32'd52);
		Mult_2_op2 = (V_shift_reg[1]) + (V_shift_reg[4]);
		
		Mult_3_op1 = (32'd159);
		Mult_3_op2 = (V_shift_reg[2]) + (V_shift_reg[3]); 
		
		end

		M1_COMMON_6: begin
		
		Mult_1_op1 =  $signed(32'd76284);
		Mult_1_op2 = $signed((Y_register[15:8]) - 32'd16);
		Mult_2_op1 =  $signed(32'd104595);
		Mult_2_op2 = $signed(V_shift_reg[2] -32'd128); //[2]

		end
		
		M1_COMMON_7: begin
						
		Mult_1_op1 =  $signed(32'd25624);
		Mult_1_op2 = $signed(U_shift_reg[1] - 32'd128);
	
		Mult_2_op1 =  $signed(32'd53281);
		Mult_2_op2 = $signed(V_shift_reg[1] - 32'd128);
		
		Mult_3_op1 =  $signed(32'd132251);
		Mult_3_op2 = $signed(U_shift_reg[1] - 32'd128);
		
		end
		
		M1_COMMON_8: begin
		
		Mult_1_op1 = $signed(32'd76284);
		Mult_1_op2 = $signed(Y_register[7:0] - 32'd16);
		
		Mult_2_op1 = $signed(32'd104595);
		Mult_2_op2 = $signed(V_prime_buf - 32'd128);
		
		end
		
		M1_COMMON_9: begin
					
		Mult_1_op1 = $signed(32'd25624);
		Mult_1_op2 = $signed(U_prime_buf - 32'd128);
	
		Mult_2_op1 = $signed(32'd53281);
		Mult_2_op2 = $signed(V_prime_buf - 32'd128);
		
		Mult_3_op1 = $signed(32'd132251);
		Mult_3_op2 = $signed(U_prime_buf - 32'd128);
			
		end
		
		M1_COMMON_10: begin	//got fix 10 n 11
				
		Mult_1_op1 = 32'd21;
		Mult_1_op2 = (U_shift_reg[0]) + (U_shift_reg[5]);
		
		Mult_2_op1 = 32'd52;
		Mult_2_op2 = (U_shift_reg[1]) + (U_shift_reg[4]);
		
		Mult_3_op1 = 32'd159;
		Mult_3_op2 = (U_shift_reg[2]) + (U_shift_reg[3]);
		
		end
		
		M1_COMMON_11: begin
		 			
		Mult_1_op1 = 32'd21;
		Mult_1_op2 = (V_shift_reg[0]) + (V_shift_reg[5]);
		
		Mult_2_op1 = 32'd52;
		Mult_2_op2 = (V_shift_reg[1])+ (V_shift_reg[4]);
		
		Mult_3_op1 = 32'd159;
		Mult_3_op2 = (V_shift_reg[2]) + (V_shift_reg[3]); 
		
		end
		
		M1_COMMON_12 : begin
		
		Mult_1_op1 = 32'd76284;
		Mult_1_op2 = $signed((Y_register[15:8]) - 32'd16);
		
		Mult_2_op1 = 32'd104595;
		Mult_2_op2 = $signed((V_shift_reg[2]) -32'd128); //[2]
		
		end
		
		M1_OUT_1 : begin
		
		Mult_1_op1 = 32'd25624;
		Mult_1_op2 = $signed((U_shift_reg[1]) - 32'd128);
	
		Mult_2_op1 = 32'd53281;
		Mult_2_op2 = $signed((V_shift_reg[1]) - 32'd128);
		
		Mult_3_op1 = 32'd132251;
		Mult_3_op2 = $signed((U_shift_reg[1]) - 32'd128);
		
		end
		
		M1_OUT_2: begin
		
		Mult_1_op1 = 32'd76284;
		Mult_1_op2 = $signed(Y_register[7:0] - 32'd16);
		
		Mult_2_op1 = 32'd104595;
		Mult_2_op2 = $signed(V_prime_buf -32'd128);
		
		end
		
		M1_OUT_3: begin
					
		Mult_1_op1 = $signed(32'd25624);
		Mult_1_op2 = $signed(U_prime_buf - 32'd128);
	
		Mult_2_op1 = $signed(32'd53281);
		Mult_2_op2 = $signed(V_prime_buf - 32'd128);
		
		Mult_3_op1 = $signed(32'd132251);
		Mult_3_op2 = $signed(U_prime_buf - 32'd128);
			
		end
		
		M1_OUT_4: begin	//HAVE TO CHK U AND V REG HERE!!
				
		Mult_1_op1 = 32'd21;
		Mult_1_op2 = (U_shift_reg[0]) + (U_shift_reg[5]);
		
		Mult_2_op1 = 32'd52;
		Mult_2_op2 = (U_shift_reg[1]) + (U_shift_reg[4]);
		
		Mult_3_op1 = 32'd159;
		Mult_3_op2 = (U_shift_reg[2])+ (U_shift_reg[3]);
		
		end
		
		M1_OUT_5: begin
		 			
		Mult_1_op1 = 32'd21;
		Mult_1_op2 = (V_shift_reg[0]) +(V_shift_reg[5]);
		
		Mult_2_op1 = 32'd52;
		Mult_2_op2 = (V_shift_reg[1]) + (V_shift_reg[4]);
		
		Mult_3_op1 = 32'd159;
		Mult_3_op2 = (V_shift_reg[2]) + (V_shift_reg[3]); 
		
		end

		M1_OUT_6: begin
		
		Mult_1_op1 = $signed(32'd76284);
		Mult_1_op2 = $signed((Y_register[15:8]) - 32'd16);
		
		Mult_2_op1 = $signed(32'd104595);
		Mult_2_op2 = $signed(V_shift_reg[2] -32'd128); //[2]

		end
		
		M1_OUT_7: begin
						
		Mult_1_op1 = $signed(32'd25624);
		Mult_1_op2 = $signed(U_shift_reg[2] - 32'd128);
	
		Mult_2_op1 = $signed(32'd53281);
		Mult_2_op2 = $signed(V_shift_reg[2] - 32'd128);
		
		Mult_3_op1 = $signed(32'd132251);
		Mult_3_op2 = $signed(U_shift_reg[2] - 32'd128);
		
		end
		
		M1_OUT_8: begin
		
		Mult_1_op1 = $signed(32'd76284);
		Mult_1_op2 = $signed(Y_register[7:0] - 32'd16);
		
		Mult_2_op1 = $signed(32'd104595);
		Mult_2_op2 = $signed(V_prime_buf -32'd128);
		
		end
		
		M1_OUT_9: begin
					
		Mult_1_op1 = $signed(32'd25624);
		Mult_1_op2 = $signed(U_prime_buf - 32'd128);
	
		Mult_2_op1 = $signed(32'd53281);
		Mult_2_op2 = $signed(V_prime_buf - 32'd128);
		
		Mult_3_op1 = $signed(32'd132251);
		Mult_3_op2 = $signed(U_prime_buf - 32'd128);
			
		end

endcase 

end 	
		
		



endmodule
