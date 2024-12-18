module encode(
    input [MSG_SIZE-1:0] msg_in,
    output reg [2*(MSG_SIZE+2*(2*STEP + 1))-1:0] msg_out
);
    localparam STEP = 0;
    localparam MSG_SIZE = 6;
    localparam CODED_MSG_SIZE = 2*(MSG_SIZE+2*(2*STEP + 1));
    integer i;
    reg [MSG_SIZE+2-1:0] msg;

    always @(*) begin
        // Добавляем нули в начало и конец
        msg = { {(2*STEP+1){1'b0}}, msg_in, {(2*STEP+1){1'b0}} };

        for (i = 0; i < MSG_SIZE+2; i = i + 1) begin
            msg_out[2*i] = msg[i];
            if (STEP <= i && i < MSG_SIZE+2 - STEP - 1) begin
                msg_out[2*i+1] = msg[i-STEP] ^ msg[i+STEP+1];
            end else begin
                msg_out[2*i+1] = 1'b0;
            end
        end
    end
endmodule