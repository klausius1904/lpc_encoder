module synchronous_fifo #(parameter DEPTH = 8, DATA_WIDTH = 8) (
    input wire ACLK,
    input wire ARESET_N,
    input wire WR_EN,
    input wire RD_EN,
    input wire [DATA_WIDTH-1:0] DATA_IN,
    output reg [DATA_WIDTH-1:0] DATA_OUT,
    output wire FULL,
    output wire EMPTY
);

    reg [DATA_WIDTH-1:0] FIFO [DEPTH-1:0];  // FIFO buffer storage
    reg [$clog2(DEPTH):0] WR_PTR;           // Write pointer
    reg [$clog2(DEPTH):0] RD_PTR;           // Read pointer
    reg [$clog2(DEPTH+1):0] COUNT;          // Number of elements in the FIFO

    // Set default values on reset
    always @(posedge ACLK or negedge ARESET_N) begin
        if (!ARESET_N) begin
            WR_PTR <= 0;
            RD_PTR <= 0;
            COUNT <= 0;
            DATA_OUT <= 0;
        end else begin
            // Write data to FIFO
            if (WR_EN && !FULL) begin
                FIFO[WR_PTR] <= DATA_IN;
                WR_PTR <= (WR_PTR + 1) % DEPTH;
                COUNT <= COUNT + 1;
            end

            // Read data from FIFO
            if (RD_EN && !EMPTY) begin
                DATA_OUT <= FIFO[RD_PTR];
                RD_PTR <= (RD_PTR + 1) % DEPTH;
                COUNT <= COUNT - 1;
            end
        end
    end

    // Full and Empty flag logic
  assign FULL = ((WR_PTR+1'b1) == RD_PTR);
  assign EMPTY = (WR_PTR == RD_PTR);

endmodule


