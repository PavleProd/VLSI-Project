module memory #(
	parameter FILE_NAME = "mem_init.mif", // fajl iz kog se inicijalizuje memorija
    parameter ADDR_WIDTH = 6, // velicina memorije 2^ADDR_WIDTH memorijskih reci
    parameter DATA_WIDTH = 16 // velicina memorijske reci
)(
    input clk,
    input we, // write enable: 0 - citanje, 1 - upis
    input [ADDR_WIDTH - 1:0] addr, // ako je we==0, sa ove adrese se cita, inace se upisuje
    input [DATA_WIDTH - 1:0] data, // ako je we==1, ovaj podatak se upisuje na addr
    output reg [DATA_WIDTH - 1:0] out // upisuje se uvek podatak sa adrese addr(novoupisani ako je upis)
);

    // podrazumevano 2^6 ulaza. Prvih 8 lokacija: GPR registri.
    // Ostale lokacije: slobodna zona podataka (program, podaci, stek)
    // STEK: poslednja memorijska lokacija, raste ka nizim adresama
	(* ram_init_file = FILE_NAME *) reg [DATA_WIDTH - 1:0] mem [2**ADDR_WIDTH - 1:0];

    always @(posedge clk) begin
        if (we) begin
            mem[addr] = data;
        end
        out <= mem[addr];
    end

endmodule
