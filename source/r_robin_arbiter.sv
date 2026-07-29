module round_robin_arbiter #(
    parameter int N = 4
)(
    input  logic                     clk,
    input  logic                     arst_n,
    input  logic [N-1:0]             req,

    output logic [N-1:0]             grant,
    output logic                     grant_valid,
    output logic [$clog2(N)-1:0]     grant_idx
);

    logic [$clog2(N)-1:0]             last_grant_idx;
    logic [$clog2(N)-1:0]             next_grant_idx;
    logic [N-1:0]                     grant_mask;

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            last_grant_idx <= '0;
        end else if (grant_valid) begin
            last_grant_idx <= grant_idx;
        end
    end

    assign grant_mask = (1 << last_grant_idx) - 1;
    assign next_grant_idx = (req & ~grant_mask) ? $clog2(req & ~grant_mask) : $clog2(req);

    assign grant_valid = |req;
    assign grant_idx = next_grant_idx;
    assign grant = (grant_valid) ? (1 << grant_idx) : '0;


    initial begin
        assert(N > 0) else $fatal("N must be greater than 0");
        
        foreach (grant[i]) begin
            assert(grant[i] == 1'b0) else $fatal("Grant should be initialized to 0");
        end
        foreach (grant_mask[i]) begin
            assert(grant_mask[i] == 1'b0) else $fatal("Grant mask should be initialized to 0");
        end
        
    
    end

endmodule