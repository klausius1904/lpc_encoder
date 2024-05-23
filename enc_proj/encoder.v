module lpc_encoder
(
	input wire ACLK,
	input wire ARESET_N,
	input wire[15:0] IN_SOURCE,
	input wire IN_VALID,
	input wire T_LAST,
	input wire SAMPLE_LAST,
	output wire READY,
	input wire TUSER
	
	output wire OUT_VALID,
	output wire [3:0]OUT_LAST,
	output wire [79:0] OUT_CODED,
	input wire T_READY
	
	

);
	
	reg[7:0] src_reg[7:0], src_nxt[7:0];
	reg[7:0] pv_reg, pv_nxt;
	reg[7:0] ph_reg, ph_nxt;
	reg[2:0] cnt_reg, cnt_nxt;
	reg ready_reg, ready_nxt;
	reg out_last_reg, out_last_nxt;
	reg out_valid_reg, out_valid_nxt;
	reg[79:0] encoded_reg, encoded_nxt;
	reg[3:0]sample_last_reg, sample_last_nxt;
	reg [3:0] idx;
	
	
	always@(posedge ACLK or negedge ARESET_N)begin
		if(~ARESET_N)begin
			for(idx=0; idx<8; idx=idx+1)begin
				src_reg[idx]<=0;
			end
			cnt_reg<=0;
			ready_reg<=1;
			out_last_reg<=0;
			out_valid_reg<=0;
			encoded_reg<=0;
			pv_reg<=0;	
			ph_reg<=0;
			sample_last_reg<=0;
			
		end
		else begin
			for(idx=0; idx<8; idx=idx+1)begin
				src_reg[idx]<=src_nxt[idx];
			end
			cnt_reg<=cnt_nxt;
			ready_reg<=ready_nxt;
			out_last_reg<=out_last_nxt;
			out_valid_reg<=out_valid_nxt;
			encoded_reg<=encoded_nxt;
			pv_reg<=pv_nxt;
			ph_reg<=ph_nxt;
			sample_last_reg<=sample_last_nxt;
		end
	end
	always@(*)begin
		cnt_nxt=cnt_reg;
		ready_nxt=ready_reg;
		out_last_nxt=out_last_reg;
		out_valid_nxt=out_valid_reg;
		encoded_nxt=encoded_reg;
		pv_nxt=pv_reg;
		ph_nxt=ph_reg;
		sample_last_nxt=sample_last_reg;

		for(idx=0; idx<8; idx=idx+1)begin
				src_nxt[idx]=src_reg[idx];
		end
		if(TUSER)begin
			cnt_nxt=0;
			out_last_nxt=0;
			encoded_nxt=0;
			pv_nxt=0;
			ph_nxt=0;
			ready_nxt=1;
			out_valid_nxt=0;
			sample_last_nxt=0;
			for(idx=0; idx<8; idx=idx+1)begin
				src_reg[idx]<=0;
			end
		end else if(IN_VALID&READY)begin
			src_nxt[2*cnt_reg]=IN_SOURCE[15:8];
			src_nxt[2*cnt_reg+1]=IN_SOURCE[7:0];
			pv_nxt[2*cnt_reg]=^IN_SOURCE[15:8];
			pv_nxt[2*cnt_reg+1]=^IN_SOURCE[7:0];	
			for(idx=0; idx<8; idx=idx+1)begin
				ph_nxt[idx]={src_reg[0][idx]^src_reg[1][idx]^src_reg[2][idx]^src_reg[3][idx]^src_reg[4][idx]^src_reg[5][idx]^src_reg[6][idx]^src_reg[7][idx]};
			end
			sample_last_nxt[cnt_reg]=SAMPLE_LAST;
			cnt_nxt=cnt_reg+1;
			if(T_LAST)begin
				encoded_nxt={src_reg[0],src_reg[1],src_reg[2],src_reg[3],src_reg[4],src_reg[5],src_reg[6],src_reg[7],pv_reg,ph_reg};
				out_valid_nxt=1;
				ready_nxt=0;
			end
		end
		if(OUT_VALID&T_READY)begin
			cnt_nxt=0;	
			ready_nxt=1;
			for(idx=0; idx<8; idx=idx+1)begin
				src_nxt[idx]=0;
			end
			pv_nxt=0;
			ph_nxt=0;
			encoded_nxt=0;
			out_valid_nxt=0;
		end
		
	end
assign READY=ready_reg;
assign OUT_VALID=out_valid_reg;
assign OUT_CODED=encoded_reg;
assign OUT_LAST=sample_last_reg;
endmodule
