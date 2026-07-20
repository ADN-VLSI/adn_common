module hello;

  `include "vip/adn_common_tb_headers.sv"

  initial begin
    $display("Hello, SystemVerilog!");
    $finish;
  end

endmodule