module slave_axi_s_interface(
	input wire ACLK,
	input wire ARESET_N,
	input wire TVALID,
	output wire TREADY,
	input wire[15:0] TDATA,
	input wire TLAST,
	input wire TUSER,
	
	input wire READY,
	output wire VALID,
	output wire LAST,
	output wire SAMPLE_LAST,	
	output wire[15:0] SAMPLE
	output wire USER_OUT;
);

	reg [15:0] data_reg, data_nxt;
	reg [2:0] cnt_reg, cnt_nxt;
	reg valid_reg, valid_nxt;
	reg ready_reg, ready_nxt;
	reg last_reg, last_nxt;
	reg sample_last_reg, sample_last_nxt;
	reg user_out_reg, user_out_nxt;

	always@(posedge ACLK or negedge ARESET_N)begin
		if(~ARESET_N)begin
			data_reg<=0;
			cnt_reg<=0;
			valid_reg<=0;
			ready_reg<=1;
			last_reg<=0;
			sample_last_reg<=0;
			user_out_reg<=0;
		end
		else begin
			data_reg<=data_nxt;
			cnt_reg<=cnt_nxt;
			valid_reg<=valid_nxt;
			ready_reg<=ready_nxt;
			last_reg<=last_nxt;
			sample_last_reg<=sample_last_nxt;
			user_out_reg<=user_out_nxt;
			
		end
	end
	
	always@(*)begin
		data_nxt=data_reg;
		cnt_nxt=cnt_reg;
		valid_nxt=valid_reg;
		ready_nxt=ready_reg;
		last_nxt=last_reg;
		sample_last_nxt=sample_last_reg;
		user_out_nxt=user_out_reg;

		if(TREADY & TVALID)begin
			data_nxt=TDATA;
			cnt_nxt=cnt_reg+1;
			valid_nxt = 1;
			sample_last_nxt=TLAST;

			if (TUSER)begin
				cnt_nxt=0;
				ready_nxt=1;
				valid_nxt=0;
				last_nxt=0;
				sample_last_nxt=0;
				data_nxt=0;
			end
			user_out_nxt=TUSER;
		end
		if(cnt_reg==3)begin
			ready_nxt=0;
			cnt_nxt=cnt_reg+1;
			last_nxt=1;
		end
		if(cnt_reg==4)begin
		 valid_nxt = 0;
		 last_nxt=0;
		end
		if(READY & ~TREADY) begin
			ready_nxt=1;
			cnt_nxt=0;
		end

	
	end
assign TREADY = ready_reg;
assign LAST = last_reg;
assign VALID = valid_reg;
assign SAMPLE = data_reg;
assign SAMPLE_LAST=sample_last_reg;
assign USER_OUT =user_out_reg;
endmodule
