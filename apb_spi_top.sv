// apb_spi_top.sv - AMBA APB Memory-Mapped SPI Peripheral Controller Wrapper
module apb_spi_top #(
    parameter DATA_WIDTH = 8
)(
    // AMBA APB Bus Interface
    input  logic        pclk,
    input  logic        presetn,
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [3:0]  paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,
    
    // External SPI Physical Pins
    output logic        sclk,
    output logic        mosi,
    input  logic        miso,
    output logic        cs_n
);

    // Memory-Mapped Control & Status Registers
    // 0x0: Control Register [1: start_tx, 0: enable]
    // 0x4: TX Data Register [7:0: tx_data]
    // 0x8: Status Register  [1: tx_done, 0: busy] (Read-Only)
    
    logic        enable_reg;
    logic        start_tx_reg;
    logic [7:0]  tx_data_reg;
    logic        busy_stat;
    logic        tx_done_stat;

    assign pready = 1'b1; // Zero-wait-state APB transfer

    // APB Write Register Logic
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            enable_reg   <= 1'b0;
            start_tx_reg <= 1'b0;
            tx_data_reg  <= 8'h0;
        end else begin
            start_tx_reg <= 1'b0; // Self-clearing pulse
            if (psel && penable && pwrite) begin
                case (paddr)
                    4'h0: begin
                        enable_reg   <= pwdata[0];
                        start_tx_reg <= pwdata[1];
                    end
                    4'h4: begin
                        tx_data_reg  <= pwdata[7:0];
                    end
                endcase
            end
        end
    end

    // APB Read Register Logic
    always_comb begin
        prdata = 32'h0;
        if (psel && !pwrite) begin
            case (paddr)
                4'h0: prdata = {30'h0, start_tx_reg, enable_reg};
                4'h4: prdata = {24'h0, tx_data_reg};
                4'h8: prdata = {30'h0, tx_done_stat, busy_stat};
                default: prdata = 32'h0;
            endcase
        end
    end

    // Instantiate Under-Test Core
    spi_uart_ip #(
        .DATA_WIDTH(DATA_WIDTH)
    ) core_inst (
        .clk     (pclk),
        .rst_n   (presetn),
        .enable  (enable_reg),
        .start_tx(start_tx_reg),
        .tx_data (tx_data_reg),
        .sclk    (sclk),
        .mosi    (mosi),
        .miso    (miso),
        .cs_n    (cs_n),
        .busy    (busy_stat),
        .tx_done (tx_done_stat)
    );

endmodule
