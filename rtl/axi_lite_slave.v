`timescale 1ns / 1ps

module axi_lite_slave #(
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
    input                           s_rready,

    //CRC_sig
    output  [DATA_WIDTH-1:0]        crc_initial,
    output  [DATA_WIDTH-1:0]        crc_data,
    input   [DATA_WIDTH-1:0]        crc_result
);    
    
    //Register Map
    parameter   CRC_Initial = 8'h00,
                CRC_Data    = 8'h04,
                CRC_Result  = 8'h08;


    //Write Addr & Data
    reg aw_receive;
    reg w_receive;
    reg [ADDR_WIDTH-1:0]    reg_waddr;
    reg [DATA_WIDTH-1:0]    reg_crc_data;
    reg [DATA_WIDTH-1:0]    reg_crc_initial;

    assign crc_initial = reg_crc_initial;
    assign crc_data = reg_crc_data;

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            s_awready   <= 0;
            s_wready    <= 0;
            reg_waddr   <= 0;
            aw_receive  <= 0;
            w_receive   <= 0;
        end
        else if (s_awaddr == 8'h08) begin
            s_awready <= 0;
        end
        else begin
            // Address handshake
            if (s_awvalid && !s_awready) begin
                s_awready   <= 1'b1;
                reg_waddr   <= s_awaddr;
            end
            else begin
                s_awready <= 0;
            end

            if(s_awvalid && s_awready)
                aw_receive  <= 1'b1;
            else if(aw_receive && w_receive)
                aw_receive  <= 1'b0;
            else
                aw_receive  <= aw_receive;

            // Data handshake
            if (s_wvalid && !s_wready) begin
                s_wready        <= 1'b1;
                case (s_awaddr)
                    CRC_Initial:  reg_crc_initial <= s_wdata;
                    CRC_Data:  reg_crc_data <= s_wdata;
                    default: begin reg_crc_data <= 32'hFFFF_FFFF; reg_crc_initial <= 32'hFFFF_FFFF; end
                endcase
            end
            else begin
                s_wready <= 0;
            end

            if(s_wvalid && s_wready)
                w_receive  <= 1'b1;
            else if(aw_receive && w_receive)
                w_receive  <= 1'b0;
            else
                w_receive  <= w_receive;
        end            
    end

    //CRC Enable Pulse
    reg crc_en;

    always @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn)
        crc_en <= 0;
    else if (reg_waddr == 8'h04)
        crc_en <= aw_receive && w_receive;
    else
        crc_en <= 0;
    end   

    //Write Response
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            s_bvalid <= 0;
            s_bresp  <= 2'b00; // OKAY
        end
        else if (aw_receive || w_receive) begin
            case (reg_waddr)
                CRC_Initial: begin s_bvalid <= 1'b1; s_bresp <= 2'b00; end // OKAY
                CRC_Data: begin s_bvalid <= 1'b1; s_bresp <= 2'b00; end // OKAY
                default: begin s_bvalid <= 1'b1; s_bresp <= 2'b10; end //SLVERR
            endcase
        end
        else if (s_bready) begin
            s_bvalid <= 0;
        end
    end

    //CRC Status & Result
    reg [DATA_WIDTH-1:0]    reg_crc_result;

    always @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) 
            reg_crc_result  <= 0;
        else if (crc_en) 
            reg_crc_result  <= crc_result;
        else 
            reg_crc_result  <= reg_crc_result;
    end

    //Read Addr
    reg [ADDR_WIDTH-1:0]    reg_raddr;
    reg                     re_en;

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            s_arready   <= 0;
            reg_raddr   <= 0;
        end
        else
            if (s_arvalid && !s_arready) begin
                s_arready   <= 1'b1;
                reg_raddr   <= s_araddr;
                re_en       <= 1'b1;
            end
            else begin
                s_arready <= 0;
                re_en     <= 0;
            end
    end

    //Read Data
    
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            s_rvalid        <= 0;
            s_rresp         <= 2'b00;
            reg_crc_result  <= 32'h0000_0000;
        end
        else begin
            if (re_en) begin
                case (reg_raddr)
                    CRC_Initial: begin s_rvalid <= 1'b1; s_rdata  <= reg_crc_initial; s_rresp  <= 2'b00; end //OKAY
                    CRC_Data: begin s_rvalid <= 1'b1; s_rdata  <= reg_crc_data; s_rresp  <= 2'b00; end //OKAY
                    CRC_Result: begin s_rvalid <= 1'b1; s_rdata  <= reg_crc_result; s_rresp  <= 2'b00; end //OKAY
                    default: begin s_rvalid <= 1'b1; s_rdata  <= 32'h0000_0000; s_rresp  <= 2'b10; end //SLVERR
                endcase
            end
            else if (s_rready) begin
                s_rvalid <= 0;
            end
        end
    end

endmodule
