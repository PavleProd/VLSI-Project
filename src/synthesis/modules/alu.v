module alu # (
    parameter DATA_WIDTH = 16
)(
    input [2:0] oc,
    input [DATA_WIDTH-1:0] a,
    input [DATA_WIDTH-1:0] b,
    output reg [DATA_WIDTH-1:0] f
);

    // mapirani operacioni kodovi
    localparam ADD = 3'b000;
    localparam SUB = 3'b001;
    localparam MUL = 3'b010;
    localparam DIV = 3'b011;
    localparam NOT = 3'b100;
    localparam XOR = 3'b101;
    localparam OR = 3'b110;
    localparam AND = 3'b111;

    // na promenu a, c, oc
    always @(*) begin
        case (oc)
            ADD: f = a + b;
            SUB: f = a - b; 
            MUL: f = a * b;
            DIV: f = a / b; // sta ako je b 0?
            NOT: f = ~a;
            XOR: f = a ^ b;
            OR: f = a | b;
            AND: f = a & b;
        endcase
    end
    
endmodule