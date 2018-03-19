module AXISlave(
   // Global Signals
   ACLK,
   ARESETn,

   // Write Address Channel
   AWID,
   AWADDR,
   AWLEN,
   AWSIZE,
   AWBURST,
   AWLOCK,
   AWCACHE,
   AWPROT,
   AWUSER,
   AWVALID,
   AWREADY,

   // Write Channel
   WID,
   WLAST,
   WDATA,
   WSTRB,
   WUSER,
   WVALID,
   WREADY,

   // Write Response Channel
   BID,
   BRESP,
   BUSER,
   BVALID,
   BREADY,

   // Read Address Channel
   ARID,
   ARADDR,
   ARLEN,
   ARSIZE,
   ARBURST,
   ARLOCK,
   ARCACHE,
   ARPROT,
   ARUSER,
   ARVALID,
   ARREADY,

   // Read Channel
   RID,
   RLAST,
   RDATA,
   RRESP,
   RUSER,
   RVALID,
   RREADY,

   // Low power interface
   CACTIVE,
   CSYSREQ,
   CSYSACK
   );
parameter	ID_MAX = 3;

parameter	AWUSER_MAX = 31;
parameter	ARUSER_MAX = 31;
parameter	WUSER_MAX = 31;
parameter	RUSER_MAX = 31;
parameter	BUSER_MAX = 31;

parameter	DATA_MAX = 63;
parameter	STRB_MAX = 7;

   
// INDEX:        - Global Signals
// =====
input                ACLK;        // AXI Clock
input                ARESETn;     // AXI Reset


// INDEX:        - Write Address Channel
// =====
input     [ID_MAX:0] AWID;
input         [31:0] AWADDR;
input          [3:0] AWLEN;
input          [2:0] AWSIZE;
input          [1:0] AWBURST;
input          [3:0] AWCACHE;
input          [2:0] AWPROT;
input          [1:0] AWLOCK;
input [AWUSER_MAX:0] AWUSER;
input                AWVALID;
output                AWREADY;


// INDEX:        - Write Data Channel
// =====
input     [ID_MAX:0] WID;
input   [DATA_MAX:0] WDATA;
input   [STRB_MAX:0] WSTRB;
input  [WUSER_MAX:0] WUSER;
input                WLAST;
input                WVALID;
output                WREADY;


// INDEX:        - Write Response Channel
// =====
output     [ID_MAX:0] BID;
output          [1:0] BRESP;
output  [BUSER_MAX:0] BUSER;
output                BVALID;
input                BREADY;


// INDEX:        - Read Address Channel
// =====
input     [ID_MAX:0] ARID;
input         [31:0] ARADDR;
input          [3:0] ARLEN;
input          [2:0] ARSIZE;
input          [1:0] ARBURST;
input          [3:0] ARCACHE;
input          [2:0] ARPROT;
input          [1:0] ARLOCK;
input [ARUSER_MAX:0] ARUSER;
input                ARVALID;
output                ARREADY;


// INDEX:        - Read Data Channel
// =====
output     [ID_MAX:0] RID;
output   [DATA_MAX:0] RDATA;
output          [1:0] RRESP;
output  [RUSER_MAX:0] RUSER;
output                RLAST;
output                RVALID;
input                 RREADY;

// INDEX:        - Low Power Interface
// =====
input                CACTIVE;
input                CSYSREQ;
output                CSYSACK;




parameter  MEM_SIZE = 64-1;
  
reg	[63:0]	mem [0:MEM_SIZE];		/* internal ram, only process 64 bit read and write */
integer i;
initial 
begin
  	mem[0] = 64'h0706_0504_0302_0100;
	for (i=1; i<MEM_SIZE; i=i+1) 
	 mem[i] = mem[i-1]+64'h0808_0808_0808_0808;//2010.11.26
end

/*
always @(posedge ACLK)
 if(~ARESETn) 
 	begin
 	for (i=0; i<MEM_SIZE; i=i+1) 	 mem[i] = 64'hZ;//2010.11.26
 	end
*/
reg [3:0]  state;

parameter	S_WAIT_REQ 	= 4'b0001; 
parameter	S_PRE_DATA  = 4'b1100;
parameter	S_SEND_DATA = 4'b0010;
parameter	S_RECV_DATA = 4'b0100;
parameter	S_SEND_ACK  = 4'b1000;


