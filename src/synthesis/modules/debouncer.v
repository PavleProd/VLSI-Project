module debouncer (
    input clk,
    input rst_n,
    input in,
    output out
);
    reg out_next, out_reg;
    reg [1:0] ff_next, ff_reg;
    reg [7:0] cnt_next, cnt_reg;
    assign out = out_reg;

    wire in_changed, in_stable;

    assign in_changed = ff_reg[0] ^ ff_reg[1]; // vrednost na ulazu se promenila
    assign in_stable = (cnt_reg == 8'hFF) ? 1'b1 : 1'b0; // ako je ista vrednost 2^8 - 1 taktova, krecemo da ispisujemo tu vrednost

    // SEKVENCIJALNA LOGIKA
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= 1'b0;
            ff_reg <= 2'b00;
            cnt_reg <= 8'h00;
        end
        else begin
            out_reg <= out_next;
            ff_reg <= ff_next;
            cnt_reg <= cnt_next;
        end
    end

    // KOMBINACIONA LOGIKA
    always @(*) begin
        ff_next[0] = in; // nova vrednost
        ff_next[1] = ff_reg[0]; // stara vrednost
        cnt_next = in_changed ? 0 : (cnt_reg + 1'b1); // ako je vrednost ostala stabilna uvecavamo counter, inace ga resetujemo
        out_next = in_stable ? in : out_reg; // nova vrednost stabilizovana -> ispisi je, inace ispisi staru
    end

endmodule
