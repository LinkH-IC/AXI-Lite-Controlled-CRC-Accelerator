`timescale 1ns / 1ps

module axi_crc_top #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input   ACLK,
    input   ARESETn,

    //Write_addr
    input                           s_awvalid,
    input   [ADDR_WIDTH-1:0]        s_awaddr,
    output  reg                     s_awready,

    //Write_data
    input                           s_wvalid,
    input   [DATA_WIDTH-1:0]        s_wdata,
    output  reg                     s_wready,

    //Write_response
    output  reg [1:0]               s_bresp,
    output  reg                     s_bvalid,
    input                           s_bready,

    //Read_addr
    input                           s_arvalid,
    input   [ADDR_WIDTH-1:0]        s_araddr,
    output  reg                     s_arready,

    //Read_data
    output  reg                     s_rvalid,
    output  reg [DATA_WIDTH-1:0]    s_rdata,
    output  reg [1:0]               s_rresp,
    input                           s_rready
);

    wire    [DATA_WIDTH-1:0]    crc_initial;
    wire    [DATA_WIDTH-1:0]    crc_data;
    wire    [DATA_WIDTH-1:0]    crc_result;

    axi_lite_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) Slave0 (
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
        .s_rready(s_rready),

        .crc_initial(crc_initial),
        .crc_data(crc_data),
        .crc_result(crc_result)
    );

    crc_engine #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) CRC(
        .crcIn(crc_initial),
        .data_in(crc_data),

        .crc_out(crc_result)
    );
    
endmodule