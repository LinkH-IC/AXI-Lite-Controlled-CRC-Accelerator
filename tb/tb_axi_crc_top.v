`timescale 1ns/1ps

module tb_axi_crc_top;

    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 32;

    reg ACLK;
    reg ARESETn;

    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK;
    end

    initial begin
        ARESETn = 0;

        #20 ARESETn = 1;
    end

    //Write_addr
    reg                     s_awvalid;
    reg   [ADDR_WIDTH-1:0]  s_awaddr;
    wire                    s_awready;

    //Write_data
    reg                     s_wvalid;
    reg   [DATA_WIDTH-1:0]  s_wdata;
    wire                    s_wready;

    //Write_response
    wire [1:0]              s_bresp;
    wire                    s_bvalid;
    reg                     s_bready;

    //Read_addr
    reg                     s_arvalid;
    reg   [ADDR_WIDTH-1:0]  s_araddr;
    wire                    s_arready;

    //Read_data
    wire                    s_rvalid;
    wire [DATA_WIDTH-1:0]   s_rdata;
    wire [1:0]              s_rresp;
    reg                     s_rready;

    axi_crc_top dut(
        .ACLK(ACLK),
        .ARESETn(ARESETn),

        .s_awvalid(s_awvalid),
        .s_awaddr(s_awaddr),
        .s_awready(s_awready),

        .s_wvalid(s_wvalid),
        .s_wdata(s_wdata),
        .s_wready(s_wready),

        .s_bresp(s_bresp),
        .s_bvalid(s_bvalid),
        .s_bready(s_bready),

        .s_arvalid(s_arvalid),
        .s_araddr(s_araddr),
        .s_arready(s_arready),

        .s_rvalid(s_rvalid),
        .s_rdata(s_rdata),
        .s_rresp(s_rresp),
        .s_rready(s_rready)
    );

    task axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);

    begin
        @(posedge ACLK)

        s_awaddr    <= addr;
        s_awvalid   <= 1;
        s_wdata     <= data;
        s_wvalid    <= 1;
        s_bready    <= 1;

        wait (s_awready && s_wready); //Wait handshake

        @(posedge ACLK)
        s_awvalid   <= 0;
        s_wvalid    <= 0;

        //Wait response
        wait (s_bvalid);

        s_bready    <= 0;
    end

    endtask

    task axi_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);

    begin
        @(posedge ACLK)

        s_araddr    <= addr;
        s_arvalid   <= 1;
        s_rready    <= 1;

        wait (s_arready);

        @(posedge ACLK)
        s_arvalid   <= 0;

        wait (s_rvalid)
        data = s_rdata;

        @(posedge ACLK)
        s_rready    <= 0;

    end

    endtask

    reg [DATA_WIDTH-1:0] crc_result;
    reg [DATA_WIDTH-1:0] random_val;

    initial begin

        $dumpfile("axi_crc_top.vcd"); 
        $dumpvars(0, tb_axi_crc_top);

        s_awvalid   = 0;
        s_wvalid    = 0;
        s_arvalid   = 0;
        s_rready    = 0;
        s_bready    = 0;

        wait (ARESETn);

        repeat(5) begin

            random_val = $urandom();
            $display("Random Data = %h", random_val);
            
            axi_write(8'h00, 32'hFFFF_FFFF);
            axi_write(8'h04, random_val);

            axi_read(8'h04, crc_result);
            $display("Read CRC_DATA reg, Read Data = %h", crc_result);
            axi_read(8'h08, crc_result);
            $display("Read CRC_RESULT reg, Read Data = %h", crc_result);
            axi_read(8'h0C, crc_result); //Read SLVERR Test
            $display("Read non-allocated reg, Read Data = %h", crc_result);
            #10;

        end        

        #100;
        $finish;
    end
    
endmodule
