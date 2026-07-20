module adn_common_pipeline #(
    parameter int DATA_WIDTH = 32
) (
    input logic arst_ni,
    input logic clk_i,

    input  logic [DATA_WIDTH-1:0] data_in_i,
    input  logic                  data_in_valid_i,
    output logic                  data_in_ready_o,

    output logic [DATA_WIDTH-1:0] data_out_o,
    output logic                  data_out_valid_o,
    input  logic                  data_out_ready_i
);

  logic [DATA_WIDTH-1:0] data_reg;

  logic [DATA_WIDTH-1:0] is_full;
  logic [DATA_WIDTH-1:0] is_full_next;

  always_comb data_in_ready_o = is_full ? data_out_ready_i : '1;
  always_comb data_out_o = data_reg;
  always_comb data_out_valid_o = is_full;
  always_comb is_full_next = data_in_valid_i ? '1 : (data_out_ready_i ? '0 : is_full);

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      is_full <= '0;
    end else begin
      is_full <= is_full_next;
    end
  end


endmodule
