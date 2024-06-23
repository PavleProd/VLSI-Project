module top;

    // alu
    reg [2:0] oc;
    reg [3:0] a, b;
    wire [3:0] f;

    alu alu_instance(oc, a, b, f); 

    integer i;

    initial begin
        // alu
        for(i = 0; i < 2 ** 11; i = i + 1) begin
            {oc, a, b} = i;
            #5;
        end
        $stop; // ne zaustavlja simulaciju, samo je pauzira. Mozemo pokrenuti opet sa run -all
    end

    // alu
    initial begin
        $monitor("time = %4d, oc = %3b, a = %4b, b = %4b, f = %4b", $time, oc, a, b, f);
    end

endmodule