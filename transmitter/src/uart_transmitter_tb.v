`timescale 1ns / 1ns

module uart_transmitter_tb();

    reg clk;
    reg rst;

    reg start;
    wire tx;

    transmitter transmitter_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx(tx)
    );
    
    initial forever #(5) clk = !clk;
    initial #5000000 $finish;

    initial begin
        clk <= 0;
        # 100000
        start = 1;
        rst = 0;
        # 100000
        start = 0;
        #2000000
        start = 1;
        # 100000
        start = 0;
        rst = 1;
    end


initial begin
    $dumpfile("uart_transmitter_out.vcd");
    $dumpvars(0, uart_transmitter_tb);
end

endmodule