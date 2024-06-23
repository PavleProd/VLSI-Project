module register # (
    parameter DATA_WIDTH = 16
) (
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
    input [DATA_WIDTH-1:0] in,
    output [DATA_WIDTH-1:0] out
);

    reg [3:0] out_reg, out_next;
    assign out = out_reg;

    // kombinaciona logika
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= {DATA_WIDTH{1'b0}};
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
            out_next = {DATA_WIDTH{1'b0}};
        else if (ld)
            out_next = in;
        else if (inc)
            out_next = out_reg + 1'b1;
        else if (dec)
            out_next = out_reg - 1'b1;
        else if(sr)
            out_next = {ir, out_reg[DATA_WIDTH-1:1]};
        else if(sl)
            out_next = {out_reg[DATA_WIDTH-2:0], il};
    end
    
endmodule