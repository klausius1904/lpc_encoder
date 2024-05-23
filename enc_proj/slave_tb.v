`timescale 1ns / 1ns

module slave_axi_s_interface_tb;

reg ACLK;
reg ARESET_N;
reg TVALID;
wire TREADY;
reg [15:0] TDATA;
reg TLAST;
reg READY;
reg TUSER;
wire VALID;
wire LAST;
wire [15:0] SAMPLE;

integer               data_file; 
integer               scan_file;
`define NULL 0
`define FRAME_SIZE 1920

integer assert_tlast;
// Instantiate the module
slave_axi_s_interface uut (
    .ACLK(ACLK),
    .ARESET_N(ARESET_N),
    .TVALID(TVALID),
    .TREADY(TREADY),
    .TDATA(TDATA),
    .TLAST(TLAST),
    .TUSER(TUSER),
    .READY(READY),
    .VALID(VALID),
    .LAST(LAST),
    .SAMPLE(SAMPLE)
);

// Clock generation
always begin
    #5 ACLK = ~ACLK;
end

// Reset generation
initial begin
    ACLK = 0;
    ARESET_N = 0;
    #10  ARESET_N = 1;
end

// Testbench stimulus
initial begin
    // Initialize inputs
    	TVALID = 0;
   	TDATA = 0;
    	TLAST = 0;
	assert_tlast =0;
	READY=1;
	
	data_file = $fopen("data.txt", "r");
		if (data_file == `NULL) begin
    			$display("data_file handle was NULL");
    			$finish;
  		end
	#20;
end
initial begin
	#50 TUSER=1;
	#10 TUSER=0;
end
always@(posedge ACLK or negedge ARESET_N)begin
	if(TREADY && ARESET_N)begin
		scan_file = $fscanf(data_file, "%d\n", TDATA); 
		if (!$feof(data_file)) begin
			TVALID=1;
			assert_tlast=assert_tlast+1;
			if(assert_tlast==`FRAME_SIZE)begin
				TLAST=1;
				assert_tlast=0;
			end
			else TLAST=0;
		end else begin
			TVALID=0;
		end
	end
end

endmodule

