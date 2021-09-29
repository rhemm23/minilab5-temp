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
    genvar row;
    for (row = 0; row < DIM; row = row + 1) begin : iter
      if (row == 0) begin
        transpose_fifo #(.DEPTH(DIM + row), .BITS(BITS_AB)) queue (
          .clk(clk),
          .rst_n(rst_n),
          .en(en && ~WrEn),
          .WrEn((Arow == row) && WrEn),
          .d(Ain),
          .q(Aout[row])
        );
      end else begin 
        transpose_fifo #(.DEPTH(DIM + row), .BITS(BITS_AB)) queue (
          .clk(clk),
          .rst_n(rst_n),
          .en(en && ~WrEn),
          .WrEn((Arow == row) && WrEn),
          .d({{row{8'h00}}, Ain}),
          .q(Aout[row])
        );
      end
    end
  endgenerate
endmodule