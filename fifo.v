
`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:   pku_ims
// Engineer: 
// Copyright(c) 2016,  IMS&SoC Lab
// Create Date:    23:37:28 11/02/2016 
// Design Name:    fifo
// Module Name:    fifo 
// Project Name:   fifo
// Target Devices: 
// Tool versions: 
// Description: 
// Author     : Chenglong Zou
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

 module fifo #
  (
       // FIFO: Data Width
	   parameter integer FIFO_DATA_WIDTH	= 20     
   )
    (
       input  wire        clk,
       input  wire        rst_n,
	   
       
       input  wire [FIFO_DATA_WIDTH-1:0] data_in,
       input  wire        writep,
       input  wire        readp,
	   
      
       output reg [FIFO_DATA_WIDTH-1:0] data_out,
       output reg         fullp,
       output reg         emptyp     
  
     );

  // Total number of input data
   localparam NUMBER_OF_INPUT_WORDS  = 8;

   //检测需要的位宽
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction                 
   
  localparam bit_num  = clogb2(NUMBER_OF_INPUT_WORDS-1); 
   
   
   
parameter	
		FULL = 3'd7,	//bit_num 'd (NUMBER_OF_INPUT_WORDS-1)
		EMPTY = 3'd0;	


reg [bit_num-1:0]	tail;
reg [bit_num-1:0]	head;

// Define the FIFO counter.  Counts the number of entries in the FIFO which
// is how we figure out things like Empty and Full.
//
reg [bit_num-1:0]	count;

// Define our regsiter bank.  This is actually synthesizable!


reg [FIFO_DATA_WIDTH-1:0] fifomem[0:NUMBER_OF_INPUT_WORDS-1];

// Dout is registered and gets the value that tail points to RIGHT NOW.
//

always @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      
      data_out <= 0;
   end
   //read
   else if(readp==1'b1&&emptyp==1'b0) begin
      data_out<= fifomem[tail];
   end
end 
     
// Update FIFO memory.
//write
/*always @(posedge clk)
   if (rst_n == 1'b0) begin
     if (writep == 1'b1 && fullp == 1'b0)
      fifomem[head] <=data_in;
   end*/

   
   
   
// Update the head register.
//
always @(posedge clk) begin
   if (!rst_n) begin
     head <= 0;
   end
   else begin
      if (writep == 1'b1 && fullp == 1'b0) begin
         // WRITE
		 fifomem[head] <=data_in;
         head <= head + 1;
		 
      end
   end
end

// Update the tail register.
//
always @(posedge clk) begin
   if (!rst_n) begin
      tail <= 0;
   end
   else begin
      if (readp == 1'b1 && emptyp == 1'b0) begin
         // READ               
         tail <= tail + 1;
      end
   end
end

// Update the count regsiter.
//
always @(posedge clk) begin
   if (!rst_n) begin
      count <= 0;
   end
   
   else begin
      case ({readp, writep})
         2'b00: count <= count;
         2'b01: 
            // WRITE
            if (!fullp) 
               count <= count + 1;
         2'b10: 
            // READ
            if (!emptyp)
               count <= count - 1;
         2'b11:
            // Concurrent read and write.
			
            count <= count;
			
      endcase
	  
	  
   end
end

         
// *** Update the flags
//
// First, update the empty flag.

/*always @(posedge clk) begin
if (!rst_n) begin
      emptyp <= 1'b1;
      fullp <= 1'b0;
    end
else begin
    case(count)
	7'd0: begin emptyp <= 1'b1;fullp <= 1'b0; end
	7'd79: begin emptyp <= 1'b0;fullp <= 1'b1; count<=count;end
	default : begin emptyp <= 1'b0;fullp <= 1'b0; end
    endcase

end
end*/





always @(count) begin
   if (count == EMPTY)
     emptyp = 1'b1;
   else
     emptyp = 1'b0;
end


// Update the full flag
always @(count) begin
   if (count < FULL)
      fullp = 1'b0;
   else
      fullp = 1'b1;
end

endmodule

