module decode(
    input [2*(MSG_SIZE + 2*(2*STEP+1))-1:0] msg_in,
    output reg [MSG_SIZE-1:0] msg_out
);
    localparam STEP = 0;
    localparam MSG_SIZE = 6;
    localparam CODED_MSG_SIZE = 2*(MSG_SIZE+2*(2*STEP + 1));
   
    integer i;
    reg [CODED_MSG_SIZE/2-1:0] a; // Массив для четных индексов
    reg [CODED_MSG_SIZE/2-1:0] b; // Массив для нечетных индексов

    always @(*) begin
        // Разделяем входное сообщение на a и b
        for (i = 0; i < CODED_MSG_SIZE; i = i + 2) begin
            a[i/2] = msg_in[i];
        end
        for (i = 1; i < CODED_MSG_SIZE; i = i + 2) begin
            b[(i-1)/2] = msg_in[i];
        end

        // Корректируем массив a на основе условий
        for (i = 0; i < MSG_SIZE; i = i + 1) begin
            if (i < MSG_SIZE - (4*STEP + 2)) begin
                if ((a[i] ^ a[i+2*STEP+1]) != b[i+STEP] &&
                    (a[i+2*STEP+1] ^ a[i+4*STEP+2]) != b[i+3*STEP+1]) begin
                    a[i+2*STEP+1] = ~a[i+2*STEP+1];
                end
            end
        end

        // Формируем выходное сообщение
        msg_out = a[2*STEP+1+:MSG_SIZE+2*STEP+1];
    end
endmodule