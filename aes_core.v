`timescale 1ns/1ps

module tb(output reg [127:0] data_o);
reg clk;
reg rst_n = 0;
reg [1:0] counter = 2'b00;
reg enable = 0;
reg [127:0] i_text;
reg [255:0] key;
reg pt_sel, key_sel, ct_out_sel;
reg [2:0] fsm, fsm_new;


wire trigger;
reg done = 0;
wire [386:0]sc_out;
reg busy_o;
reg load_i = 0;
wire [386:0] scan_chain;


parameter CLK_PERIOD = 10;
integer count = 0;
assign scan_chain = {i_text, key, 1'b1, 1'b1, 1'b0};


localparam RESET = 3'b000;
localparam INIT = 3'b001;
localparam ENCRYPT = 3'b010;
localparam WAIT = 3'b011;
localparam FINISH = 3'b100;


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




always @(posedge clk)
begin
    #2000
    #300 load_i = ~load_i;
    #1 load_i = ~load_i;

end

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end



always @(posedge clk)
begin


    case(fsm)
       RESET: begin
           fsm <= INIT;
           reset_dut();
           data_o  <= 0;
           key <= 0;
           busy_o <= 0;
           count <= 0;

       end
       INIT: begin
           fsm <= ENCRYPT;
           i_text <= 128'h00112233445566778899aabbccddeeff;
           key <= 256'h0;
       end
       ENCRYPT: begin
           fsm <= WAIT;
           // rst_n <= 1'b0;
           enable <= 1'b1;
       end
       WAIT: begin
            if (trigger != 1) begin
                fsm <= WAIT;
                count <= count + 1;
            end
            else
                fsm <= FINISH;
       end
       FINISH: begin
           busy_o <= 1;
           data_o <= sc_out[127:0];
           fsm <=  RESET;
       end
       default: fsm <= RESET;
    endcase
end
