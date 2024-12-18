`timescale 1ns / 1ns

module decoder_tb();

reg [31:0] msg_in;
wire [13:0] msg_out;

decode uut(
    .msg_in(msg_in),  
    .msg_out(msg_out)
);

initial begin
    msg_in = 32'b00110110111000110101101110001110; 
    #100;

    msg_in = 32'b00110110111000110101101110001110; 
    #100;

    msg_in = 32'b00110110111000110101101110001110; 
    #100;
end

initial #500 $finish; 

initial begin
    $dumpfile("./decoder_out.vcd"); 
    $dumpvars(0, decoder_tb);
end

endmodule