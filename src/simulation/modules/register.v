module register (
    input clk,
    input rst_n,
    input cl, // clear
    input ld, // load
    input inc, // increment 
    input dec, // decrement
    input sr, // shift right
    input ir, // information right, bit koji se ubacuje prilikom sr
    input sl, // shift left
    input il, // information left, bit koji se ubacuje prilikom sl
    input [3:0] in,
    output [3:0] out
);

    reg [3:0] out_reg, out_next;
    assign out = out_reg;

    // kombinaciona logika
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= 4'h0;
        end
        else begin
            out_reg <= out_next;
        end
    end

    // sekvencijalna logika
    // prioritet operacija odgovara prioritetu navodjenja parametara
    always @(*) begin
        out_next = out_reg;

        if(cl)
            out_next = 4'h0;
        else if (ld)
            out_next = in;
        else if (inc)
            out_next = out_reg + 1'b1;
        else if (dec)
            out_next = out_reg - 1'b1;
        else if(sr)
            out_next = {ir, out_reg[3:1]};
        else if(sl)
            out_next = {out_reg[2:0], il};
    end
    
endmodule