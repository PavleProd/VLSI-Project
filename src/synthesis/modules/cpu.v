module cpu #(
    parameter ADDR_WIDTH = 6, // velicina memorije 2^ADDR_WIDTH memorijskih reci
    parameter DATA_WIDTH = 16 // velicina memorijske reci
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in, // izlaz iz memorije se pojavljuje ovde
    input [DATA_WIDTH-1:0] in,
    output mem_we, // write enable: 0 - citanje, 1 - upis
    output [ADDR_WIDTH-1:0] mem_addr, // ako je we==0, sa ove adrese se cita, inace se na nju upisuje
    output [DATA_WIDTH-1:0] mem_data, // ako je we==1, ovaj podatak se upisuje na addr
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

    reg null_reg = 1'b0;

    // SISTEMSKI REGISTRI

    // 1. PC
    localparam PC_WIDTH = ADDR_WIDTH;

    reg [PC_WIDTH-1:0] pc_in;
    reg pc_ld, pc_inc;
    wire [PC_WIDTH-1:0] pc_out;

    register #(.DATA_WIDTH(PC_WIDTH)) pc_instance (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null_reg),
        .ld(pc_ld),
        .inc(pc_inc),
        .dec(null_reg),
        .sr(null_reg),
        .ir(null_reg),
        .sl(null_reg),
        .il(null_reg),
        .in(pc_in),
        .out(pc_out));

    assign pc = pc_out;

    // 2. SP
    localparam SP_WIDTH = ADDR_WIDTH;

    reg [SP_WIDTH-1:0] sp_in;
    reg sp_ld, sp_cl;
    wire [SP_WIDTH-1:0] sp_out;

    register #(.DATA_WIDTH(SP_WIDTH)) sp_instance (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(sp_cl),
        .ld(sp_ld),
        .inc(null_reg),
        .dec(null_reg),
        .sr(null_reg),
        .ir(null_reg),
        .sl(null_reg),
        .il(null_reg),
        .in(sp_in),
        .out(sp_out));

    assign sp = sp_out;

    // 3. IR HIGH
    localparam IR_HIGH_WIDTH = DATA_WIDTH;

    reg [IR_HIGH_WIDTH-1:0] ir_high_in;
    reg ir_high_ld;
    wire [IR_HIGH_WIDTH-1:0] ir_high_out;

    register #(.DATA_WIDTH(IR_HIGH_WIDTH)) ir_high (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null_reg),
        .ld(ir_high_ld),
        .inc(null_reg),
        .dec(null_reg),
        .sr(null_reg),
        .ir(null_reg),
        .sl(null_reg),
        .il(null_reg),
        .in(ir_high_in),
        .out(ir_high_out));

    localparam DIRECT = 1'b0;
    localparam INDIRECT = 1'b1;

    wire [3:0] ir_oc;
    wire [2:0] ir_opa, ir_opb, ir_opc;
    wire ir_opa_type, ir_opb_type, ir_opc_type;

    assign ir_oc = ir_high[IR_HIGH_WIDTH - 1: IR_HIGH_WIDTH - 4];
    assign ir_opa_type = ir_high[IR_HIGH_WIDTH - 5];
    assign ir_opa = ir_high[IR_HIGH_WIDTH - 6 : IR_HIGH_WIDTH - 8];
    assign ir_opb_type = ir_high[IR_HIGH_WIDTH - 9];
    assign ir_opb = ir_high[IR_HIGH_WIDTH - 10 : IR_HIGH_WIDTH - 12];
    assign ir_opc_type = ir_high[IR_HIGH_WIDTH - 13];
    assign ir_opc = ir_high[IR_HIGH_WIDTH - 14 : IR_HIGH_WIDTH - 16];

    // 4. IR LOW
    localparam IR_LOW_WIDTH = DATA_WIDTH;

    reg [IR_LOW_WIDTH-1:0] ir_low_in;
    reg ir_low_ld;
    wire [IR_LOW_WIDTH-1:0] ir_low_out;

    register #(.DATA_WIDTH(IR_LOW_WIDTH)) ir_low (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null_reg),
        .ld(ir_low_ld),
        .inc(null_reg),
        .dec(null_reg),
        .sr(null_reg),
        .ir(null_reg),
        .sl(null_reg),
        .il(null_reg),
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
        .cl(null_reg),
        .ld(acc_ld),
        .inc(null_reg),
        .dec(null_reg),
        .sr(null_reg),
        .ir(null_reg),
        .sl(null_reg),
        .il(null_reg),
        .in(acc_in),
        .out(acc_out));

    // 6. Operandi
    localparam OPERAND_WIDTH = DATA_WIDTH;

    reg [OPERAND_WIDTH-1:0] opa_in;
    reg opa_ld;
    wire [OPERAND_WIDTH-1:0] opa_out;

    register #(.DATA_WIDTH(OPERAND_WIDTH)) opa (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null_reg),
        .ld(opa_ld),
        .inc(null_reg),
        .dec(null_reg),
        .sr(null_reg),
        .ir(null_reg),
        .sl(null_reg),
        .il(null_reg),
        .in(opa_in),
        .out(opa_out));

    reg [OPERAND_WIDTH-1:0] opb_in;
    reg opb_ld;
    wire [OPERAND_WIDTH-1:0] opb_out;

    register #(.DATA_WIDTH(OPERAND_WIDTH)) opb (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null_reg),
        .ld(opb_ld),
        .inc(null_reg),
        .dec(null_reg),
        .sr(null_reg),
        .ir(null_reg),
        .sl(null_reg),
        .il(null_reg),
        .in(opb_in),
        .out(opb_out));

    reg [OPERAND_WIDTH-1:0] opc_in;
    reg opc_ld;
    wire [OPERAND_WIDTH-1:0] opc_out;

    register #(.DATA_WIDTH(OPERAND_WIDTH)) opc (
        .clk(clk),
        .rst_n(rst_n), 
        .cl(null_reg),
        .ld(opc_ld),
        .inc(null_reg),
        .dec(null_reg),
        .sr(null_reg),
        .ir(null_reg),
        .sl(null_reg),
        .il(null_reg),
        .in(opc_in),
        .out(opc_out));

    // ALU JEDINICA
    reg [2:0] alu_oc;
    reg [DATA_WIDTH-1:0] alu_a, alu_b;
    wire [DATA_WIDTH-1:0] alu_out;
    reg [DATA_WIDTH-1:0] alu_out_reg, alu_out_next;

    // mapirani operacioni kodovi
    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_MUL = 3'b010;
    localparam ALU_DIV = 3'b011;
    localparam ALU_NOT = 3'b100;
    localparam ALU_XOR = 3'b101;
    localparam ALU_OR = 3'b110;
    localparam ALU_AND = 3'b111;

    alu #(.DATA_WIDTH(DATA_WIDTH)) alu_unit(.oc(alu_oc), .a(alu_a), .b(alu_b), .f(alu_out));

    // OPERATION CODES
    localparam OC_MOV = 4'b0000;

    localparam OC_ADD = 4'b0001;
    localparam OC_SUB = 4'b0010;
    localparam OC_MUL = 4'b0011;
    localparam OC_DIV = 4'b0100; // ne koristi se

    localparam OC_IN = 4'b0101;
    localparam OC_OUT = 4'b0110;

    localparam OC_STOP = 4'b1111;
    // ---------------------------------

    // STATE MACHINE
    localparam INIT = 6'd0; // stanje posle reseta, radimo inicijalizaciju vrednosti
    
    // Load IR-a
    localparam LOAD_IR_HIGH_MEMORY = 6'd1;
    localparam LOAD_IR_HIGH_REGISTER = 6'd2;
    localparam LOAD_IR_HIGH_DONE = 6'd3; 
    localparam LOAD_IR_LOAD_MEMORY = 6'd4;
    localparam LOAD_IR_LOW_REGISTER = 6'd5;
    localparam LOAD_IR_LOW_DONE = 6'd6;

    // Citanje Operanada
    localparam LOAD_OPA_MEMORY = 6'd7;
    localparam LOAD_OPA_MEMORY_INDIRECT = 6'd8;
    localparam LOAD_OPA_DONE = 6'd9;
    localparam LOAD_OPB_MEMORY = 6'd10;
    localparam LOAD_OPB_MEMORY_INDIRECT = 6'd11;
    localparam LOAD_OPB_DONE = 6'd12;
    localparam LOAD_OPC_MEMORY = 6'd13;
    localparam LOAD_OPC_MEMORY_INDIRECT = 6'd14;
    localparam LOAD_OPC_DONE = 6'd15;

    // Upis Operanada
    localparam WRITE_OPA_MEMORY = 6'd16;
    localparam WRITE_OPA_MEMORY_INDIRECT = 6'd17;
    localparam WRITE_OPA_DONE = 6'd18;

    // Instrukcije
    localparam INSTR_ALU = 6'd19;
    localparam INSTR_OUT = 6'd20;

    localparam INSTR_STOP = 6'd21;
    localparam STOPA = 6'd22;
    localparam STOPB = 6'd23;
    localparam STOPC = 6'd24;

    reg [5:0] state_reg, state_next;
    reg mem_we_reg, mem_we_next;
    reg [ADDR_WIDTH-1:0] mem_addr_reg, mem_addr_next;
    reg [DATA_WIDTH-1:0] mem_data_reg, mem_data_next;
    reg [DATA_WIDTH-1:0] out_reg, out_next;

    assign mem_we = mem_we_reg;
    assign mem_addr = mem_addr_reg;
    assign mem_data = mem_data_reg;
    assign out = out_reg;

    // 0 - direktno (ako je direktno tu stajemo), 1 - indirektno
    reg load_phase_reg, load_phase_next;

    // SEKVENCIJALNA LOGIKA
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            // reset signal ce resetovati i sve registre na 0
            state_reg <= INIT;
            
            mem_addr_reg <= {ADDR_WIDTH{1'b0}};
            mem_data_reg <= {DATA_WIDTH{1'b0}};
            mem_we_reg <= 1'b0;

            load_phase_reg <= 1'b0;

            alu_out_reg <= {DATA_WIDTH{1'b0}};
            out_reg <= {DATA_WIDTH{1'b0}};
        end
        else begin
            state_reg <= state_next;
            
            mem_addr_reg <= mem_addr_next;
            mem_data_reg <= mem_data_next;
            mem_we_reg <= mem_we_next;

            load_phase_reg <= load_phase_next;

            alu_out_reg <= alu_out_next;
            out_reg <= out_next;
        end
    end

    // KOMBINACIONA LOGIKA
    always @(*) begin
        state_next = state_reg;
        
        mem_addr_next = mem_addr_reg;
        mem_data_next = mem_data_reg;
        mem_we_next = mem_we_reg;
        
        load_phase_next = load_phase_reg;

        alu_b = {DATA_WIDTH{1'b0}};
        alu_a = {DATA_WIDTH{1'b0}};
        alu_oc = 3'h0;
        alu_out_next = alu_out_reg;

        pc_in = 6'd0;
        ir_high_in = {DATA_WIDTH{1'b0}};
        ir_low_in = {DATA_WIDTH[1'b0]};
        opa_in = {DATA_WIDTH{1'b0}};
        opb_in = {DATA_WIDTH{1'b0}};
        opc_in = {DATA_WIDTH{1'b0}};

        out_next = out_reg;

        // reset svih signala
        { pc_ld, pc_inc, ir_high_ld, ir_low_ld, opa_ld, opb_ld, opc_ld } = 7'd0;

        case (state_reg)
            INIT: begin
                pc_ld = 1'b1;
                pc_in = {{(PC_WIDTH - 4){1'b0}}, 4'd8}; // pocetna vrednost PC = 8

                state_next = LOAD_IR_HIGH_MEMORY;
            end
            LOAD_IR_HIGH_MEMORY: begin
                mem_we_next = 1'b0;
                mem_addr_next = pc_out;
                pc_inc = 1'b1; // update PC na sledecu lokaciju

                state_next = LOAD_IR_HIGH_REGISTER;
            end
            LOAD_IR_HIGH_REGISTER: begin
                ir_high_ld = 1'b1;
                ir_high_in = mem_in;

                state_next = LOAD_IR_HIGH_DONE;
            end
            LOAD_IR_HIGH_DONE: begin
                case (ir_oc)
                    OC_MOV: begin
                        if(ir_opc_type)
                            state_next = LOAD_IR_LOAD_MEMORY;
                        else
                            state_next = LOAD_OPB_MEMORY;
                    end
                    OC_ADD, OC_SUB, OC_MUL: begin
                        state_next = LOAD_OPB_MEMORY;
                    end
                    OC_IN: begin
                        state_next = WRITE_OPA_MEMORY;
                    end
                    OC_OUT: begin
                        state_next = LOAD_OPA_MEMORY;
                    end
                    OC_STOP: begin
                        if(ir_opa) begin
                            state_next = LOAD_OPA_MEMORY;
                        end
                        else if(ir_opb) begin
                            state_next = LOAD_OPB_MEMORY;
                        end
                        else if(ir_opc) begin
                            state_next = LOAD_OPC_MEMORY;
                        end
                        else begin
                            state_next = INSTR_STOP;
                        end
                    end
                    default:
                        state_next = LOAD_IR_HIGH_MEMORY; // DIV trenutno ne radi nista
                endcase
            end
            LOAD_IR_LOAD_MEMORY: begin
                mem_we_next = 1'b0;
                mem_addr_next = pc_out;
                pc_inc = 1'b1; // update PC na sledecu lokaciju

                state_next = LOAD_IR_LOW_REGISTER;
            end
            LOAD_IR_LOW_REGISTER: begin
                ir_low_ld = 1'b1;
                ir_low_in = mem_in;

                state_next = LOAD_IR_LOW_DONE;
            end
            LOAD_IR_LOW_DONE: begin
                // trenutno samo MOV operacija ima citanje IR_LOW
                state_next = WRITE_OPA_MEMORY;
            end
            LOAD_OPA_MEMORY: begin
                mem_we_next = 1'b0;
                mem_addr_next = ir_opa;

                if(ir_opa_type == INDIRECT)
                    state_next = LOAD_OPA_MEMORY_INDIRECT;
                else
                    state_next = LOAD_OPA_DONE;
            end
            LOAD_OPA_MEMORY_INDIRECT: begin
                mem_we_next = 1'b0;
                mem_addr_next = mem_in[ADDR_WIDTH-1:0]; // ucitavamo samo najnizih ADDR_WIDTH bita

                state_next = LOAD_OPA_DONE; 
            end
            LOAD_OPA_DONE: begin
                opa_ld = 1'b1;
                opa_in = mem_in;

                case (ir_oc)
                    OC_OUT: begin
                        state_next = INSTR_OUT;
                    end
                    OC_STOP: begin
                        state_next = INSTR_STOP;
                    end 
                    default:
                        state_next = LOAD_IR_HIGH_MEMORY; // GRESKA
                endcase
            end
            LOAD_OPB_MEMORY: begin
                mem_we_next = 1'b0;
                mem_addr_next = ir_opa;

                if(ir_opb_type == INDIRECT)
                    state_next = LOAD_OPB_MEMORY_INDIRECT;
                else
                    state_next = LOAD_OPB_DONE;
            end
            LOAD_OPB_MEMORY_INDIRECT: begin
                mem_we_next = 1'b0;
                mem_addr_next = mem_in[ADDR_WIDTH-1:0]; // ucitavamo samo najnizih ADDR_WIDTH bita

                state_next = LOAD_OPB_DONE; 
            end
            LOAD_OPB_DONE: begin
                opb_ld = 1'b1;
                opb_in = mem_in;

                case (ir_oc)
                    OC_MOV: begin
                        state_next = WRITE_OPA_MEMORY;
                    end 
                    OC_STOP: begin
                        state_next = STOPB;
                    end
                    OC_ADD, OC_SUB, OC_MUL: begin
                        state_next = LOAD_OPC_MEMORY;
                    end
                    default:
                        state_next = LOAD_IR_HIGH_MEMORY; // GRESKA
                endcase
            end
            LOAD_OPC_MEMORY: begin
                mem_we_next = 1'b0;
                mem_addr_next = ir_opc;

                if(ir_opc_type == INDIRECT)
                    state_next = LOAD_OPC_MEMORY_INDIRECT;
                else
                    state_next = LOAD_OPC_DONE;
            end
            LOAD_OPC_MEMORY_INDIRECT: begin
                mem_we_next = 1'b0;
                mem_addr_next = mem_in[ADDR_WIDTH-1:0]; // ucitavamo samo najnizih ADDR_WIDTH bita

                state_next = LOAD_OPC_DONE; 
            end
            LOAD_OPC_DONE: begin
                opc_ld = 1'b1;
                opc_in = mem_in;

                case (ir_oc)
                    OC_ADD, OC_SUB, OC_MUL: begin
                        state_next = INSTR_ALU;
                    end 
                    OC_STOP: begin
                        state_next = STOPC;
                    end
                    default: 
                        state_next = LOAD_IR_HIGH_MEMORY; // GRESKA
                endcase
            end
            WRITE_OPA_MEMORY: begin

                mem_addr_next = ir_opa;

                if(ir_opa_type == INDIRECT) begin
                    mem_we_next = 1'b0;
                    state_next = WRITE_OPA_MEMORY_INDIRECT;
                end
                else begin
                    mem_we_next = 1'b1;
                    
                    case (ir_oc)
                        OC_IN: begin
                            mem_data_next = in;
                        end
                        OC_MOV: begin
                            if(ir_opc_type == INDIRECT)
                                mem_data_next = ir_low_out;
                            else
                                mem_data_next = opb_out;
                        end
                        OC_ADD, OC_SUB, OC_MUL: begin
                            mem_data_next = alu_out_reg;
                        end
                        default:
                            state_next = LOAD_IR_HIGH_MEMORY; // GRESKA 
                    endcase

                    state_next = WRITE_OPA_DONE;
                end
            end
            WRITE_OPA_MEMORY_INDIRECT: begin
                mem_we_next = 1'b1;
                mem_addr_next = mem_in[ADDR_WIDTH-1:0]; // ucitavamo samo najnizih ADDR_WIDTH bita
                
               case (ir_oc)
                    OC_IN: begin
                        mem_data_next = in;
                    end
                    OC_MOV: begin
                        if(ir_opc_type == INDIRECT)
                            mem_data_next = ir_low_out;
                        else
                            mem_data_next = opb_out;
                    end
                    OC_ADD, OC_SUB, OC_MUL: begin
                        mem_data_next = alu_out_reg;
                    end
                    default:
                        state_next = LOAD_IR_HIGH_MEMORY; // GRESKA 
                endcase
            end
            WRITE_OPA_DONE: begin
                out_next = mem_in;
                state_next = LOAD_IR_HIGH_MEMORY;
            end
            INSTR_ALU: begin
                alu_a = opb_out;
                alu_b = opc_out;

                case (ir_oc)
                    OC_ADD: begin
                        alu_oc = ALU_ADD;
                        state_next = WRITE_OPA_MEMORY;
                    end
                    OC_SUB: begin
                        alu_oc = ALU_SUB;
                        state_next = WRITE_OPA_MEMORY;
                    end
                    OC_MUL: begin
                        alu_oc = ALU_SUB;
                        state_next = WRITE_OPA_MEMORY;
                    end
                    default:
                        state_next = LOAD_IR_HIGH_MEMORY; // GRESKA
                endcase

                alu_out_next = alu_out; // pamtimo stanje alu u registar
            end
            STOPA: begin
                out_next = opa_out;

                if(opb_out) begin
                    state_next = LOAD_OPB_MEMORY;
                end
                else if(opc_out) begin
                    state_next = LOAD_OPC_MEMORY;
                end
                else begin
                    state_next = INSTR_STOP;
                end
            end
            STOPB: begin
                out_next = opb_out;

                if(opc_out) begin
                    state_next = LOAD_OPC_MEMORY;
                end
                else begin
                    state_next = INSTR_STOP;
                end
            end
            STOPC: begin
                out_next = opc_out;

                state_next = INSTR_STOP;
            end
            INSTR_STOP: begin
                state_next = INSTR_STOP; // vrtimo se zauvek u ovom stanju
            end
            INSTR_OUT: begin
                out_next = opa_out;
                state_next = LOAD_IR_HIGH_MEMORY;
            end
            default: 
                state_next = LOAD_IR_HIGH_MEMORY; // GRESKA
        endcase
    end

endmodule