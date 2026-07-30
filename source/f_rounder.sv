@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

module f_rounder #(
    parameter int N = 8
    
)(
    input  logic [N-1:0] req_i,
    input logic [$clog2(N)-1:0] offset,
    output logic [N-1:0] req_o
);

always_comb begin


    int i= offset;
    int j= 0;
    
    req_o = '0;

    for (i= offset; i < N; i++) begin
        
        req_o[j] = req_i[i];
        j++;
    end

    i=0;

    for (i=0; i<offset; i++) begin
        
        req_o[j] = req_i[i];
        j++;
    end

end    



endmodule