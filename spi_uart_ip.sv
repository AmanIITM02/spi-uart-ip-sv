// spi_uart_ip.sv - Low-Power Configurable SPI Peripheral Controller with Clock Gating
module spi_uart_ip #(
    parameter DATA_WIDTH = 8
)(
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Low-Power / Control Logic
    input  logic                  enable,      // Enables dynamic peripheral clock gating
    input  logic                  start_tx,    // Start Transmission Trigger
    input  logic [DATA_WIDTH-1:0] tx_data,     // Data payload to transmit
    
    // SPI Physical Interface
    output logic                  sclk,        // SPI Serial Clock (Gated)
    output logic                  mosi,        // Master Out Slave In
    input  logic                  miso,        // Master In Slave Out
    output logic                  cs_n,        // Chip Select (Active Low)
    
    // Status Flags
    output logic                  busy,
    output logic                  tx_done
);

    // Dynamic Clock Gating Logic
    logic gated_sclk;
    assign gated_sclk = clk & enable & (~cs_n);
    assign sclk       = gated_sclk;

    // Internal FSM States
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        SETUP = 2'b01,
        SHIFT = 2'b10,
        DONE  = 2'b11
    } state_t;

    state_t current_state, next_state;

    logic [2:0]            bit_cnt;
    logic [DATA_WIDTH-1:0] shift_reg;

    // FSM State Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else if (enable) begin
            current_state <= next_state;
        end
    end

    // FSM Next-State & Control Logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (start_tx) next_state = SETUP;
            end
            SETUP: begin
                next_state = SHIFT;
            end
            SHIFT: begin
                if (bit_cnt == DATA_WIDTH - 1)
                    next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Datapath & Output Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs_n      <= 1'b1;
            mosi      <= 1'b0;
            busy      <= 1'b0;
            tx_done   <= 1'b0;
            bit_cnt   <= '0;
            shift_reg <= '0;
        end else if (enable) begin
            case (current_state)
                IDLE: begin
                    cs_n    <= 1'b1;
                    busy    <= 1'b0;
                    tx_done <= 1'b0;
                    bit_cnt <= '0;
                    if (start_tx) begin
                        shift_reg <= tx_data;
                        busy      <= 1'b1;
                    end
                end

                SETUP: begin
                    cs_n    <= 1'b0; // Pull Chip Select LOW
                    mosi    <= shift_reg[DATA_WIDTH-1]; // MSB First
                end

                SHIFT: begin
                    mosi      <= shift_reg[DATA_WIDTH-1];
                    shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
                    bit_cnt   <= bit_cnt + 1'b1;
                end

                DONE: begin
                    cs_n    <= 1'b1; // Deselect Chip Select
                    busy    <= 1'b0;
                    tx_done <= 1'b1;
                end
            endcase
        end
    end

    // Procedural Assertion Check (Evaluated during active bit shifting)
    always_ff @(posedge clk) begin
        if (rst_n && (current_state == SHIFT) && cs_n) begin
            $display("[ASSERTION ERROR] Transmission active while Chip Select is inactive at %0t!", $time);
        end
    end

endmodule
