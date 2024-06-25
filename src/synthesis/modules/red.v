module red (
    input clk,
    input rst_n,
    input in,
    output out
);
    reg [1:0] ff_reg, ff_next;
    assign out = ff_reg[0] & ~ff_reg[1];
    
    // sekvencijalna logika
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            ff_reg <= 2'b00;
        end
        else begin
            ff_reg <= ff_next;
        end
    end

    // kombinaciona logika
    always @(*) begin
        ff_next = {in, ff_reg[0]};
    end
endmodule