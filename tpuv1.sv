module tpuv1
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16,
    parameter DATAW=64
  )
  (
    input clk, rst_n, r_w,
    input [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input [ADDRW-1:0] addr
  );

  reg [$clog2(DIM * 3 - 2)-1:0] counter;
  reg en_mat_mul;

  wire signed [BITS_C-1:0] c_out [DIM-1:0];

  wire [BITS_AB-1:0] bytes_in [7:0];
  wire [BITS_C-1:0] half_words_in [3:0];

  wire signed [BITS_AB-1:0] a_out [DIM-1:0];
  wire signed [BITS_AB-1:0] b_out [DIM-1:0];

  wire signed [BITS_C-1:0] c_in [DIM-1:0];

  wire c_row_half;
  wire [$clog2(DIM)-1:0] a_row_sel;
  wire [$clog2(DIM)-1:0] c_row_sel;

  wire wr_a, wr_b, wr_c;

  wire [ADDRW-1:0] addr_cmd_msk;

  systolic_array #(BITS_AB, BITS_C, DIM) sys_arr (
    .clk(clk),
    .rst_n(rst_n),
    .WrEn(wr_c),
    .en(en_mat_mul),
    .A(a_out),
    .B(b_out),
    .Cin(c_in),
    .Crow(c_row_sel),
    .Cout(c_out)
  );

  memA #(BITS_AB, DIM) mem_a (
    .clk(clk),
    .rst_n(rst_n),
    .en(en_mat_mul),
    .WrEn(wr_a),
    .Ain(bytes_in),
    .Arow(a_row_sel),
    .Aout(a_out)
  );

  memB #(BITS_AB, DIM) mem_b (
    .clk(clk),
    .rst_n(rst_n),
    .en(en_mat_mul),
    .WrEn(wr_b),
    .Bin(bytes_in),
    .Bout(b_out)
  );

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      en_mat_mul <= '0;
      counter <= '0;
    end else begin
      if (en_mat_mul) begin
        if (counter == (3 * DIM - 2)) begin
          en_mat_mul <= '0;
          counter <= '0;
        end else begin
          counter <= counter + 1;
        end
      end else if (addr == 16'h0400 && r_w == 1'b1) begin
        en_mat_mul <= 1'b1;
      end
    end
  end

  assign dataOut = c_row_half ? { c_out[7], c_out[6], c_out[5], c_out[4] } :
                                { c_out[3], c_out[2], c_out[1], c_out[0] };

  assign c_in = c_row_half ? { half_words_in[3], half_words_in[2], half_words_in[1], half_words_in[0], c_out[3], c_out[2], c_out[1], c_out[0] } :
                             { c_out[7], c_out[6], c_out[5], c_out[4], half_words_in[3], half_words_in[2], half_words_in[1], half_words_in[0] };

  assign c_row_half = addr[3];
  assign c_row_sel = addr[6:4];

  assign a_row_sel = addr[5:3];

  assign bytes_in = { dataIn[63:56], dataIn[55:48], dataIn[47:40], dataIn[39:32], dataIn[31:24], dataIn[23:16], dataIn[15:8], dataIn[7:0] };
  assign half_words_in = { dataIn[63:48], dataIn[46:32], dataIn[31:16], dataIn[15:0] };

  assign addr_cmd_msk = addr & 16'h0F00;

  assign wr_a = (addr_cmd_msk == 16'h0100) & r_w;
  assign wr_b = (addr_cmd_msk == 16'h0200) & r_w;
  assign wr_c = (addr_cmd_msk == 16'h0300) & r_w;

endmodule
