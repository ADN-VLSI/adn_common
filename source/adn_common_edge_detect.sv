module adn_common_edge_detect #(
    parameter int EDGE_TYPE = 0
)(
    input logic clk,
    input logic rst_n,
    input logic signal_in,

    output logic edge_pulse
);

    logic signal_prev;

    always_ff @(posedge clk) begin

        if (~rst_n)
            signal_prev <= 1'b0;
        else
            signal_prev <= signal_in;
    end

    always_comb begin

        case (EDGE_TYPE)

            0: edge_pulse = (~signal_prev) & signal_in;
            1: edge_pulse = (signal_prev) & (~signal_in);
            2: edge_pulse = signal_prev ^ signal_in;

            default: edge_pulse = 1'b0;

        endcase
        
    end

endmodule