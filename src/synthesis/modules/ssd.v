module ssd (
  input [3:0] in,
    output reg [6:0] out
);

  // aktivno u 0, od donjeg ka gornjem bitu: sredina, gornji pa u smeru okretanja kazaljke
  always @(*) begin
    case (in)
      0: out = ~7'h3F;
      1: out = ~7'h06;
      2: out = ~7'h5B;
      3: out = ~7'h4F;
      4: out = ~7'h66;
      5: out = ~7'h6D;
      6: out = ~7'h7D;
      7: out = ~7'h07;
      8: out = ~7'h7F;
      9: out = ~7'h6F;
      10: out = ~7'h37;
      default: out = ~7'h00;
    endcase
  end

endmodule