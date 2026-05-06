`timescale 1ns/1ps

module pcs_8b10b_encode (
    input  logic [7:0] din,
    input  logic       kin,
    input  logic       rd_in,
    output logic [9:0] code,
    output logic       rd_out
);

    logic [5:0] six;
    logic [3:0] four;
    logic       rd_mid;

    function automatic logic [6:0] enc_5b6b(input logic [4:0] x, input logic rd);
        begin
            unique case ({rd, x})
                6'b0_00000: enc_5b6b = 7'b1_100111;
                6'b0_00001: enc_5b6b = 7'b1_011101;
                6'b0_00010: enc_5b6b = 7'b1_101101;
                6'b0_00011: enc_5b6b = 7'b0_110001;
                6'b0_00100: enc_5b6b = 7'b1_110101;
                6'b0_00101: enc_5b6b = 7'b0_101001;
                6'b0_00110: enc_5b6b = 7'b0_011001;
                6'b0_00111: enc_5b6b = 7'b0_111000;
                6'b0_01000: enc_5b6b = 7'b1_111001;
                6'b0_01001: enc_5b6b = 7'b0_100101;
                6'b0_01010: enc_5b6b = 7'b0_010101;
                6'b0_01011: enc_5b6b = 7'b0_110100;
                6'b0_01100: enc_5b6b = 7'b0_001101;
                6'b0_01101: enc_5b6b = 7'b0_101100;
                6'b0_01110: enc_5b6b = 7'b0_011100;
                6'b0_01111: enc_5b6b = 7'b1_010111;
                6'b0_10000: enc_5b6b = 7'b1_011011;
                6'b0_10001: enc_5b6b = 7'b0_100011;
                6'b0_10010: enc_5b6b = 7'b0_010011;
                6'b0_10011: enc_5b6b = 7'b0_110010;
                6'b0_10100: enc_5b6b = 7'b0_001011;
                6'b0_10101: enc_5b6b = 7'b0_101010;
                6'b0_10110: enc_5b6b = 7'b0_011010;
                6'b0_10111: enc_5b6b = 7'b1_111010;
                6'b0_11000: enc_5b6b = 7'b1_110011;
                6'b0_11001: enc_5b6b = 7'b0_100110;
                6'b0_11010: enc_5b6b = 7'b0_010110;
                6'b0_11011: enc_5b6b = 7'b1_110110;
                6'b0_11100: enc_5b6b = 7'b0_001110;
                6'b0_11101: enc_5b6b = 7'b1_101110;
                6'b0_11110: enc_5b6b = 7'b1_011110;
                6'b0_11111: enc_5b6b = 7'b1_101011;
                6'b1_00000: enc_5b6b = 7'b0_011000;
                6'b1_00001: enc_5b6b = 7'b0_100010;
                6'b1_00010: enc_5b6b = 7'b0_010010;
                6'b1_00011: enc_5b6b = 7'b1_110001;
                6'b1_00100: enc_5b6b = 7'b0_001010;
                6'b1_00101: enc_5b6b = 7'b1_101001;
                6'b1_00110: enc_5b6b = 7'b1_011001;
                6'b1_00111: enc_5b6b = 7'b1_000111;
                6'b1_01000: enc_5b6b = 7'b0_000110;
                6'b1_01001: enc_5b6b = 7'b1_100101;
                6'b1_01010: enc_5b6b = 7'b1_010101;
                6'b1_01011: enc_5b6b = 7'b1_110100;
                6'b1_01100: enc_5b6b = 7'b1_001101;
                6'b1_01101: enc_5b6b = 7'b1_101100;
                6'b1_01110: enc_5b6b = 7'b1_011100;
                6'b1_01111: enc_5b6b = 7'b0_101000;
                6'b1_10000: enc_5b6b = 7'b0_100100;
                6'b1_10001: enc_5b6b = 7'b1_100011;
                6'b1_10010: enc_5b6b = 7'b1_010011;
                6'b1_10011: enc_5b6b = 7'b1_110010;
                6'b1_10100: enc_5b6b = 7'b1_001011;
                6'b1_10101: enc_5b6b = 7'b1_101010;
                6'b1_10110: enc_5b6b = 7'b1_011010;
                6'b1_10111: enc_5b6b = 7'b0_000101;
                6'b1_11000: enc_5b6b = 7'b0_001100;
                6'b1_11001: enc_5b6b = 7'b1_100110;
                6'b1_11010: enc_5b6b = 7'b1_010110;
                6'b1_11011: enc_5b6b = 7'b0_001001;
                6'b1_11100: enc_5b6b = 7'b1_001110;
                6'b1_11101: enc_5b6b = 7'b0_010001;
                6'b1_11110: enc_5b6b = 7'b0_100001;
                6'b1_11111: enc_5b6b = 7'b0_010100;
                default:    enc_5b6b = 7'b1_100111;
            endcase
        end
    endfunction

    function automatic logic [4:0] enc_3b4b(
        input logic [2:0] y,
        input logic [4:0] x,
        input logic       rd
    );
        begin
            unique case ({rd, y})
                4'b0_000: enc_3b4b = 5'b1_1011;
                4'b1_000: enc_3b4b = 5'b0_0100;
                4'b0_001: enc_3b4b = 5'b0_1001;
                4'b1_001: enc_3b4b = 5'b1_1001;
                4'b0_010: enc_3b4b = 5'b0_0101;
                4'b1_010: enc_3b4b = 5'b1_0101;
                4'b0_011: enc_3b4b = 5'b0_1100;
                4'b1_011: enc_3b4b = 5'b1_0011;
                4'b0_100: enc_3b4b = 5'b1_1101;
                4'b1_100: enc_3b4b = 5'b0_0010;
                4'b0_101: enc_3b4b = 5'b0_1010;
                4'b1_101: enc_3b4b = 5'b1_1010;
                4'b0_110: enc_3b4b = 5'b0_0110;
                4'b1_110: enc_3b4b = 5'b1_0110;
                4'b0_111: enc_3b4b = ((x == 5'd17) || (x == 5'd18) || (x == 5'd20))
                                      ? 5'b1_0111 : 5'b1_1110;
                4'b1_111: enc_3b4b = ((x == 5'd11) || (x == 5'd13) || (x == 5'd14))
                                      ? 5'b0_1000 : 5'b0_0001;
                default:  enc_3b4b = 5'b1_1011;
            endcase
        end
    endfunction

    always_comb begin
        six    = 6'b001111;
        four   = 4'b1010;
        rd_mid = rd_in;
        rd_out = rd_in;

        if (kin) begin
            unique case ({rd_in, din})
                9'b0_10111100: begin code = 10'b0011111010; rd_out = 1'b1; end
                9'b1_10111100: begin code = 10'b1100000101; rd_out = 1'b0; end
                9'b0_11111011: begin code = 10'b1101101000; rd_out = 1'b0; end
                9'b1_11111011: begin code = 10'b0010010111; rd_out = 1'b1; end
                9'b0_11111101: begin code = 10'b1011101000; rd_out = 1'b0; end
                9'b1_11111101: begin code = 10'b0100010111; rd_out = 1'b1; end
                9'b0_11110111: begin code = 10'b1110101000; rd_out = 1'b0; end
                9'b1_11110111: begin code = 10'b0001010111; rd_out = 1'b1; end
                default: begin
                    code   = 10'b0011111010;
                    rd_out = 1'b1;
                end
            endcase
        end
        else begin
            {rd_mid, six} = enc_5b6b(din[4:0], rd_in);
            {rd_out, four} = enc_3b4b(din[7:5], din[4:0], rd_mid);
            code = {six, four};
        end
    end

endmodule

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

    typedef enum logic [2:0] {
        SEND_IK,
        SEND_ID,
        SEND_S,
        SEND_D,
        SEND_T,
        SEND_R
    } send_t;

    send_t emit_state;
    logic [7:0] emit_data;
    logic       emit_is_k;
    logic       rd;

    logic [7:0] fifo_mem [0:7];
    logic [2:0] wr_ptr;
    logic [2:0] rd_ptr;
    logic [3:0] fifo_count;

    logic [9:0] enc_code;
    logic       enc_rd_out;

    logic       consume_data;
    logic       pop_fifo;
    logic       push_fifo;
    logic       have_data_now;
    logic [7:0] scheduled_data;
    send_t      next_emit_state;
    logic [7:0] next_emit_data;
    logic       next_emit_is_k;
    logic       frame_pending;
    logic       idle_data_select;

    pcs_8b10b_encode u_encoder (
        .din    (emit_data),
        .kin    (emit_is_k),
        .rd_in  (rd),
        .code   (enc_code),
        .rd_out (enc_rd_out)
    );

    function automatic logic [9:0] tx_order(input logic [9:0] raw);
        tx_order = {raw[0], raw[1], raw[2], raw[3], raw[4],
                    raw[5], raw[6], raw[7], raw[8], raw[9]};
    endfunction

    always_comb begin
        have_data_now = (fifo_count != 4'd0) || TX_EN;
        frame_pending = have_data_now;
        idle_data_select = enc_rd_out;
        scheduled_data = (fifo_count != 4'd0) ? fifo_mem[rd_ptr] : Din;

        next_emit_state = SEND_IK;
        next_emit_data  = K28_5;
        next_emit_is_k  = 1'b1;
        consume_data    = 1'b0;

        unique case (emit_state)
            SEND_IK: begin
                next_emit_state = SEND_ID;
                next_emit_data  = idle_data_select ? D16_2 : D05_6;
                next_emit_is_k  = 1'b0;
            end

            SEND_ID: begin
                if (frame_pending) begin
                    next_emit_state = SEND_S;
                    next_emit_data  = K27_7;
                    next_emit_is_k  = 1'b1;
                end
                else begin
                    next_emit_state = SEND_IK;
                    next_emit_data  = K28_5;
                    next_emit_is_k  = 1'b1;
                end
            end

            SEND_S: begin
                if (have_data_now) begin
                    next_emit_state = SEND_D;
                    next_emit_data  = scheduled_data;
                    next_emit_is_k  = 1'b0;
                    consume_data    = 1'b1;
                end
                else begin
                    next_emit_state = SEND_S;
                    next_emit_data  = K27_7;
                    next_emit_is_k  = 1'b1;
                end
            end

            SEND_D: begin
                if (have_data_now) begin
                    next_emit_state = SEND_D;
                    next_emit_data  = scheduled_data;
                    next_emit_is_k  = 1'b0;
                    consume_data    = 1'b1;
                end
                else begin
                    next_emit_state = SEND_T;
                    next_emit_data  = K29_7;
                    next_emit_is_k  = 1'b1;
                end
            end

            SEND_T: begin
                if (frame_pending) begin
                    next_emit_state = SEND_R;
                    next_emit_data  = K23_7;
                    next_emit_is_k  = 1'b1;
                end
                else begin
                    next_emit_state = SEND_IK;
                    next_emit_data  = K28_5;
                    next_emit_is_k  = 1'b1;
                end
            end

            SEND_R: begin
                if (frame_pending) begin
                    next_emit_state = SEND_S;
                    next_emit_data  = K27_7;
                    next_emit_is_k  = 1'b1;
                end
                else begin
                    next_emit_state = SEND_IK;
                    next_emit_data  = K28_5;
                    next_emit_is_k  = 1'b1;
                end
            end

            default: begin
                next_emit_state = SEND_IK;
                next_emit_data  = K28_5;
                next_emit_is_k  = 1'b1;
            end
        endcase

        pop_fifo  = consume_data && (fifo_count != 4'd0);
        push_fifo = TX_EN && !(consume_data && (fifo_count == 4'd0)) &&
                    ((fifo_count != 4'd8) || pop_fifo);
    end

    always_ff @(posedge Clk) begin
        if (Reset) begin
            Dout        <= tx_order(10'b0011111010);
            rd          <= 1'b0;
            emit_state  <= SEND_IK;
            emit_data   <= K28_5;
            emit_is_k   <= 1'b1;
            wr_ptr      <= 3'd0;
            rd_ptr      <= 3'd0;
            fifo_count  <= 4'd0;
            for (int i = 0; i < 8; i++) begin
                fifo_mem[i] <= 8'h00;
            end
        end
        else begin
            Dout       <= tx_order(enc_code);
            rd         <= enc_rd_out;
            emit_state <= next_emit_state;
            emit_data  <= next_emit_data;
            emit_is_k  <= next_emit_is_k;

            if (push_fifo) begin
                fifo_mem[wr_ptr] <= Din;
                wr_ptr <= wr_ptr + 3'd1;
            end

            if (pop_fifo) begin
                rd_ptr <= rd_ptr + 3'd1;
            end

            unique case ({push_fifo, pop_fifo})
                2'b10: fifo_count <= fifo_count + 4'd1;
                2'b01: fifo_count <= fifo_count - 4'd1;
                default: fifo_count <= fifo_count;
            endcase
        end
    end

endmodule
