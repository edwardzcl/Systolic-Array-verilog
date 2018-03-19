module distributor(
input wire [31:0] S_AXIS_TDATA,
//input data of the image,filter or bias
//
input wire S_AXIS_TVALID,
//input data is in-vaild
//
input wire S_AXIS_TLAST,
//indicates the last input data 

input wire [3:0] sign,
// from controller, to tell which buffer or which SRAM in filter buffer to store the data

input wire clk,

input wire reset_n,

output wire [15:0] value,

output wire [1:0] store_choice,
//choose which buffer to store the data

output wire  [1:0] filter_store_choice,
//choose which SRAM in the filter buffer to store the data 

output reg S_AXIS_TREADY,
//tells the Master it is ready to accept data in

output wire input_start,

output wire last
);
reg [1:0] record_store_choice;



assign value [0] = S_AXIS_TDATA [0];
assign value [1] = S_AXIS_TDATA [1];
assign value [2] = S_AXIS_TDATA [2];
assign value [3] = S_AXIS_TDATA [3];
assign value [4] = S_AXIS_TDATA [4];
assign value [5] = S_AXIS_TDATA [5];
assign value [6] = S_AXIS_TDATA [6];
assign value [7] = S_AXIS_TDATA [7];

assign value [8] = S_AXIS_TDATA [8];
assign value [9] = S_AXIS_TDATA [9];
assign value [10] = S_AXIS_TDATA [10];
assign value [11] = S_AXIS_TDATA [11];
assign value [12] = S_AXIS_TDATA [12];
assign value [13] = S_AXIS_TDATA [13];
assign value [14] = S_AXIS_TDATA [14];
assign value [15] = S_AXIS_TDATA [15];

assign store_choice [1] = sign [1];
assign store_choice [0] = sign [0];
assign filter_store_choice [1] = sign[3];
assign filter_store_choice [0] = sign[2];
assign input_start = S_AXIS_TVALID & S_AXIS_TREADY;
assign last = S_AXIS_TLAST;

always@(posedge clk or negedge reset_n)
begin
	if(!reset_n) 
		record_store_choice <= 2'b00;
	else
		record_store_choice <= store_choice;
end

always@(posedge clk or negedge reset_n)
begin
	if(!reset_n)
		S_AXIS_TREADY <= 1'b0;
	else
		if(S_AXIS_TLAST == 1'b1)
			S_AXIS_TREADY <= 1'b0;
		else
			if( ((!record_store_choice [0]) && (store_choice [0]))||((!record_store_choice [1]) && (store_choice [1])))
				S_AXIS_TREADY <= 1'b1;
			else
				S_AXIS_TREADY <= S_AXIS_TREADY;

end


endmodule
