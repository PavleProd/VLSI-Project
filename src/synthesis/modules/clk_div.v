module clk_div #(
    parameter DIVISOR = 50_000_000
) (
    input clk,
    input rst_n,
    output out
);

    reg out_reg, out_next;
    integer count_reg, count_next;

    assign out = out_reg;

    // kombinaciona logika
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= 1'b0;
            count_reg <= 0;
        end
        else begin
            out_reg <= out_next;
            count_reg <= count_next;
        end
    end

    // sekvencijalna logika
    always @(*) begin
        if(count_reg == DIVISOR) begin
            count_next = 1'b0;
            out_next = 1'b1;
        end
        else begin
            count_next = count_reg + 1'b1;
            out_next = 1'b0;
        end
    end
    
endmodule