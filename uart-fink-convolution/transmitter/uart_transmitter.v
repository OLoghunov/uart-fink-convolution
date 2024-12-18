module transmitter(
    input wire clk,
    input wire rst,
    input wire start,
    input wire msg_select,  // Switch to select message type (0: input_message, 1: coded_message) switch #1
    input wire baud_select, // Switch to select baud rate (0: 1200, 1: 2400) switch #2
    input wire [MSG_SIZE-1:0] input_message, // Input message to transmit switch #3-8
    output reg tx // UART transmission line
);
    parameter BAUD_RATE_2400 = 2400;      // UART baud rate 
    parameter BAUD_RATE_1200 = 1200; 
    parameter CLK_FREQ = 27000000;       // Clock frequency
    
    reg [31:0] ticks_per_bit;
    localparam COOLDOWN_TICKS = CLK_FREQ; // 1-second cooldown (based on clock frequency)

    parameter MSG_SIZE = 6;
    parameter STEP = 0;                  // Used in coding logic
    localparam CODED_MSG_SIZE = 2 * (MSG_SIZE + 2 * (2 * STEP + 1));

    // State machine states
    localparam IDLE = 2'b00;
    localparam TRANSMIT_START = 2'b01;
    localparam TRANSMIT_DATA = 2'b10;

    integer bit_index;
    reg [31:0] bit_counter;                  // Counter for baud rate timing
    reg [31:0] cooldown_counter;        // Counter for start cooldown
    reg cooldown_active;                    // Cooldown active flag
    reg [1:0] state;                    
//    reg [MSG_SIZE-1:0] input_message;   // Input message to transmit
    wire [CODED_MSG_SIZE-1:0] coded_message; // Encoded message

    encode uut(
        .msg_in(~input_message),
        .msg_out(coded_message)
    );

    initial begin
        tx = 1; // Idle state for UART line is high
        state = IDLE;
        bit_index = 0;
        bit_counter = 0;
        cooldown_counter = 0;
        cooldown_active = 0;
        ticks_per_bit = CLK_FREQ / BAUD_RATE_2400; // Default to 2400 baud
    end

    // Main state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1;
            state <= IDLE;
            bit_index <= 0;
            bit_counter <= 0;
            cooldown_counter <= 0;
            cooldown_active <= 0;
            ticks_per_bit <= CLK_FREQ / BAUD_RATE_2400; // Reset to 2400 baud
        end else begin
            if (baud_select)
                ticks_per_bit <= CLK_FREQ / BAUD_RATE_2400;
            else
                ticks_per_bit <= CLK_FREQ / BAUD_RATE_1200;

            if (cooldown_active) begin
                if (cooldown_counter == COOLDOWN_TICKS - 1) begin
                    cooldown_active <= 0; // Cooldown finished
                    cooldown_counter <= 0;
                end else begin
                    cooldown_counter <= cooldown_counter + 1;
                end
            end

            case (state)
                IDLE: begin
                    tx <= 1; // Keep line high during idle
                    if (start && !cooldown_active) begin
                        bit_index <= 0;
                        bit_counter <= 0;
                        cooldown_active <= 1; // Start cooldown
                        cooldown_counter <= 0;
                        state <= TRANSMIT_START;
                    end
                end

                TRANSMIT_START: begin
                    if (bit_counter == ticks_per_bit - 1) begin
                        tx <= 0; // Start bit is low
                        bit_counter <= 0;
                        state <= TRANSMIT_DATA;
                    end else begin
                        bit_counter <= bit_counter + 1;
                    end
                end

                TRANSMIT_DATA: begin
                    if (bit_counter == ticks_per_bit - 1) begin
                        if (msg_select)
                            tx <= coded_message[bit_index]; // Transmit coded_message
                        else
                            tx <= ~input_message[bit_index]; // Transmit input_message

                        bit_counter <= 0;
                        bit_index <= bit_index + 1;

                        if ((msg_select && bit_index == CODED_MSG_SIZE) ||
                            (!msg_select && bit_index == MSG_SIZE)) begin
                            // All bits transmitted, go to idle
                            bit_index <= 0;
                            state <= IDLE;
                        end
                    end else begin
                        bit_counter <= bit_counter + 1;
                    end
                end

                default: state <= IDLE; // Default to IDLE state
            endcase
        end
    end
endmodule
