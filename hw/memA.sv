module memA
  #(
    parameter BITS_AB=8,
    parameter DIM=8
  )
  (
    input clk, rst_n, en, WrEn,
    input signed [BITS_AB-1:0] Ain [DIM-1:0],
    input [$clog2(DIM)-1:0] Arow,
    output signed [BITS_AB-1:0] Aout [DIM-1:0]
  );
  
  generate
    genvar row, i, j;
    for (row = 0; row < DIM; row = row + 1) begin : iter
      if (row == 0) begin
        transpose_fifo #(.DEPTH(DIM), .BITS(BITS_AB)) queue (
          .clk(clk),
          .rst_n(rst_n),
          .en(en && ~WrEn),
          .WrEn((Arow == row) && WrEn),
          .d(Ain),
          .q(Aout[row])
        );
      end else begin
        wire [BITS_AB-1:0] queue_in [DIM + row - 1:0];
        transpose_fifo #(.DEPTH(DIM + row), .BITS(BITS_AB)) queue (
          .clk(clk),
          .rst_n(rst_n),
          .en(en && ~WrEn),
          .WrEn((Arow == row) && WrEn),
          .d(queue_in),
          .q(Aout[row])
        );
        for (i = 0; i < row; i = i + 1) begin : zero_iter
          assign queue_in[i] = 8'h00;
        end
        for (j = 0; j < DIM; j = j + 1) begin : ain_iter
          assign queue_in[row + j] = Ain[j];
        end
      end
    end
  endgenerate
endmodule
