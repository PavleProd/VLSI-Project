module bcd (
    input [5:0] in,
    output [3:0] ones,
    output [3:0] tens
);

    assign tens = in / 6'd10;
    assign ones = in % 6'd10;
endmodule