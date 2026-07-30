module b_rounder #(
    parameter int N = 8
    
)(
    input  logic [N-1:0] req_i,
    input logic [$clog2(N)-1:0] offset,
    output logic [N-1:0] grant_o
);

always_comb begin


    int i= offset;
    int j= 0;
   
    grant_o = '0;

    for (i= offset; i < N; i++) begin
        
        grant_o[i] = req_i[j];
        j++;
    end

    i=0;

    for (i=0; i<offset; i++) begin
        
        grant_o[i] = req_i[j];
        j++;
    end

end    



endmodule