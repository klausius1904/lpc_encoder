`timescale 1ns/1ns
module decoder_fifo_tb;

	reg ACLK;
	reg ARESET_N;
	reg [79:0] TDATA;
	reg TVALID;
	wire TREADY;
	reg TUSER;
	reg TLAST;
	
	reg RD_EN;
	wire [15:0] DATA_OUT;
	wire LAST_OUT;
	wire EMPTY;

	integer data_file;
	integer write_file;
	integer scan_file;
	reg [10:0] cnt_reg;
	reg isStart;
	`define NULL 0

	decoder_fifo #(.DEPTH(128), .DATA_WIDTH(16), .LAST_WIDTH(1)) uut(
									.ACLK(ACLK),
									.ARESET_N(ARESET_N),
									.TDATA(TDATA),
									.TVALID(TVALID),
									.TREADY(TREADY),
									.TUSER(TUSER),
									.TLAST(TLAST),
									.RD_EN(RD_EN),
									.DATA_OUT(DATA_OUT),
									.LAST_OUT(LAST_OUT),
									.EMPTY(EMPTY)
										);
	always #5 ACLK = ~ACLK;
	initial begin
		ACLK=0;
		ARESET_N=0;	
		TVALID=0;
		TUSER=0;
		TLAST=0;
		cnt_reg=0;
		isStart=1;
		RD_EN=1;
		#20 ARESET_N=1;
	end
	
	initial begin
		data_file = $fopen("data_out.txt", "r");
		write_file = $fopen("data_fifo.txt", "w");
		if(data_file == `NULL)begin
			$display("Error at file open");
			$finish;
		end
		if(write_file == `NULL)begin
			$display("Error at file open");
			$finish;
		end
	end


	always@(posedge ACLK or negedge ARESET_N)begin
		if(ARESET_N && TREADY)begin
			scan_file = $fscanf(data_file,"%b\n", TDATA);
			if(~$feof(data_file))begin
				TVALID=1;
				cnt_reg = cnt_reg+1;
				if(cnt_reg == 1920)begin	
					cnt_reg = 0;
					TLAST = 1;
				end else begin
					TLAST= 0;
				end
				if(isStart)begin
					isStart=0;	
					TUSER = 1;
				end else begin
					TUSER=0;
				end 
			end
			else begin
				TVALID=0;
			end
		end
		if(~EMPTY)begin
			$fwrite(write_file, "%b\n", DATA_OUT);
		end
	end
endmodule