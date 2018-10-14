
`timescale 1 ns / 1 ps

	module my_dma_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here
		
		output wire                            hw_active,
        output wire [C_S_AXI_DATA_WIDTH-1:0]   src_addr,
        output wire                    [2:0]   is_face,
        output wire                            sad_active,
        input  wire                            row_done,
        input  wire                            all_done,
        input  wire [C_S_AXI_DATA_WIDTH-1:0]   data,
        input  wire                            rvalid,

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 3;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 16
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg8;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg9;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg10;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg11;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg13;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg14;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg15;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
	      slv_reg4 <= 0;
	      slv_reg5 <= 0;
	      slv_reg6 <= 0;
	      slv_reg7 <= 0;
	      slv_reg8 <= 0;
	      slv_reg9 <= 0;
	      slv_reg10 <= 0;
	      slv_reg11 <= 0;
	      slv_reg12 <= 0;
	      slv_reg13 <= 0;
	      slv_reg14 <= 0;
	      slv_reg15 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          4'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h4:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 4
	                slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h5:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 5
	                slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h6:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 6
	                slv_reg6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h7:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 7
	                slv_reg7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h8:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 8
	                slv_reg8[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h9:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 9
	                slv_reg9[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hA:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 10
	                slv_reg10[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hB:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 11
	                slv_reg11[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hC:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 12
	                slv_reg12[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hD:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 13
	                slv_reg13[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hE:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 14
	                slv_reg14[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hF:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 15
	                slv_reg15[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                      slv_reg4 <= slv_reg4;
	                      slv_reg5 <= slv_reg5;
	                      slv_reg6 <= slv_reg6;
	                      slv_reg7 <= slv_reg7;
	                      slv_reg8 <= slv_reg8;
	                      slv_reg9 <= slv_reg9;
	                      slv_reg10 <= slv_reg10;
	                      slv_reg11 <= slv_reg11;
	                      slv_reg12 <= slv_reg12;
	                      slv_reg13 <= slv_reg13;
	                      slv_reg14 <= slv_reg14;
	                      slv_reg15 <= slv_reg15;
	                    end
	        endcase
	      end
	    else begin
          // slv_reg0  <= (hw_done)? 32'd0 : slv_reg0;
          slv_reg0  <= (hw_done && ((src_addr+4)>=dst_addr))? 32'd0    :  slv_reg0;
          slv_reg4  <= (hw_done && ((src_addr+4)>=dst_addr))? posx[0]  :  slv_reg4;
          slv_reg5  <= (hw_done && ((src_addr+4)>=dst_addr))? posy[0]  :  slv_reg5;
          slv_reg6  <= (hw_done && ((src_addr+4)>=dst_addr))? sad[0]   :  slv_reg6;
          slv_reg7  <= (hw_done && ((src_addr+4)>=dst_addr))? posx[1]  :  slv_reg7;
          slv_reg8  <= (hw_done && ((src_addr+4)>=dst_addr))? posy[1]  :  slv_reg8;
          slv_reg9  <= (hw_done && ((src_addr+4)>=dst_addr))? sad[1]   :  slv_reg9;
          slv_reg10 <= (hw_done && ((src_addr+4)>=dst_addr))? posx[2]  : slv_reg10;
          slv_reg11 <= (hw_done && ((src_addr+4)>=dst_addr))? posy[2]  : slv_reg11;
          slv_reg12 <= (hw_done && ((src_addr+4)>=dst_addr))? sad[2]   : slv_reg12;
          slv_reg13 <= (hw_done && ((src_addr+4)>=dst_addr))? posx[3]  : slv_reg13;
          slv_reg14 <= (hw_done && ((src_addr+4)>=dst_addr))? posy[3]  : slv_reg14;
          slv_reg15 <= (hw_done && ((src_addr+4)>=dst_addr))? sad[3]   : slv_reg15;
        end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        4'h0   : reg_data_out <= slv_reg0;
	        4'h1   : reg_data_out <= slv_reg1;
	        4'h2   : reg_data_out <= slv_reg2;
	        4'h3   : reg_data_out <= slv_reg3;
	        4'h4   : reg_data_out <= slv_reg4;
	        4'h5   : reg_data_out <= slv_reg5;
	        4'h6   : reg_data_out <= slv_reg6;
	        4'h7   : reg_data_out <= slv_reg7;
	        4'h8   : reg_data_out <= slv_reg8;
	        4'h9   : reg_data_out <= slv_reg9;
	        4'hA   : reg_data_out <= slv_reg10;
	        4'hB   : reg_data_out <= slv_reg11;
	        4'hC   : reg_data_out <= slv_reg12;
	        4'hD   : reg_data_out <= slv_reg13;
	        4'hE   : reg_data_out <= slv_reg14;
	        4'hF   : reg_data_out <= slv_reg15;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
	
	reg sad_start;
    reg sad_done;
    reg hw_done;      
    
    wire [C_S_AXI_DATA_WIDTH-1:0] dst_addr;
    reg  [C_S_AXI_DATA_WIDTH-1:0] reg_src_addr;
    reg                           active;
    reg  [3:0]                    wait_restart;
    reg  [10:0]                   now_col;
    
    assign hw_active = (hw_done)? 0 : active; // (| slv_reg0);
    assign src_addr  = reg_src_addr; // slv_reg1;
    assign is_face   = slv_reg2[2:0];
    
    assign dst_addr  = slv_reg3;
    
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN == 1'b0) reg_src_addr <= 0;
      else if (slv_reg0 == 0) reg_src_addr <= slv_reg1;
      else if (hw_done) reg_src_addr <= reg_src_addr + 4;
      else reg_src_addr <= reg_src_addr;
    end
    
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN == 1'b0) active <= 0;
      else if (slv_reg0 == 0) active <= 0;
      else if (hw_done) active <= 0;
      else if (wait_restart == 15) active <= 1;
      else active <= 1; 
    end
    
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN == 1'b0) wait_restart <= 0;
      else if (hw_done || wait_restart) wait_restart <= (wait_restart == 15)? 0 : wait_restart + 1;
      else wait_restart <= 0;
    end
    
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN == 1'b0) now_col <= 0;
      else if (slv_reg0 == 0) now_col <= 0;
      else if (hw_done) now_col <= now_col + 4;
      else now_col <= now_col;
    end 
    
    //****************************************************************
    //*                            FSM                               *
    //****************************************************************
    parameter [1:0]
      INIT_SAD  = 2'b00,
      FIRST_ROW = 2'b01,
      EXEC_SAD  = 2'b10,
      LAST_SAD  = 2'b11;
    
    reg [ 1:0] ctrl_sad_state;
    reg [10:0] row;
    reg        reg_sad_active;
          
    assign sad_active = (sad_start||reg_sad_active) && (!o_sad_done);
    
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN == 1'b0) reg_sad_active <= 0;
      else if (o_sad_done) reg_sad_active <= 0;
      else if (sad_start) reg_sad_active <= 1;
      else reg_sad_active <= reg_sad_active;
    end
    
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN == 1'b0) begin
        ctrl_sad_state <= INIT_SAD;
      end
      else begin
        case (ctrl_sad_state)
        
          // INIT_SAD
          INIT_SAD: begin
            sad_start <= 0;
            sad_done <= 0;
            hw_done <= 0;
            row <= 0;
            if (hw_active) begin
              ctrl_sad_state <= FIRST_ROW;
              row <= 0;
            end
            else ctrl_sad_state <= INIT_SAD;
          end
            
          // FIRST_ROW
          FIRST_ROW:
            if ((i_write[0]||i_write[1]||i_write[2]||i_write[3]||i_write[4]) && (bank==31)) begin 
              if (is_face == 0) begin
                ctrl_sad_state <= EXEC_SAD;
                sad_start <= 1;
              end
              else begin
                ctrl_sad_state <= INIT_SAD;
                hw_done <= 1;
              end
            end
            else ctrl_sad_state <= FIRST_ROW;
            
          // EXEC_SAD
          EXEC_SAD:
            if (o_sad_done) sad_done <= 1;
            else if (sad_done) begin
              if (write_state == W_END_COPY) begin
                ctrl_sad_state <= LAST_SAD;
                sad_start <= 1;
                sad_done <= 0;
                row <= row + 1;
              end
              else if (write_state == W_WAIT_SAD) begin
                sad_start <= 1;
                sad_done <= 0;
                row <= row + 1;
              end
              else sad_done <= 1;
            end
            else sad_start <= 0;
            
          // LAST_SAD
          LAST_SAD:
            if (o_sad_done) begin 
              ctrl_sad_state <= INIT_SAD;
              hw_done <= 1;
            end
            else sad_start <= 0; 
            
        endcase
      end
    end
    //****************************************************************
    //*                          End FSM                             *
    //****************************************************************
    
    //****************************************************************
    //*                           BRAM                               *
    //****************************************************************  
    integer idx;
    localparam integer BRAM_NUM = 5;
    
    reg  [  5:0]    bank, now_grow, now_frow;
    wire [  5:0]    i_gaddr, i_faddr;
    reg             i_write [0:BRAM_NUM-1];  // i_write[0] for group, 1~4 for face 1~4.
    reg  [287:0]    i_data;
    wire [287:0]    o_gdata;  // output group data
    wire [255:0]    o_fdata [0:BRAM_NUM-2];  // output face data
    
    //*******************
    //* Address control *
    //*******************
    assign i_gaddr = (sad_active)? now_grow : bank;
    assign i_faddr = (sad_active)? now_frow : bank;
    
    // Insert data into row "bank". (Address for write operation)
    always @(posedge S_AXI_ACLK) begin
      if (hw_active == 0) bank <= 32;
      else if (row_done) bank <= (bank >= 31)? 0 : bank+1;
      else bank <= bank;
    end
    
    // Get the value of bram at row "now_row". (Address for read operation)
    always @(posedge S_AXI_ACLK) begin
      if (hw_active == 0) begin
        now_grow <= 0;
        now_frow <= 0;
      end
      else if (sad_active) begin
        now_grow <= (now_grow == 31)? 0 : now_grow+1;
        now_frow <= (now_frow == 31)? now_frow : now_frow+1;
      end
      else begin
        now_grow <= (bank == 31)? 0 : bank+1;
        now_frow <= 0;
      end
    end
    //*******************
    
    //**********************
    //* Read/Write control *
    //**********************
    parameter [1:0]
      W_WAIT_COPY = 2'b00, 
      W_WAIT_SAD  = 2'b01,
      W_END_COPY  = 2'b10;
    
    reg [1:0] write_state;
    
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN == 1'b0) begin
        write_state <= W_WAIT_COPY;
        for (idx = 0; idx < BRAM_NUM; idx = idx + 1)
          i_write[idx] <= 0;
      end
      else if (ctrl_sad_state == FIRST_ROW) begin
        i_write[is_face] <= row_done;
      end
      else begin
        case (write_state)
          
          // W_WAIT_COPY
          W_WAIT_COPY: begin
            for (idx = 0; idx < BRAM_NUM; idx = idx + 1)
              i_write[idx] <= 0;
            if (row_done == 0) write_state <= W_WAIT_COPY;
            else begin
              if (all_done) write_state <= W_END_COPY;
              else write_state <= W_WAIT_SAD;
              if (sad_done || o_sad_done) i_write[is_face] <= 1;
            end
          end
          
          // W_WAIT_SAD  
          W_WAIT_SAD:
            if (o_sad_done) begin
              i_write[is_face] <= 1;
            end
            else if (sad_done) begin
              write_state <= W_WAIT_COPY;
              i_write[is_face] <= 0;
            end
            else write_state <= W_WAIT_SAD;
            
          // W_END_COPY
          W_END_COPY: begin
            if (i_write[is_face]) i_write[is_face] <= 0;
            else if (o_sad_done) i_write[is_face] <= 1;
            else i_write[is_face] <= 0;
            
            if (hw_active) write_state <= W_END_COPY;
            else write_state <= W_WAIT_COPY;
          end
            
        endcase
      end
    end
    //*******************
    
    always @(posedge S_AXI_ACLK) begin
      if (rvalid) i_data <= { data, i_data[287:32] }; //{ i_data[255:0], data };
      else i_data <= i_data;
    end
    
    //**************************
    // Group image
    //**************************
    bram # (
        .ADDR_WIDTH(6),
        .DATA_WIDTH(288),
        .DEPTH(32)
    ) group_bram_inst (
        .i_clk(S_AXI_ACLK),
        .i_addr(i_gaddr[4:0]),
        .i_write(i_write[0]),
        .i_data(i_data),
        .o_data(o_gdata)
    );
    
    //**************************
    // Face 1 image
    //**************************
    bram # (
        .ADDR_WIDTH(6),
        .DATA_WIDTH(256),
        .DEPTH(32)
    ) face_1_bram_inst (
        .i_clk(S_AXI_ACLK),
        .i_addr(i_faddr[4:0]),
        .i_write(i_write[1]),
        .i_data(i_data[287:32]),
        .o_data(o_fdata[0])
    );
        
    //**************************
    // Face 2 image
    //**************************
    bram # (
        .ADDR_WIDTH(6),
        .DATA_WIDTH(256),
        .DEPTH(32)
    ) face_2_bram_inst (
        .i_clk(S_AXI_ACLK),
        .i_addr(i_faddr[4:0]),
        .i_write(i_write[2]),
        .i_data(i_data[287:32]),
        .o_data(o_fdata[1])
    );
            
    //**************************
    // Face 3 image
    //**************************
    bram # (
        .ADDR_WIDTH(6),
        .DATA_WIDTH(256),
        .DEPTH(32)
    ) face_3_bram_inst (
        .i_clk(S_AXI_ACLK),
        .i_addr(i_faddr[4:0]),
        .i_write(i_write[3]),
        .i_data(i_data[287:32]),
        .o_data(o_fdata[2])
    );
     
    //**************************
    // Face 4 image
    //**************************
    bram # (
        .ADDR_WIDTH(6),
        .DATA_WIDTH(256),
        .DEPTH(32)
    ) face_4_bram_inst (
        .i_clk(S_AXI_ACLK),
        .i_addr(i_faddr[4:0]),
        .i_write(i_write[4]),
        .i_data(i_data[287:32]),
        .o_data(o_fdata[3])
    );
    
    //****************************************************************
    //*                          End BRAM                            *
    //****************************************************************
    
    //****************************************************************
    //*                        Compute sad                           *
    //****************************************************************
    wire        o_sad_done;
    wire [31:0] o_sad  [0:BRAM_NUM-2];
    reg  [31:0] sad    [0:BRAM_NUM-2];
    wire [10:0] o_posx [0:BRAM_NUM-2];
    reg  [10:0] posx   [0:BRAM_NUM-2];
    reg  [10:0] posy   [0:BRAM_NUM-2];
    
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN == 1'b0) begin
        for (idx = 0; idx < BRAM_NUM-1; idx = idx + 1) begin
          sad[idx]  <= 32'hFFFFFFFF;
          posx[idx] <= 0;
          posy[idx] <= 0;
        end
      end
      else if (slv_reg0 == 0) begin
        for (idx = 0; idx < BRAM_NUM-1; idx = idx + 1) begin
          sad[idx]  <= 32'hFFFFFFFF;
          posx[idx] <= 0;
          posy[idx] <= 0;
        end
      end
      else if (o_sad_done) begin
        for (idx = 0; idx < BRAM_NUM-1; idx = idx + 1) begin
          if (o_sad[idx] < sad[idx]) begin
            sad[idx]  <= o_sad[idx];
            posx[idx] <= now_col + o_posx[idx];
            posy[idx] <= row;
          end
          else begin
            sad[idx]  <= sad[idx];
            posx[idx] <= posx[idx];
            posy[idx] <= posy[idx];
          end
        end
      end
    end
      
    //**************************
    // Face 1 compute sad
    //**************************    
    compute_sad face1_sad_inst (
      .clk(S_AXI_ACLK),
      .sad_start(sad_start),
      .face(o_fdata[0]),
      .group(o_gdata),
      .sad_done(o_sad_done),
      .posx(o_posx[0]),
      .sad(o_sad[0])
    );
    
    //**************************
    // Face 2 compute sad
    //**************************
    compute_sad face2_sad_inst (
      .clk(S_AXI_ACLK),
      .sad_start(sad_start),
      .face(o_fdata[1]),
      .group(o_gdata),
      .sad_done(),
      .posx(o_posx[1]),
      .sad(o_sad[1])
    );
    
    //**************************
    // Face 3 compute sad
    //**************************    
    compute_sad face3_sad_inst (
      .clk(S_AXI_ACLK),
      .sad_start(sad_start),
      .face(o_fdata[2]),
      .group(o_gdata),
      .sad_done(),
      .posx(o_posx[2]),
      .sad(o_sad[2])
    );
    
    //**************************
    // Face 4 compute sad
    //**************************        
    compute_sad face4_sad_inst (
      .clk(S_AXI_ACLK),
      .sad_start(sad_start),
      .face(o_fdata[3]),
      .group(o_gdata),
      .sad_done(),
      .posx(o_posx[3]),
      .sad(o_sad[3])
    );
    //****************************************************************
    //*                     End compute sad                          *
    //****************************************************************

	// User logic ends

	endmodule
