`timescale 1ns/1ps

// 802.3 36.2.4.5: make one code group, track rd like stream has memory
module pcs_8b10b_encode (
    input  logic [7:0] din,
    input  logic       kin,
    input  logic       rd_in,
    output logic [9:0] code,
    output logic       rd_out
);

    logic [5:0] code6;
    logic [3:0] code4;
    logic       rd6;

    // 802.3 table 36-1: 5b to 6b table, plus rd after six bits
    function automatic logic [6:0] enc_5b6b(input logic [4:0] lo5, input logic rd_in);
        begin
            enc_5b6b = 7'b110_0111;
            unique case ({rd_in, lo5})
                6'b00_0000: enc_5b6b = 7'b110_0111;
                6'b00_0001: enc_5b6b = 7'b101_1101;
                6'b00_0010: enc_5b6b = 7'b110_1101;
                6'b00_0011: enc_5b6b = 7'b011_0001;
                6'b00_0100: enc_5b6b = 7'b111_0101;
                6'b00_0101: enc_5b6b = 7'b010_1001;
                6'b00_0110: enc_5b6b = 7'b001_1001;
                6'b00_0111: enc_5b6b = 7'b011_1000;
                6'b00_1000: enc_5b6b = 7'b111_1001;
                6'b00_1001: enc_5b6b = 7'b010_0101;
                6'b00_1010: enc_5b6b = 7'b001_0101;
                6'b00_1011: enc_5b6b = 7'b011_0100;
                6'b00_1100: enc_5b6b = 7'b000_1101;
                6'b00_1101: enc_5b6b = 7'b010_1100;
                6'b00_1110: enc_5b6b = 7'b001_1100;
                6'b00_1111: enc_5b6b = 7'b101_0111;
                6'b01_0000: enc_5b6b = 7'b101_1011;
                6'b01_0001: enc_5b6b = 7'b010_0011;
                6'b01_0010: enc_5b6b = 7'b001_0011;
                6'b01_0011: enc_5b6b = 7'b011_0010;
                6'b01_0100: enc_5b6b = 7'b000_1011;
                6'b01_0101: enc_5b6b = 7'b010_1010;
                6'b01_0110: enc_5b6b = 7'b001_1010;
                6'b01_0111: enc_5b6b = 7'b111_1010;
                6'b01_1000: enc_5b6b = 7'b111_0011;
                6'b01_1001: enc_5b6b = 7'b010_0110;
                6'b01_1010: enc_5b6b = 7'b001_0110;
                6'b01_1011: enc_5b6b = 7'b111_0110;
                6'b01_1100: enc_5b6b = 7'b000_1110;
                6'b01_1101: enc_5b6b = 7'b110_1110;
                6'b01_1110: enc_5b6b = 7'b101_1110;
                6'b01_1111: enc_5b6b = 7'b110_1011;
                6'b10_0000: enc_5b6b = 7'b001_1000;
                6'b10_0001: enc_5b6b = 7'b010_0010;
                6'b10_0010: enc_5b6b = 7'b001_0010;
                6'b10_0011: enc_5b6b = 7'b111_0001;
                6'b10_0100: enc_5b6b = 7'b000_1010;
                6'b10_0101: enc_5b6b = 7'b110_1001;
                6'b10_0110: enc_5b6b = 7'b101_1001;
                6'b10_0111: enc_5b6b = 7'b100_0111;
                6'b10_1000: enc_5b6b = 7'b000_0110;
                6'b10_1001: enc_5b6b = 7'b110_0101;
                6'b10_1010: enc_5b6b = 7'b101_0101;
                6'b10_1011: enc_5b6b = 7'b111_0100;
                6'b10_1100: enc_5b6b = 7'b100_1101;
                6'b10_1101: enc_5b6b = 7'b110_1100;
                6'b10_1110: enc_5b6b = 7'b101_1100;
                6'b10_1111: enc_5b6b = 7'b010_1000;
                6'b11_0000: enc_5b6b = 7'b010_0100;
                6'b11_0001: enc_5b6b = 7'b110_0011;
                6'b11_0010: enc_5b6b = 7'b101_0011;
                6'b11_0011: enc_5b6b = 7'b111_0010;
                6'b11_0100: enc_5b6b = 7'b100_1011;
                6'b11_0101: enc_5b6b = 7'b110_1010;
                6'b11_0110: enc_5b6b = 7'b101_1010;
                6'b11_0111: enc_5b6b = 7'b000_0101;
                6'b11_1000: enc_5b6b = 7'b000_1100;
                6'b11_1001: enc_5b6b = 7'b110_0110;
                6'b11_1010: enc_5b6b = 7'b101_0110;
                6'b11_1011: enc_5b6b = 7'b000_1001;
                6'b11_1100: enc_5b6b = 7'b100_1110;
                6'b11_1101: enc_5b6b = 7'b001_0001;
                6'b11_1110: enc_5b6b = 7'b010_0001;
                6'b11_1111: enc_5b6b = 7'b001_0100;
            endcase
        end
    endfunction

    // 802.3 table 36-1: 3b to 4b table, use rd from the six bit half
    function automatic logic [4:0] enc_3b4b(
        input logic [2:0] hi3,
        input logic [4:0] lo5,
        input logic       rd_in
    );
        begin
            enc_3b4b = 5'b1_1011;
            unique case ({rd_in, hi3})
                4'b0000: enc_3b4b = 5'b1_1011;
                4'b1000: enc_3b4b = 5'b0_0100;
                4'b0001: enc_3b4b = 5'b0_1001;
                4'b1001: enc_3b4b = 5'b1_1001;
                4'b0010: enc_3b4b = 5'b0_0101;
                4'b1010: enc_3b4b = 5'b1_0101;
                4'b0011: enc_3b4b = 5'b0_1100;
                4'b1011: enc_3b4b = 5'b1_0011;
                4'b0100: enc_3b4b = 5'b1_1101;
                4'b1100: enc_3b4b = 5'b0_0010;
                4'b0101: enc_3b4b = 5'b0_1010;
                4'b1101: enc_3b4b = 5'b1_1010;
                4'b0110: enc_3b4b = 5'b0_0110;
                4'b1110: enc_3b4b = 5'b1_0110;
                4'b0111: enc_3b4b = ((lo5 == 5'd17) || (lo5 == 5'd18) || (lo5 == 5'd20)) ? 5'b1_0111 : 5'b1_1110;
                4'b1111: enc_3b4b = ((lo5 == 5'd11) || (lo5 == 5'd13) || (lo5 == 5'd14)) ? 5'b0_1000 : 5'b0_0001;
            endcase
        end
    endfunction

    // 802.3 table 36-2: k code table, only project k symbols go here
    always_comb begin
        code6 = 6'b00_1111;
        code4 = 4'b1010;
        rd6   = rd_in;
        rd_out = rd_in;

        if (kin) begin
            unique case ({rd_in, din})
                9'b0_1011_1100:  begin code = 10'b00_1111_1010; rd_out = 1'b1; end
                9'b1_1011_1100:  begin code = 10'b11_0000_0101; rd_out = 1'b0; end
                9'b0_1111_1011:  begin code = 10'b11_0110_1000; rd_out = 1'b0; end
                9'b1_1111_1011:  begin code = 10'b00_1001_0111; rd_out = 1'b1; end
                9'b0_1111_1101:  begin code = 10'b10_1110_1000; rd_out = 1'b0; end
                9'b1_1111_1101:  begin code = 10'b01_0001_0111; rd_out = 1'b1; end
                9'b0_1111_0111:  begin code = 10'b11_1010_1000; rd_out = 1'b0; end
                9'b1_1111_0111:  begin code = 10'b00_0101_0111; rd_out = 1'b1; end
                default:        begin code = 10'b00_1111_1010; rd_out = 1'b1; end
            endcase
        end else begin
            {rd6, code6} = enc_5b6b(din[4:0], rd_in);
            {rd_out, code4} = enc_3b4b(din[7:5], din[4:0], rd6);
            code = {code6, code4};
        end
    end

endmodule

// class top, din plus tx_en in, encoded dout out
module E1000X (
    input  logic       Clk,
    input  logic       Reset,
    input  logic       TX_EN,
    input  logic [7:0] Din,
    output logic [9:0] Dout
);

    localparam logic [7:0] K28_5 = 8'hBC;
    localparam logic [7:0] K27_7 = 8'hFB;
    localparam logic [7:0] K29_7 = 8'hFD;
    localparam logic [7:0] K23_7 = 8'hF7;
    localparam logic [7:0] D16_2 = 8'h50;
    localparam logic [7:0] D05_6 = 8'hC5;
    localparam logic [9:0] IDLE_WORD = 10'b01_0111_1100;

    typedef enum logic [2:0] {
        IDLE_K,
        IDLE_D,
        START_K,
        DATA_D,
        TERM_K,
        EXT_K
    } send_t;

    send_t      state,      next_state;
    logic [7:0] tx_byte,    next_tx_byte;
    logic       tx_is_k,    next_tx_is_k;
    logic       rd,         rd_next;

    logic [7:0] fifo_mem [0:7];
    logic [2:0] wr_ptr, rd_ptr;
    logic [3:0] fifo_count;

    logic [9:0] code;

    logic       take_data;
    logic       fifo_pop, fifo_push;
    logic       has_data;
    logic [7:0] queued_byte;
    logic [9:0] tx_word;

    // 802.3 36.2.4.4
    pcs_8b10b_encode u_encoder (
        .din    (tx_byte),
        .kin    (tx_is_k),
        .rd_in  (rd),
        .code   (code),
        .rd_out (rd_next)
    );

    // 802.3 36.2.4.19
    assign tx_word = {code[0], code[1], code[2], code[3], code[4], code[5], code[6], code[7], code[8], code[9]};

    // 802.3 36.2.5.2.1: pick next ordered set from tx_en and fifo state
    always_comb begin
        has_data   = (fifo_count != 4'd0) || TX_EN;
        queued_byte = (fifo_count != 4'd0) ? fifo_mem[rd_ptr] : Din;

        next_state    = IDLE_K;
        next_tx_byte  = K28_5;
        next_tx_is_k  = 1'b1;
        take_data     = 1'b0;

        unique case (state)
            // 802.3 36.2.4.12: idle starts with k28.5
            IDLE_K: begin
                next_state    = IDLE_D;
                next_tx_byte  = rd_next ? D16_2 : D05_6;
                next_tx_is_k  = 1'b0;
            end

            // 802.3 36.2.4.12: idle second code is d5.6 or d16.2
            IDLE_D: begin
                if (has_data) begin
                    next_state    = START_K;
                    next_tx_byte  = K27_7;
                    next_tx_is_k  = 1'b1;
                end else begin
                    next_state    = IDLE_K;
                    next_tx_byte  = K28_5;
                    next_tx_is_k  = 1'b1;
                end
            end

            // 802.3 36.2.4.14: start packet is s, aka k27.7
            START_K: begin
                if (has_data) begin
                    next_state    = DATA_D;
                    next_tx_byte  = queued_byte;
                    next_tx_is_k  = 1'b0;
                    take_data     = 1'b1;
                end else begin
                    next_state    = START_K;
                    next_tx_byte  = K27_7;
                    next_tx_is_k  = 1'b1;
                end
            end

            // 802.3 36.2.4.11: data code groups are plain gmii bytes
            DATA_D: begin
                if (has_data) begin
                    next_state    = DATA_D;
                    next_tx_byte  = queued_byte;
                    next_tx_is_k  = 1'b0;
                    take_data     = 1'b1;
                end else begin
                    next_state    = TERM_K;
                    next_tx_byte  = K29_7;
                    next_tx_is_k  = 1'b1;
                end
            end

            // 802.3 36.2.4.15: end packet starts with t, aka k29.7
            TERM_K: begin
                if (has_data) begin
                    next_state    = EXT_K;
                    next_tx_byte  = K23_7;
                    next_tx_is_k  = 1'b1;
                end else begin
                    next_state    = IDLE_K;
                    next_tx_byte  = K28_5;
                    next_tx_is_k  = 1'b1;
                end
            end

            // 802.3 36.2.4.16: r gives carrier extend and packet gap help
            EXT_K: begin
                if (has_data) begin
                    next_state    = START_K;
                    next_tx_byte  = K27_7;
                    next_tx_is_k  = 1'b1;
                end else begin
                    next_state    = IDLE_K;
                    next_tx_byte  = K28_5;
                    next_tx_is_k  = 1'b1;
                end
            end

            default: begin
                next_state    = IDLE_K;
                next_tx_byte  = K28_5;
                next_tx_is_k  = 1'b1;
            end
        endcase

        fifo_pop  = take_data && (fifo_count != 4'd0);
        fifo_push = TX_EN && !(take_data && (fifo_count == 4'd0)) && ((fifo_count != 4'd8) || fifo_pop);
    end

    // 802.3 36.2.4.2: one code group per clock, reg'd for gate timing
    always_ff @(posedge Clk) begin
        if (Reset) begin
            Dout        <= IDLE_WORD;
            rd          <= 1'b1;
            state       <= IDLE_D;
            tx_byte     <= D16_2;
            tx_is_k     <= 1'b0;
            wr_ptr      <= 3'd0;
            rd_ptr      <= 3'd0;
            fifo_count  <= 4'd0;
            for (int i = 0; i < 8; i++) fifo_mem[i] <= 8'h00;
        end else begin
            Dout        <= tx_word;
            rd          <= rd_next;
            state       <= next_state;
            tx_byte     <= next_tx_byte;
            tx_is_k     <= next_tx_is_k;

            if (fifo_push) begin
                fifo_mem[wr_ptr] <= Din;
                wr_ptr <= wr_ptr + 3'd1;
            end

            if (fifo_pop) rd_ptr <= rd_ptr + 3'd1;

            unique case ({fifo_push, fifo_pop})
                2'b10:      fifo_count <= fifo_count + 4'd1;
                2'b01:      fifo_count <= fifo_count - 4'd1;
                default:    fifo_count <= fifo_count;
            endcase
        end
    end

endmodule
