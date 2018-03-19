  module AXIS_ip #
  (
       // AXI4Stream sink: Data Width
	   parameter integer AXIS_TDATA_WIDTH	= 32     //4 byte
   )
    (
       input  wire        AXIS_ACLK,
       input  wire        AXIS_ARESETN,
	   
       output wire        S_AXIS_TREADY,
       input  wire [AXIS_TDATA_WIDTH-1:0] S_AXIS_TDATA,
       input  wire        S_AXIS_TLAST,
       input  wire        S_AXIS_TVALID,
	   
       output wire        M_AXIS_TVALID,
       output wire [AXIS_TDATA_WIDTH-1:0] M_AXIS_TDATA,
       output wire        M_AXIS_TLAST,
       input  wire        M_AXIS_TREADY,
       output wire [(AXIS_TDATA_WIDTH/8)-1:0]  M_AXIS_TKEEP
  
     );
 
   // Total number of input data
   localparam NUMBER_OF_INPUT_WORDS  = 8;
   // Total number of output data
   localparam NUMBER_OF_OUTPUT_WORDS = 4;
   // Define the states of state machine
   localparam IDLE  = 3'b001;
   localparam WRITE_TO_FIFO = 3'b010;
   localparam READ_FROM_FIFO  = 3'b100;
   reg [3:0] state;
   reg flag;
   

   reg [AXIS_TDATA_WIDTH-1:0] mem [NUMBER_OF_INPUT_WORDS-1:0];
   reg [NUMBER_OF_INPUT_WORDS-1:0] temp;
   wire tx_en;
   wire rx_en;
   reg rx_en_delay;
   wire rx_en_final;
   reg rx_done;
   reg tx_done;  
   
   //检测需要的位宽
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction                  
   
   localparam bit_num_wr  = clogb2(NUMBER_OF_OUTPUT_WORDS);
   localparam bit_num_rd  = clogb2(NUMBER_OF_INPUT_WORDS);
   reg [bit_num_rd - 1:0] write_pointer;
   reg [bit_num_wr - 1:0] read_pointer;
   reg [bit_num_wr - 1:0] store_pointer;
  
   assign M_AXIS_TKEEP	= {(AXIS_TDATA_WIDTH/8){1'b1}};   
   assign M_AXIS_TLAST = (read_pointer == NUMBER_OF_OUTPUT_WORDS-1);
   assign M_AXIS_TVALID= ((state == READ_FROM_FIFO)&&(read_pointer < NUMBER_OF_OUTPUT_WORDS));
   assign S_AXIS_TREADY = ((state == WRITE_TO_FIFO) &&(write_pointer < NUMBER_OF_INPUT_WORDS)); 
   assign tx_en = M_AXIS_TVALID && M_AXIS_TREADY;   
   assign rx_en = S_AXIS_TVALID && S_AXIS_TREADY;
   assign rx_en_final = rx_en_delay || rx_en;
   
  /************************Control state machine implementation************************/
   always @(posedge AXIS_ACLK) 
   begin  
      if (!AXIS_ARESETN)              
        begin           
           state <= IDLE;          
        end
      else
        case (state)
        IDLE: 
          begin
		    // 检测到S_AXIS_TVALID == 1，进入WRITE_TO_FIFO
            if (S_AXIS_TVALID == 1)
               begin
               state <= WRITE_TO_FIFO;
               end
			else
	            begin
	              state <= IDLE;
	            end
           end
          WRITE_TO_FIFO: 
            begin
            if (rx_done==1) 
                begin             
                state  <= READ_FROM_FIFO;             
                end
            else   
                begin			
			     state <= WRITE_TO_FIFO;  
                end				 
            end
          READ_FROM_FIFO: 
          begin         
		   if (tx_done)                                                      
	          begin                                                           
	            state <= IDLE;                                       
	          end                                                             
	        else                                                              
	          begin                                                           
	            state <= READ_FROM_FIFO;                                
	          end                                  
          end
        endcase
   end
   
   /*******************Control read_pointer and tx_done implementation***********/
   //注意修改，这样才能让tx_en拉低时，tx_done 拉高

  always@(posedge AXIS_ACLK)                                               
	begin                                                                            
	  if(!AXIS_ARESETN)                                                            
	    begin                                                                        
	      read_pointer <= 0;                                                         
	      tx_done <= 1'b0;                                                           
	    end                                                                          
	  else                                                                           
	    if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1)                                
	      begin                                                                      
	        if (tx_en)                                                               	                                            
	          begin                                                        
	            read_pointer <= read_pointer + 1;                                   
	            tx_done <= 1'b0;                                                     
	          end                                                                    
	                                                                             
	         if (read_pointer == NUMBER_OF_OUTPUT_WORDS-1)                             
	          begin                                                                      	                                                               
	          tx_done <= 1'b1;                                                         
	          end   
           end 		  
	end                                        
     /*******************Control write_pointer and rx_done implementation***********/
  always@(posedge AXIS_ACLK)
	begin
	  if(!AXIS_ARESETN)
	    begin
	      write_pointer <= 0;
	      rx_done <= 1'b0;
	    end  
	  else
	    if (write_pointer <= NUMBER_OF_INPUT_WORDS-1)
	      begin
	        if (rx_en)
	          begin	                                                                             
	            write_pointer <= write_pointer + 1;
	            rx_done <= 1'b0;
	          end
	           if ((write_pointer == NUMBER_OF_INPUT_WORDS-1)|| S_AXIS_TLAST)
	            begin	              
	              rx_done <= 1'b1;
	            end
	      end  
	end

  //当M_AXIS_TVALID拉高时，应该立即发送数据
  //当tx_en拉高，读出fifo
   assign M_AXIS_TDATA= tx_en?mem[read_pointer]:32'd0;   
  //最好初始化
  //当rx_en拉高，写入fifo
  always@(posedge AXIS_ACLK)
  begin
    if(!AXIS_ARESETN)
	    begin
	      store_pointer <= -1;
	      temp <= 0;
	    end
    else
      if(rx_en_final == 1)
        if(flag == 1)
          begin
            temp <= temp + S_AXIS_TDATA;
          end
        else
          begin
            temp <= S_AXIS_TDATA;
            mem[store_pointer] <= temp;
            store_pointer <= store_pointer + 1;
          end
  end
    
  always@(posedge AXIS_ACLK)
  begin
	  if(state == IDLE)
	      flag <= 0;
	  else
	      if(rx_en)
	      flag <= ~flag;  
	end
	
	always@(posedge AXIS_ACLK)
  begin
    rx_en_delay <= rx_en;
  end
  

endmodule