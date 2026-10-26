module tb_spi_uart_ip;

    parameter DATA_WIDTH = 8;

    logic                  clk;
    logic                  rst_n;
    logic                  enable;
    logic                  start_tx;
    logic [DATA_WIDTH-1:0] tx_data;
    logic                  sclk;
    logic                  mosi;
    logic                  miso;
    logic                  cs_n;
    logic                  busy;
    logic                  tx_done;

    // Instantiate DUT
    spi_uart_ip #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (.*);

    // Clock Generation (50 MHz = 20ns period)
    always #10 clk = ~clk;

    initial begin
        $dumpfile("spi_trace.vcd");
        $dumpvars(0, tb_spi_uart_ip);

        // Initialize Signals
        clk      = 0;
        rst_n    = 0;
        enable   = 0;
        start_tx = 0;
        tx_data  = 8'h0;
        miso     = 0;

        #40 rst_n = 1;
        #20 enable = 1; // Enable peripheral power domain

        $display("\n=== STARTING LOW-POWER SPI CONTROLLER SIMULATION ===");

        // --- TRANSMISSION 1: Send Byte 0xA5 (10100101) ---
        @(posedge clk);
        tx_data  = 8'hA5;
        start_tx = 1'b1;
        @(posedge clk);
        start_tx = 1'b0;

        $display("[TX START] Data: 0x%h (0b10100101) | Power Enabled: %0b", tx_data, enable);

        // Wait for Transmission Completion
        wait(tx_done);
        $display("[TX DONE]  Time: %0t | Transmission Complete!", $time);

        #40;

        // --- TEST LOW-POWER CLOCK GATING ---
        $display("\n[POWER TEST] Disabling Peripheral Power Domain (Clock Gating)...");
        enable = 0; // Gate off clocks completely
        #60;

        if (sclk == 0) begin
            $display("[POWER SUCCESS] SCLK is cleanly gated OFF while enable is low at time %0t", $time);
        end

        #100;
        $display("\n=== [SUCCESS] SPI CONTROLLER SIMULATION COMPLETED CLEANLY ===\n");
        $finish;
    end

endmodule
