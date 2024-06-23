module top;

    // alu
    reg [2:0] oc;
    reg [3:0] a, b;
    wire [3:0] f;

    alu alu_instance(oc, a, b, f);

    // register
    reg clk, rst_n, cl, ld, inc, dec, sr, ir, sl, il;
    reg [3:0] in;
    wire [3:0] out;

    register register_instance(.clk(clk), .rst_n(rst_n), .cl(cl), .ld(ld), .inc(inc), .dec(dec), .sr(sr), .ir(ir), .sl(sl), .il(il), .in(in), .out(out));

    integer i;

    initial begin
        // alu
        for(i = 0; i < 2 ** 11; i = i + 1) begin
            {oc, a, b} = i;
            #5;
        end
        $stop; // ne zaustavlja simulaciju, samo je pauzira. Mozemo pokrenuti opet sa run -all

        // register
        rst_n = 1'b0;
        #0 rst_n = ~rst_n;
        repeat (1000) begin
            {cl, ld, inc, dec, sr, ir, sl, il, in} = $urandom_range(0, 2 ** 12 - 1);
            #5;
        end
        $finish; // kraj simulacije
    end

    // alu
    initial begin
        $monitor("time = %4d, oc = %3b, a = %4b, b = %4b, f = %4b", $time, oc, a, b, f);
    end

    // register
    initial begin
        clk = 1'b0;
        forever begin
            #5 clk = ~clk;
        end
    end

    always @(out) begin
        $strobe(
            "time = %5d, cl = %b, ld = %b, inc = %b, dec = %b, sr = %b, ir = %b, sl = %b, il = %b, in = %b, out = %b",
            $time, cl, ld, inc, dec, sr, ir, sl, il, in, out);
    end

endmodule