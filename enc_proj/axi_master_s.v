module master_axi_s_interface(

	input wire ACLK,
	input wire ARESET_N,
	output wire TVALID,
	input wire TREADY,
	output wire[80:0] TDATA,
	input wire[3:0] LAST,
	input wire TUSER,
	
	output wire READY,
	input wire [80:0] SAMPLE,
	input wire VALID_SAMPLE,
	output wire[3:0] TLAST
	
);
	reg[80:0] data_in_reg, data_in_nxt;
	reg[80:0] data_reg, data_nxt;
	reg[3:0] last_reg, last_nxt;
	reg valid_reg, valid_nxt;
	reg ready_reg, ready_nxt;

	always@(posedge ACLK or negedge ARESET_N)begin
		if(~ARESET_N)begin
			data_reg<=0;
			last_reg<=0;
			valid_reg<=0;
			ready_reg<=1;	
		end
		else begin
			data_reg<=data_nxt;
			last_reg<=last_nxt;
			valid_reg<=valid_nxt;
			ready_reg<=ready_nxt;
		end
	end
	always@(*)begin
		data_nxt=data_reg;
		last_nxt=last_reg;
		valid_nxt=valid_reg;
		ready_nxt=ready_reg;
		if(TUSER)begin
			data_nxt=0;	
			last_nxt=0;
			valid_nxt=0;
			ready_nxt=1;
		end
		else if(READY && VALID_SAMPLE)begin
			data_nxt=SAMPLE;
			last_nxt= LAST;
			valid_nxt=1;
			ready_nxt=0;
		end
		if(TREADY && TVALID)begin
			valid_nxt=0;
			ready_nxt=1;
			data_nxt=0;
		end

	end
assign TVALID=valid_reg;
assign TDATA=data_reg;
assign READY=ready_reg;
assign TLAST= last_reg;
 
endmodule

