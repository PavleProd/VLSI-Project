module cpu #(
    parameter ADDR_WIDTH = 6; // velicina memorije 2^ADDR_WIDTH memorijskih reci
    parameter DATA_WIDTH = 16; // velicina memorijske reci
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in,
    input [DATA_WIDTH-1:0] in,
    output mem_we,
    output [ADDR_WIDTH-1:0] mem_addr,
    output [DATA_WIDTH-1:0] mem_data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp
);
    /* OPIS PROCESORA
    1) Podaci: unsigned int, velicine DATA_WIDTH
    2) Registri:
        a) PC - 6b (Program Counter). Pocetna vrednost 8
        b) SP - 6b, (Stack Pointer). Ukazuje na prvu slobodnu memorijsku lokaciju. Stek pocinje od poslednje adrese i ide ka nizim
        c) IR - 32b (Instruction Register)
        d) A - 16b (Accumulator)
    3) Procesor: 3A Instrukcije. Format: oc - kod operacije; D/I - Direktno(0), Indirektno(1);
        1. bajt: | oc oc oc oc | D/I addr addr addr | D/I addr addr addr | D/I addr addr addr | 
        2. bajt  |                              Konstanta  / Adresa                           |
    */

    // OC-ovi instrukcijskog seta
    localparam MOV = 4'b0000;

    // MEM[addr1] = MEM[addr2] op MEM[addr3]
    localparam ADD = 4'b0001;
    localparam SUB = 4'b0010;
    localparam MUL = 4'b0011;
    localparam DIV = 4'b0100;

    localparam STOP = 4'b1111;
    // ---------------------------------

    // POMOCNI REGISTRI
    reg null = 1'b0;

    // SISTEMSKI REGISTRI

    // 1. PC
    localparam PC_WIDTH = ADDR_WIDTH;

    reg [PC_WIDTH-1:0] pc_in;
    wire [PC_WIDTH-1:0] pc_out;

    register #(.DATA_WIDTH(PC_WIDTH)) pc (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(null),
        .inc(null),
        .dec(null),
        .sr(null),
        .ir(null),
        .sl(null),
        .il(null),
        .in(pc_in),
        .out(pc_out));

    assign pc = pc_out;

    // 2. SP
    localparam SP_WIDTH = ADDR_WIDTH;

    reg [SP_WIDTH-1:0] sp_in;
    wire [SP_WIDTH-1:0] sp_out;

    register #(.DATA_WIDTH(SP_WIDTH)) sp (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(null),
        .inc(null),
        .dec(null),
        .sr(null),
        .ir(null),
        .sl(null),
        .il(null),
        .in(sp_in),
        .out(sp));

    assign sp = sp_out;

    // 3. IR HIGH
    localparam IR_HIGH_WIDTH = DATA_WIDTH;

    reg [IR_HIGH_WIDTH-1:0] ir_high_in;
    wire [IR_HIGH_WIDTH-1:0] ir_high_out;

    register #(.DATA_WIDTH(IR_HIGH_WIDTH)) ir_high (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(null),
        .inc(null),
        .dec(null),
        .sr(null),
        .ir(null),
        .sl(null),
        .il(null),
        .in(ir_high_in),
        .out(ir_high_out));

    // 4. IR LOW
    localparam IR_LOW_WIDTH = DATA_WIDTH;

    reg [IR_LOW_WIDTH-1:0] ir_low_in;
    wire [IR_LOW_WIDTH-1:0] ir_low_out;

    register #(.DATA_WIDTH(IR_LOW_WIDTH)) ir_low (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(null),
        .inc(null),
        .dec(null),
        .sr(null),
        .ir(null),
        .sl(null),
        .il(null),
        .in(ir_low_in),
        .out(ir_low_out));

    // 5. ACC
    localparam ACC_WIDTH = DATA_WIDTH;

    reg [ACC_WIDTH-1:0] acc_in;
    wire [ACC_WIDTH-1:0] acC_out;

    register #(.DATA_WIDTH(ACC_WIDTH)) ir_low (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(null),
        .inc(null),
        .dec(null),
        .sr(null),
        .ir(null),
        .sl(null),
        .il(null),
        .in(acc_in),
        .out(acc_out));

endmodule