reg  [31:0]	org_addr;
wire [28:0]	addr;	/* read or write addr */
reg  [3:0]	len;	/* read or write length */ 

/* for read */
assign addr = org_addr[31:3];
assign RDATA = mem[addr];
reg [63:0]  mask;
always @ (WSTRB)
begin
	if (WSTRB[0])   mask[7:0] = 8'hFF;
	else            mask[7:0] = 8'h00;
	
	if (WSTRB[1])   mask[15:8] = 8'hFF;
	else            mask[15:8] = 8'h00;
	
	if (WSTRB[2])   mask[23:16] = 8'hFF;
	else            mask[23:16] = 8'h00;
	
	if (WSTRB[3])   mask[31:24] = 8'hFF;
	else            mask[31:24] = 8'h00;
	
	if (WSTRB[4])   mask[39:32] = 8'hFF;
	else            mask[39:32] = 8'h00;
	
	if (WSTRB[5])   mask[47:40] = 8'hFF;
	else            mask[47:40] = 8'h00;
	
	if (WSTRB[6])   mask[55:48] = 8'hFF;
	else            mask[55:48] = 8'h00;
	
	if (WSTRB[7])   mask[63:56] = 8'hFF;
	else            mask[63:56] = 8'h00;
end








/* for write */
always @ (posedge ACLK)
begin
	if (WVALID && WREADY && state == S_RECV_DATA)
	begin	
		mem[addr] <= (mem[addr] & (~mask)) | (WDATA & mask);
	end
end 





assign BUSER = 0;
assign BRESP = 0;
assign BID = 4'b0001;

assign RRESP = 2'b00;
assign RID = 4'b0001;
assign RUSER = 0;

assign CSYSACK = 0;


reg ARREADY;
reg AWREADY;
reg RVALID;
reg WREADY;
reg BVALID;
reg RLAST;




always @ (posedge ACLK or negedge ARESETn)
if (!ARESETn)
begin
	state <= S_WAIT_REQ;

	ARREADY <= 1;
	AWREADY <= 1;
	RVALID <= 0;
	WREADY <= 0;
	BVALID <= 0;
	RLAST <= 0;
	len <= 0;
	org_addr <= 0;
end
else
begin
	case (state)
		S_WAIT_REQ:
		begin
			if (ARVALID)
			begin
				ARREADY <= 0;
				state <= S_PRE_DATA;
			end
			else if (AWVALID)
			begin
				state <= S_RECV_DATA;
				WREADY <= 1;
				AWREADY <= 0;
			end

			if (ARVALID)
			begin
				org_addr <= ((ARADDR[31:0] >> ARSIZE) << ARSIZE);
				len <= ARLEN;
			end
			else
			begin
				org_addr <= ((AWADDR[31:0] >> AWSIZE) << AWSIZE);
				len <= AWLEN;
			end


			if (ARVALID && ARLEN == 4'b0000)
			begin
				RLAST <= 1;
			end	
		end

		S_PRE_DATA:
		begin
			RVALID <= 1;
			state <= S_SEND_DATA;
		end

		
		S_SEND_DATA:
		begin
			if (RREADY)
			begin
				//addr <= addr + 1;
				org_addr <= (org_addr + (1<<ARSIZE));
				len <= len - 1;

			
				if (len == 1)
				begin
					RLAST <= 1;
				end

				if (len == 0 || RLAST == 1)
				begin
					RLAST <= 0;
					RVALID <= 0;
					ARREADY <= 1;
					state <= S_WAIT_REQ;
				end
			end
		end


		S_RECV_DATA:
		begin
			if (WVALID)
			begin
				//addr <= addr + 1;
				org_addr <= (org_addr + (1<<ARSIZE));
				len <= len - 1;
				

				if (WLAST)
				begin
					WREADY <= 0;
					BVALID <= 1;
					state <= S_SEND_ACK;
				end
			end


		end 


		S_SEND_ACK:
		begin
			if (BREADY)
			begin
				AWREADY <= 1;
				BVALID <= 0;
				state <= S_WAIT_REQ;
			end
		end

		default:
			state <= S_WAIT_REQ;
	endcase 
end

endmodule 
