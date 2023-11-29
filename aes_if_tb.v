`timescale 1ns/1ps

module tb(output reg [127:0] data_o);
reg clk;
reg rst_n = 0;
reg [1:0] counter = 2'b00;
reg enable = 0;
reg [127:0] i_text;
reg [255:0] key;
reg pt_sel, key_sel, ct_out_sel;

wire trigger;
reg done = 0;
wire [386:0]sc_out;
reg busy_o;
reg load_i = 0;
wire [386:0] scan_chain;


parameter CLK_PERIOD = 10;

assign scan_chain = {i_text, key, pt_sel, key_sel, ct_out_sel};


localparam AES_KEYSCHED = 0;
localparam AES_DECRYPT = 1;

reg [1:0] fsm, fsm_new;

always @(posedge clk)
begin
    #2000
    #300 load_i = ~load_i;
    #1 load_i = ~load_i;

end


always @(posedge trigger) begin

    counter = counter + 1;
    if (counter == 2'b10)
    begin
        done = 1;
        // counter = 0;
    end
end


always @(negedge trigger) 
begin
    if (counter == 2'b10 & done == 1) begin
        done = 0;
        counter = 2'b00;
    end
end


initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task reset_dut;
begin
    enable = 1'b0;
    i_text = 127'b0;
    key = 255'b0;
    pt_sel = 1'b0;
    key_sel = 1'b0;
    ct_out_sel = 1'b0;

    rst_n = 1'b0;
    #(1 * CLK_PERIOD);
    rst_n = 1'b1;
    #(2 * CLK_PERIOD);
end
endtask


task encrypt(input [127:0] sc_pt, 
                  input [256:0] sc_key,
                  input sc_pt_sel,
                  input sc_key_sel,
                  input sc_ct_out_sel);
begin
    i_text = sc_pt;
    key = sc_key;
    pt_sel = sc_pt_sel;
    key_sel = sc_key_sel;
    ct_out_sel = sc_ct_out_sel;
    #(1 * CLK_PERIOD);
    enable = 1'b1;
    @(posedge trigger);
    #(CLK_PERIOD);
end
endtask

initial begin

    reset_dut();

end

//assign temp = 128'h00112233445566778899aabbccddeeff;

always @(posedge clk, posedge done)

begin
    if(load_i == 1)
    begin

        busy_o = 1;
        encrypt(128'h00112233445566778899aabbccddeeff,
                         256'h0000000000000000000000000000000000000000000000000000000000000000,
                         1'b1,
                         1'b1,
                         1'b0);    
        // enable = 1;
    
    // if (done == 1'b1)
    //    begin
    //      data_o = sc_out[127:0];
    //      busy_o = 0;
    //    end

    end

end

always @(posedge done)
begin
    busy_o  <= 0;
    data_o <= sc_out[127:0];

end

////***************original code begins**********************
// initial begin
//     // Counter plaintext, hardcoded key
//     reset_dut();
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b0,
//                  1'b0,
//                  1'b0);
//     // f29000b62a499fd0a9f39a6add2e7780
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b0,
//                  1'b0,
//                  1'b0);
//     // 75e20829172112bbf2a04d3d2b12433d

//     // SC plaintext, hardcoded key
//     reset_dut();
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b1,
//                  1'b0,
//                  1'b0);
//     //8ea2b7ca516745bfeafc49904b496089
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b1,
//                  1'b0,
//                  1'b0);
//     //8ea2b7ca516745bfeafc49904b496089

//     // Counter plaintext, SC key
//     reset_dut();
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b0,
//                  1'b1,
//                  1'b0);
//     // dc95c078a2408989ad48a21492842087
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b0,
//                  1'b1,
//                  1'b0);
//     //7bc3026cd737103e62902bcd18fb0163

//     // SC plaintext, SC key
//     reset_dut();
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b1,
//                  1'b1,
//                  1'b0);
//     //1c060f4c9e7ea8d6ca961a2d64c05c18
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b1,
//                  1'b1,
//                  1'b0);
//     //1c060f4c9e7ea8d6ca961a2d64c05c18

//     // Ciphertext Output, Counter plaintext, hardcoded key
//     reset_dut();
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b0,
//                  1'b0,
//                  1'b1);
//     encrypt(128'h00112233445566778899aabbccddeeff,
//                  256'h0000000000000000000000000000000000000000000000000000000000000000,
//                  1'b0,
//                  1'b0,
//                  1'b1);
//     //f29000b62a499fd0a9f39a6add2e7780



// end


// aes_if DUT(clk, rst_n, scan_chain, enable, trigger, sc_out);
   aes_if DUT (
       .CLK             (clk),
       .RST_N          (rst_n),
       .SCAN_CHAIN      (scan_chain),
       .ENABLE          (enable),
       .TRIGGER_EXT     (trigger),
       .CIPHERTEXT      (sc_out),//enc mode
       .CT_OUT          ()
   );
endmodule // tb

////***************original code ends**********************
