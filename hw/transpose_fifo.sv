// transpose_fifo.sv
// Implements delay buffer (fifo)
// Allows for transposing entire array in one clk cycle
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in 0

module transpose_fifo
  #(
    parameter DEPTH=8,
    parameter BITS=64
  )
  (
    input clk, rst_n, en, WrEn,
    input [BITS-1:0] d [DEPTH-1:0],
    output [BITS-1:0] q
  );

  reg [BITS-1:0] data [DEPTH-1:0];

  integer i;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        data[i] <= '0;
      end
    end else if (WrEn) begin
      data <= d;
    end else if (en) begin
      for (i = 0; i < DEPTH-1; i = i + 1) begin
        data[i] <= data[i + 1];
      end
      data[DEPTH-1] <= '0;
    end
  end

  assign q = data[0];

endmodule