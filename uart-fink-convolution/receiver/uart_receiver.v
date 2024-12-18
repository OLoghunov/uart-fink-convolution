module receiver(
    input wire clk,
    input wire tx,
    input wire msg_select,   // Message type selector: 0 = uncoded, 1 = coded switch #1
    input wire baud_select,  // Baud rate selector: 0 = 1200, 1 = 2400 switch #2
    output reg [MSG_SIZE-1:0] output_message
);
    parameter BAUD_RATE_2400 = 2400;
    parameter BAUD_RATE_1200 = 1200;
    parameter CLK_FREQ = 27000000;

    localparam STEP = 0;
    localparam MSG_SIZE = 6;
    localparam CODED_MSG_SIZE = 2 * (MSG_SIZE + 2 * (2 * STEP + 1));

    integer bit_index;
    reg [31:0] bit_counter;
    reg [31:0] ticks_per_bit;
    reg [1:0] state = IDLE;

    reg [MSG_SIZE-1:0] uncoded_message;      // Storage for uncoded message
    reg [CODED_MSG_SIZE-1:0] coded_message;  // Storage for coded message

    localparam IDLE = 2'b00;
    localparam RECEIVE_START = 2'b01;
    localparam RECEIVE_DATA = 2'b10;
    localparam RECEIVE_STOP = 2'b11;

    // Decode module
    wire [MSG_SIZE-1:0] decoded_message;
    decode uut(
        .msg_in(coded_message),
        .msg_out(decoded_message)
    );

    // Adjust baud rate dynamically based on baud_select
    always @(posedge clk) begin
        if (baud_select)
            ticks_per_bit <= CLK_FREQ / BAUD_RATE_2400;  // 2400 baud
        else
            ticks_per_bit <= CLK_FREQ / BAUD_RATE_1200;  // 1200 baud
    end

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                if (!tx) begin
                    bit_counter <= ticks_per_bit / 2; // Half bit period for synchronization
                    bit_index <= 0;
                    state <= RECEIVE_START;
                end
            end
            RECEIVE_START: begin
                if (bit_counter == ticks_per_bit - 1) begin
                    bit_counter <= 0;
                    state <= RECEIVE_DATA;
                end else begin
                    bit_counter <= bit_counter + 1;
                end
            end
            RECEIVE_DATA: begin
                if (bit_counter == ticks_per_bit - 1) begin
                    bit_counter <= 0;

                    if (msg_select) begin
                        // Receiving coded message
                        coded_message[bit_index] <= tx;
                    end else begin
                        // Receiving uncoded message
                        uncoded_message[bit_index] <= tx;
                    end

                    bit_index <= bit_index + 1;

                    if ((msg_select && bit_index == CODED_MSG_SIZE - 1) || 
                        (!msg_select && bit_index == MSG_SIZE - 1)) begin
                        bit_index <= 0;
                        state <= RECEIVE_STOP;
                    end
                end else begin
                    bit_counter <= bit_counter + 1;
                end
            end
            RECEIVE_STOP: begin
                if (bit_counter == ticks_per_bit - 1) begin
                    bit_counter <= 0;
                    state <= IDLE;

                    // Update output_message
                    if (msg_select) begin
                        output_message <= ~decoded_message; // Use decoded message
                    end else begin
                        output_message <= ~uncoded_message; // Directly use uncoded message
                    end
                end else begin
                    bit_counter <= bit_counter + 1;
                end
            end
        endcase
    end
endmodule
