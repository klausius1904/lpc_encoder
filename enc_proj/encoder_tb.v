`timescale 1ns/1ns

module encoder_tb;

	reg ACLK;
	reg ARESET_N;
	reg [15:0] IN_SOURCE;
	reg IN_VALID;
	reg T_LAST;
	wire READY;
	
	wire OUT_VALID;
	wire OUT_LAST;
	wire [79:0] OUT_CODED;
	reg T_READY;

	integer               data_file    ; // file handler
	integer               scan_file    ; // file handler
	reg[15:0] captured_data;
	`define NULL 0
	reg[2:0]cnt_reg;    

lpc_encoder uut(
		.ACLK(ACLK),
		.ARESET_N(ARESET_N),
		.IN_SOURCE(IN_SOURCE),
		.IN_VALID(IN_VALID),
		.T_LAST(T_LAST),
		.READY(READY),
		.OUT_VALID(OUT_VALID),
		.OUT_LAST(OUT_LAST),
		.OUT_CODED(OUT_CODED),
		.T_READY(T_READY)
		);

	always begin #5 ACLK=~ACLK; end
	initial begin
		ACLK=0;
		ARESET_N=0;
		
		#20 ARESET_N=1;
		
	end
	initial begin
		IN_VALID=0;
		T_LAST=0;
		T_READY=1;
		cnt_reg=0;
			
		data_file = $fopen("data.txt", "r");
		if (data_file == `NULL) begin
    			$display("data_file handle was NULL");
    			$finish;
  		end
		#20;
	end

	always@(posedge ACLK or negedge ARESET_N)begin
		if(READY && ARESET_N)begin
			scan_file = $fscanf(data_file, "%d\n", IN_SOURCE); 
			if (!$feof(data_file)) begin
				IN_VALID=1;
				cnt_reg= cnt_reg+1;
				if(cnt_reg==4)begin
					T_LAST=1;
					
				end else T_LAST=0;
				if(cnt_reg==5)begin
					cnt_reg=1;
				end
			end else begin
				IN_VALID=0;
			end
		end
	end

initial begin 
 $monitor("%b/n", OUT_CODED);
end

endmodule
