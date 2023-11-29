reg rst_n = 0;
reg [1:0] counter = 2'b00;
reg enable = 0;
reg [127:0] i_text;
reg [255:0] key;
reg pt_sel, key_sel, ct_out_sel;
reg [127:0] o_text;
wire trigger;
reg done = 0;
wire [386:0]sc_out;
wire [386:0] scan_chain;

parameter CLK_PERIOD = 10;

assign scan_chain = {i_text, key, pt_sel, key_sel, ct_out_sel};
assign o_text = sc_out[127:0];

localparam AES_KEYSCHED = 0;
localparam AES_DECRYPT = 1;

reg [1:0] fsm, fsm_new;



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

always @(posedge clk)

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
    
    if (done == 1'b1)
       begin
         o_text[127:0] <= sc_out[127:0];
         busy_o <= 0;
       end

    end

end


//aes_if DUT(clk, rst_n, scan_chain, enable, trigger, sc_out);

   aes_if DUT (
       .CLK             (clk),
       .RST_N          (rst_n),
       .SCAN_CHAIN      (scan_chain),
       .ENABLE          (enable),
       .TRIGGER_EXT     (trigger),
       .CIPHERTEXT      (sc_out),//enc mode
       .CT_OUT          ()
   );
   
endmodule
