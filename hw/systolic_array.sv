module systolic_array
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8
  )
  (
    input clk, rst_n, WrEn, en,
    input signed [BITS_AB-1:0] A [DIM-1:0],
    input signed [BITS_AB-1:0] B [DIM-1:0],
    input signed [BITS_C-1:0] Cin [DIM-1:0],
    input [$clog2(DIM)-1:0] Crow,
    output signed [BITS_C-1:0] Cout [DIM-1:0]
  );

  wire signed [BITS_AB-1:0] aout_grid [DIM-1:0][DIM-1:0];
  wire signed [BITS_AB-1:0] bout_grid [DIM-1:0][DIM-1:0];
  wire signed [BITS_AB-1:0] ain_grid [DIM-1:0][DIM-1:0];
  wire signed [BITS_AB-1:0] bin_grid [DIM-1:0][DIM-1:0];

  wire signed [BITS_C-1:0] cout_grid [DIM-1:0][DIM-1:0];
  wire signed [BITS_C-1:0] cin_grid [DIM-1:0][DIM-1:0];

  wire wren_grid [DIM-1:0][DIM-1:0];

  tpumac #(BITS_AB, BITS_C) grid [DIM-1:0][DIM-1:0] (
    .clk(clk),
    .rst_n(rst_n),
    .WrEn(wren_grid),
    .en(en),
    .Ain(ain_grid),
    .Bin(bin_grid),
    .Cin(cin_grid),
    .Aout(aout_grid),
    .Bout(bout_grid),
    .Cout(cout_grid)
  );

  assign Cout = cout_grid[Crow];

  generate
    genvar i, j;
    genvar row, col;

    for (i = 0; i < DIM; i = i + 1) begin : init
      assign ain_grid[i][0] = A[i];
      assign bin_grid[0][i] = B[i];
    end
    for (i = 1; i < DIM; i = i + 1) begin : conn_i
      for (j = 0; j < DIM; j = j + 1) begin : conn_j
        assign ain_grid[j][i] = aout_grid[j][i - 1];
        assign bin_grid[i][j] = bout_grid[i - 1][j];
      end
    end
    for (row = 0; row < DIM; row = row + 1) begin : wren_row
      for (col = 0; col < DIM; col = col + 1) begin : wren_col
        assign cin_grid[row][col] = Cin[col];
        assign wren_grid[row][col] = (Crow == row) ? WrEn : 1'b0;
      end
    end
  endgenerate
endmodule
