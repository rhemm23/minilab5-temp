module memB
  #(
    parameter BITS_AB=8,
    parameter DIM=8
  )
  (
    input clk, rst_n, en, WrEn,
    input signed [BITS_AB-1:0] Bin [DIM-1:0],
    output signed [BITS_AB-1:0] Bout [DIM-1:0]
  );
  
  generate
    genvar col;
    for (col = 0; col < DIM; col = col + 1) begin : iter
      fifo #(.DEPTH(DIM + col), .BITS(BITS_AB)) queue (
        .clk(clk),
        .rst_n(rst_n),
        .en(en | WrEn),
        .d(WrEn ? Bin[col] : '0),
        .q(Bout[col])
      );
    end
  endgenerate
endmodule