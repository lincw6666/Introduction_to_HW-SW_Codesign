`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/25 19:08:09
// Design Name: 
// Module Name: compute_sad_kernel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module compute_sad_kernel (
	input wire			clk,
	input wire			sad_active,
	input wire	[255:0]	face,
	input wire	[255:0] group,
	input wire          sad_valid,
	input wire			sad_done,
	output reg  [ 31:0]	sad
	);

	integer idx;
	genvar  jdx;

	reg  [31:0] abs_diff[0:31];
    wire [31:0] sum_1[0:15];
    wire [31:0] sum_2[0:7];
    reg  [31:0] sum_3[0:3];
    wire [31:0] sum_4[0:1];
        
    //******************************************
    //* Absolute difference
    //******************************************
    always @(posedge clk) begin
      if (sad_active == 1'b0) begin
        for (idx = 0; idx < 32; idx = idx + 1)
          abs_diff[idx] <= 0;
      end
      else begin
        for (idx = 0; idx < 32; idx = idx + 1) begin
          if (face[(idx*8)+:8] > group[(idx*8)+:8])
            abs_diff[idx] <= face[(idx*8)+:8] - group[(idx*8)+:8];
          else
            abs_diff[idx] <= group[(idx*8)+:8] - face[(idx*8)+:8];
        end
      end
    end
    
    //******************************************
    //* Adder tree
    //******************************************
    generate
      for (jdx = 0; jdx < 16; jdx = jdx+1)
      begin: level_1
        assign sum_1[jdx] = abs_diff[jdx*2] + abs_diff[jdx*2+1];
      end
    endgenerate
    
    generate
      for (jdx = 0; jdx < 8; jdx = jdx+1)
      begin: level_2
        assign sum_2[jdx] = sum_1[jdx*2] + sum_1[jdx*2+1];
      end
    endgenerate
    
    always @(posedge clk) begin
      for (idx = 0; idx < 4; idx = idx + 1) begin
        sum_3[idx] <= sum_2[idx*2] + sum_2[idx*2+1];
      end
    end
    
    generate
      for (jdx = 0; jdx < 2; jdx = jdx+1)
      begin: level_4
        assign sum_4[jdx] = sum_3[jdx*2] + sum_3[jdx*2+1];
      end
    endgenerate
    
    always @(posedge clk)
    begin
	  if (sad_active) begin
	    if (sad_done) sad <= sad;
	    else if (sad_valid) sad <= sad + sum_4[0] + sum_4[1];
		else sad <= sad;
	  end
	  else sad <= 0;
    end	

endmodule
