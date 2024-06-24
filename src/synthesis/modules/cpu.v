module cpu #(
    parameter ADDR_WIDTH = 6; // velicina memorije 2^ADDR_WIDTH memorijskih reci
    parameter DATA_WIDTH = 16; // velicina memorijske reci
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in, // izlaz iz memorije se pojavljuje ovde
    input [DATA_WIDTH-1:0] in,
    output mem_we, // write enable: 0 - citanje, 1 - upis
    output reg [ADDR_WIDTH-1:0] mem_addr, // ako je we==0, sa ove adrese se cita, inace se na nju upisuje
    output reg [DATA_WIDTH-1:0] mem_data, // ako je we==1, ovaj podatak se upisuje na addr
    output reg [DATA_WIDTH-1:0] out,
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

    reg null = 1'b0;

    // SISTEMSKI REGISTRI

    // 1. PC
    localparam PC_WIDTH = ADDR_WIDTH;

    reg [PC_WIDTH-1:0] pc_in;
    reg pc_ld, pc_inc;
    wire [PC_WIDTH-1:0] pc_out;

    register #(.DATA_WIDTH(PC_WIDTH)) pc (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(pc_ld),
        .inc(pc_inc),
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
    reg sp_ld, sp_cl;
    wire [SP_WIDTH-1:0] sp_out;

    register #(.DATA_WIDTH(SP_WIDTH)) sp (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(sp_cl),
        .ld(sp_ld),
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
    reg ir_high_ld;
    wire [IR_HIGH_WIDTH-1:0] ir_high_out;

    register #(.DATA_WIDTH(IR_HIGH_WIDTH)) ir_high (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(ir_high_ld),
        .inc(null),
        .dec(null),
        .sr(null),
        .ir(null),
        .sl(null),
        .il(null),
        .in(ir_high_in),
        .out(ir_high_out));

    assign ir_oc = ir_high[IR_HIGH_WIDTH - 1: IR_HIGH_WIDTH - 4];
    assign ir_op1_type = ir_high[IR_HIGH_WIDTH - 5];
    assign ir_op1 = ir_high[IR_HIGH_WIDTH - 6 : IR_HIGH_WIDTH - 8];
    assign ir_op2_type = ir_high[IR_HIGH_WIDTH - 9];
    assign ir_op2 = ir_high[IR_HIGH_WIDTH - 10 : IR_HIGH_WIDTH - 12];
    assign ir_op3_type = ir_high[IR_HIGH_WIDTH - 13];
    assign ir_op3 = ir_high[IR_HIGH_WIDTH - 14 : IR_HIGH_WIDTH - 16];

    // 4. IR LOW
    localparam IR_LOW_WIDTH = DATA_WIDTH;

    reg [IR_LOW_WIDTH-1:0] ir_low_in;
    reg ir_low_ld;
    wire [IR_LOW_WIDTH-1:0] ir_low_out;

    register #(.DATA_WIDTH(IR_LOW_WIDTH)) ir_low (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(ir_low_ld),
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
    reg acc_ld;
    wire [ACC_WIDTH-1:0] acc_out;

    register #(.DATA_WIDTH(ACC_WIDTH)) acc (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null),
        .ld(acc_ld),
        .inc(null),
        .dec(null),
        .sr(null),
        .ir(null),
        .sl(null),
        .il(null),
        .in(acc_in),
        .out(acc_out));

    // OPERATION CODES
    localparam OC_MOV = 4'b0000;

    // MEM[addr1] = MEM[addr2] op MEM[addr3]
    localparam OC_ADD = 4'b0001;
    localparam OC_SUB = 4'b0010;
    localparam OC_MUL = 4'b0011;
    localparam OC_DIV = 4'b0100; // ne koristi se

    localparam OC_IN = 4'b0101;
    localparam OC_OUT = 4'b0110;

    localparam OC_STOP = 4'b1111;
    // ---------------------------------

    // STATE MACHINE
    localparam INIT = 0; // stanje posle reseta, radimo inicijalizaciju vrednosti
    localparam LOAD_IR_HIGH = 1; // citanje vise reci IR registra sa trenutne vrednosti PC
    localparam LOAD_IR_HIGH_WAIT = 2;
    localparam LOAD_IR_HIGH_DONE = 3; 
    localparam LOAD_IR_LOW = 4; // citanje nize reci IR registra sa trenutne vrednosti PC
    localparam LOAD_IR_LOW_WAIT = 5;
    localparam LOAD_IR_LOW_DONE = 6;
    localparam LOAD_OP = 7;
    localparam LOAD_OP_WAIT = 8;
    localparam LOAD_OP_DONE = 9;
    localparam WRITE_OP = 10;
    localparam WRITE_OP_WAIT = 11;
    localparam WRITE_OP_DONE = 12;
    localparam STOP = 13;

    integer state_reg, state_next;
    reg mem_we_reg, mem_we_next;
    reg [ADDR_WIDTH-1:0] mem_addr_reg, mem_addr_next;
    reg [DATA_WIDTH-1:0] mem_data_reg, mem_data_next;
    reg [DATA_WIDTH-1:0] out_reg, out_next;

    // POMOCNI REGISTRI
    reg [3:0] load_needed; // c, op3, op2, op1
    localparam OP1_INDEX = 0;
    localparam OP2_INDEX = 1;
    localparam OP3_INDEX = 2;
    localparam C_INDEX = 3;

    // SEKVENCIJALNA LOGIKA
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            // reset signal ce resetovati i sve registre na 0
            state_reg <= INIT;
            
            mem_addr_reg <= {ADDR_WIDTH{1'b0}};
            mem_data_reg <= {DATA_WIDTH{1'b0}};
            mem_we_reg <= 1'b0;

            out_reg <= {DATA_WIDTH{1'b0}};
        end
        else begin
            state_reg <= state_next;
            
            mem_addr_reg <= mem_addr_next;
            mem_data_reg <= mem_data_next;
            mem_we_reg <= mem_we_next;

            out_reg <= out_next;
        end
    end

    // KOMBINACIONA LOGIKA
    always @(*) begin
        state_next = state_reg;
        
        mem_addr_next = mem_addr_reg;
        mem_data_next = mem_data_reg;
        mem_we_next = mem_we_reg;
        
        out_next = out_reg;

        // reset svih signala registara
        { pc_ld, pc_inc, ir_high_ld, ir_low_ld } = 4'd0;

        case (state_reg)
            INIT: begin
                pc_ld = 1'b1;
                pc_in = {(ADDR_WIDTH - 4){1'b0}, 4'd8}; // pocetna vrednost PC = 8

                load_needed = 4'h0;

                state_next = LOAD_IR_HIGH;
            end
            LOAD_IR_HIGH: begin
                mem_we_next = 1'b0;
                mem_addr_next = pc_out;
                pc_inc = 1'b1; // update PC na sledecu lokaciju

                state_next = LOAD_IR_HIGH_WAIT;
            end
            LOAD_IR_HIGH_WAIT: begin
                ir_high_ld = 1'b1;
                ir_high_in = mem_in;

                state_next = LOAD_IR_HIGH_DONE;
            end
            LOAD_IR_HIGH_DONE begin
                case (ir_oc)
                    OC_MOV: begin
                        if(ir_op3_type)
                            load_needed[C_INDEX] = 1'b1;
                            state_next = LOAD_IR_LOW;
                        else
                            load_needed[OP2_INDEX] = 1'b1;
                            state_next = LOAD_OP;
                    end
                    OC_OUT: begin
                        load_needed[OP1_INDEX] = 1'b1;
                        state_next = LOAD_OP;
                    end
                    OC_IN: begin
                        state_next = WRITE_OP;
                    end
                    OC_ADD, OC_SUB, OC_MUL: begin
                        load_needed[OP2_INDEX] = 1'b1;
                        load_needed[OP3_INDEX] = 1'b1;
                        state_next = LOAD_OP;
                    end
                    OC_STOP: begin
                        if(op1) begin
                            load_needed[OP1_INDEX] = 1'b1;
                            state_next = LOAD_OP;
                        end
                        else if(op2) begin
                            load_needed[OP2_INDEX] = 1'b1;
                            state_next = LOAD_OP;
                        end
                        else if(op3) begin
                            load_needed[OP3_INDEX] = 1'b1;
                            state_next = LOAD_OP;
                        end
                        else begin
                            state_next = STOP;
                        end
                    end
                    default: 
                endcase
            end
            LOAD_IR_LOW begin
                mem_we_next = 1'b0;
                mem_addr_next = pc_out;
                pc_inc = 1'b1; // update PC na sledecu lokaciju

                state_next = LOAD_IR_LOW_WAIT;
            end
            LOAD_IR_LOW_WAIT begin
                ir_low_ld = 1'b1;
                ir_low_in = mem_in;

                state_next = LOAD_IR_HIGH_DONE;
            end
            LOAD_IR_LOW_DONE begin
                // trenutno samo MOV operacija ima citanje IR_LOW
                state_next = WRITE_OP;
            end
                

            default: 
        endcase
    end

endmodule