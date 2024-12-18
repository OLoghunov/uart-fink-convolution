`timescale 1ns / 1ns

module uart_receiver_tb();

    reg clk;
    reg tx;
    wire [MSG_SIZE-1:0] output_message;

    localparam STEP = 0;
    localparam MSG_SIZE = 6;
    localparam CODED_MSG_SIZE = 2*(MSG_SIZE+2*(2*STEP + 1));

    reg [CODED_MSG_SIZE-1:0] input_msg = 16'b0011101110001110;

    receiver receiver_inst (
        .clk(clk),
        .tx(tx),
        .output_message(output_message)
    );
    
    initial forever #(5) clk = !clk;

    initial #5000000 $finish;

    initial begin
        clk <= 0;

        // Сигнал о начале передачи
        tx = 0;
        #30000;

        // Основной процесс передачи данных через tx
        for (integer i = 0; i < CODED_MSG_SIZE; i = i + 1) begin
            tx = input_msg[i];
            #30000;
        end

        tx = 1; // Завершающий сигнал
    end

    initial begin
        $dumpfile("uart_receiver_out.vcd");
        $dumpvars(0, uart_receiver_tb);
    end

endmodule