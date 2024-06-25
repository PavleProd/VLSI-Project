module moduleName #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif", // fajl iz kog se inicijalizuje memorija
    parameter ADDR_WIDTH = 6, // velicina memorije 2^ADDR_WIDTH memorijskih reci
    parameter DATA_WIDTH = 16 // velicina memorijske reci
) (
    input clk,
    input rst_n,
    input [2:0] btn,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex;
);

    wire clk_out;
    clk_div #(.DIVISOR(DIVISOR)) clk_div_instance (.clk(clk), .rst_n(rst_n), .out(clk_out));

    reg mem_we;
    reg [ADDR_WIDTH - 1:0] mem_addr;
    reg [DATA_WIDTH - 1:0] mem_data;
    wire [DATA_WIDTH - 1:0] mem_out;

    memory #(.FILE_NAME(FILE_NAME), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mem_instance (
        .clk(clk_out),
        .we(mem_we),
        .addr(mem_addr),
        .out(mem_out)
    );

    wire [DATA_WIDTH-1:0] cpu_out;
    wire [ADDR_WIDTH-1:0] pc_out, sp_out;

    cpu #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) cpu_instance(
        .clk(clk_out),
        .rst_n(rst_n),
        .mem_in(mem_out),
        .in({(DATA_WIDTH - 4){1'b0}, sw[3:0]}),
        .mem_we(mem_we),
        .mem_addr(mem_addr),
        .mem_data(mem_data),
        .out(cpu_out),
        .pc(pc_out),
        .sp(sp_out)
    );

    assign led[4:0] = cpu_out[4:0];

    wire [3:0] tens_sp, ones_sp;
    bcd bcd_sp(sp_out, tens_sp, ones_sp);

    wire [3:0] tens_pc, ones_pc;
    bcd bcd_pc(pc_out, tens_pc, ones_pc);

    ssd ssd1(tens_sp, hex[27:21]);
    ssd ssd2(ones_sp, hex[20:14]);
    ssd ssd3(tens_pc, hex[13:7]);
    ssd ssd4(ones_pc, hex[6:0]);

endmodule