module tb_apb_spi;

    logic        pclk;
    logic        presetn;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [3:0]  paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;
    
    logic        sclk;
    logic        mosi;
    logic        miso;
    logic        cs_n;

    // Instantiate Top Module
    apb_spi_top dut (.*);

    // Clock Generation
    always #10 pclk = ~pclk;

    // APB Task: Write Transaction
    task apb_write(input [3:0] addr, input [31:0] data);
        @(posedge pclk);
        psel    <= 1'b1;
        pwrite  <= 1'b1;
        paddr   <= addr;
        pwdata  <= data;
        @(posedge pclk);
        penable <= 1'b1;
        @(posedge pclk);
        psel    <= 1'b0;
        penable <= 1'b0;
    endtask

    initial begin
        $dumpfile("apb_spi_trace.vcd");
        $dumpvars(0, tb_apb_spi);

        pclk    = 0;
        presetn = 0;
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 0;
        pwdata  = 0;
        miso    = 0;

        #40 presetn = 1;

        $display("\n=== STARTING AMBA APB SPI CONTROLLER SIMULATION ===");

        // Step 1: Enable Peripheral Domain via APB Write to 0x0
        apb_write(4'h0, 32'h1);
        $display("[APB WRITE] Peripheral Clock Domain Enabled (Addr: 0x0, Data: 0x1)");

        // Step 2: Load Data Payload 0x3C into TX Register via APB Write to 0x4
        apb_write(4'h4, 32'h3C);
        $display("[APB WRITE] Loaded Payload 0x3C into TX Buffer (Addr: 0x4)");

        // Step 3: Trigger Transmission via APB Write to 0x0 (Bit 1 = Start)
        apb_write(4'h0, 32'h3);
        $display("[APB WRITE] Triggered Transmission Sequence (Addr: 0x0, Data: 0x3)");

        #500;
        $display("\n=== [SUCCESS] AMBA APB SPI CONTROLLER SIMULATION COMPLETED ===\n");
        $finish;
    end

endmodule
