`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/20 13:41:37
// Design Name: 
// Module Name: compute_sad
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


module compute_sad(
    input  wire             clk,
    input  wire             sad_start,
    input  wire   [255:0]   face,
    input  wire   [287:0]   group,
    output wire             sad_done,
    output  reg   [ 10:0]   posx,
    output  reg   [ 31:0]   sad
    );
    
    integer idx;
    genvar  jdx;
    
    wire        sad_active;
	wire		sad_valid;
    reg         sad_start2;
    reg  [ 5:0] now_stage;
	wire [31:0] tmp_sad[0:3];
    
    //*********
    //* sad 1 *
	//*********
	compute_sad_kernel sad1 (
	  .clk(clk),
	  .sad_active(sad_active),
	  .face(face),
	  .group(group[255:0]),
	  .sad_valid(sad_valid),
	  .sad_done(sad_done),
	  .sad(tmp_sad[0])
	);

 	//*********
    //* sad 2 *
	//*********
	compute_sad_kernel sad2 (
	  .clk(clk),
	  .sad_active(sad_active),
	  .face(face),
	  .group(group[263:8]),
	  .sad_valid(sad_valid),
	  .sad_done(sad_done),
	  .sad(tmp_sad[1])
	);

 	//*********
    //* sad 3 *
	//*********
	compute_sad_kernel sad3 (
	  .clk(clk),
	  .sad_active(sad_active),
	  .face(face),
	  .group(group[271:16]),
	  .sad_valid(sad_valid),
	  .sad_done(sad_done),
	  .sad(tmp_sad[2])
	);

	//*********
    //* sad 4 *
	//*********
	compute_sad_kernel sad4 (
	  .clk(clk),
	  .sad_active(sad_active),
	  .face(face),
	  .group(group[279:24]),
	  .sad_valid(sad_valid),
	  .sad_done(sad_done),
	  .sad(tmp_sad[3])
	);

	//*******************************************************
    //*  Choose minimum sad.
    //*******************************************************
	wire [31:0] min01, min23;	// min sad of (sad1, sad2) , (sad3, sad4)
	wire [10:0] y01, y23;

	assign min01 = (tmp_sad[0] < tmp_sad[1])? tmp_sad[0] : tmp_sad[1];
	assign min23 = (tmp_sad[2] < tmp_sad[3])? tmp_sad[2] : tmp_sad[3];
	assign y01 = (tmp_sad[0] < tmp_sad[1])? 0 : 1;
	assign y23 = (tmp_sad[2] < tmp_sad[3])? 2 : 3;
	
	always @(posedge clk) begin
	  if (now_stage == 35) begin
	    posx <= (min01 < min23)? y01 : y23;
	    sad  <= (min01 < min23)? min01 : min23;
	  end
	  else begin
	    posx <= posx;
	    sad <= sad;
	  end
	end

    //*******************************************************
    //*  Controls signal.
    //*******************************************************
    assign sad_active = sad_start || sad_start2;    
    assign sad_valid = (now_stage>=3) && (now_stage<35);
	assign sad_done = (now_stage == 36);
    
    always @(posedge clk) begin
      if (sad_done) sad_start2 <= 0;
      else if (sad_active) sad_start2 <= 1;
      else sad_start2 <= 0;
    end
    
    always @(posedge clk) begin
      if (sad_active == 0) now_stage <= 6'd0;
      else now_stage <= (now_stage == 36)? 0 : now_stage+1;
    end

endmodule
