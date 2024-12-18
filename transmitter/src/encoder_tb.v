`timescale 1ns / 1ns

module encoder_tb();

reg [13:0] msg_in;
wire [31:0] msg_out;

encode uut(
    .msg_in(msg_in), 
    .msg_out(msg_out)
);

initial begin
    msg_in = 14'b11010011101001; 
    #100;

    msg_in = 14'b11010011101001;
    #100;

    msg_in = 14'b11010011101001;
    #100;
end

initial #500 $finish; 

initial begin
    $dumpfile("./encoder_out.vcd"); 
    $dumpvars(0, encoder_tb);
end

endmodule