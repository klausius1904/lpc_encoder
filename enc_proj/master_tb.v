` timescale 1ns/1ns

module master_axi_s_interface_tb;

reg ACLK;
reg ARESET_N;
wire TVALID;
reg TREADY;
wire[80:0] TDATA;
reg TLAST;

reg[80:0] SAMPLE;
reg VALID_SAMPLE;
wire READY;


integer               data_file    ; // file handler
integer               scan_file    ; // file handler
reg[15:0] captured_data;
`define NULL 0    


master_axi_s_interface uut (
				.ACLK(ACLK),
				.ARESET_N(ARESET_N),
				.TVALID(TVALID),
				.TREADY(TREADY),
				.TDATA(TDATA),
				.TLAST(TLAST),
				.SAMPLE(SAMPLE),
				.VALID_SAMPLE(VALID_SAMPLE),
				.READY(READY)
				);

always begin
    #5 ACLK = ~ACLK;
end

initial begin
    ACLK = 0;
    ARESET_N = 0;
    #20  ARESET_N = 1;
end

initial begin
    // Initialize inputs
   	SAMPLE=0;
    	TLAST = 0;
	TREADY=1;
	
	data_file = $fopen("data.txt", "r");
		if (data_file == `NULL) begin
    			$display("data_file handle was NULL");
    			$finish;
  		end
	#10;
end

always@(posedge ACLK or negedge ARESET_N)begin
	if(READY && ARESET_N)begin
		scan_file = $fscanf(data_file, "%d\n", SAMPLE); 
		if (!$feof(data_file)) begin
			VALID_SAMPLE=1;
		end else begin
			VALID_SAMPLE=0;
		end
	end
end


endmodule