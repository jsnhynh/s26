`timescale 1ns/1ps

module fifo (
    input  logic       clk,
    input  logic       rst,
    input  logic       push,
    input  logic       pop,
    input  logic [7:0] din,
    output logic [7:0] dout,
    output logic [7:0] next_dout,
    output logic [3:0] count,
    output logic       empty,
    output logic       full
);

    logic [7:0] mem [0:7];
    logic [2:0] wr_ptr;
    logic [2:0] rd_ptr;
    logic [3:0]    used;
    logic          do_push;
    logic          do_pop;

    assign empty = (used == 4'd0);
    assign full  = (used == 4'd8);
    assign count = used;

    assign do_push = push && !full;
    assign do_pop  = pop  && !empty;

    always_comb begin
        if (empty) dout = 8'h00;
        else       dout = mem[rd_ptr];
    end

    // next_dout: FIFO data after a pop (look-ahead for Dout encoding)
    // Must bypass if the next read pointer is the address currently being written.
    logic [2:0] next_rd_ptr;
    assign next_rd_ptr = rd_ptr + {2'b00, do_pop};

    always_comb begin
        if (empty)
            next_dout = do_push ? din : 8'h00; // If empty but pushing, next_dout will be the pushed data
        else if (do_push && (next_rd_ptr == wr_ptr))
            next_dout = din;                   // Bypass memory if reading the cell being written
        else
            next_dout = mem[next_rd_ptr];      // Safe to read from memory
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            used   <= '0;
            for (int i = 0; i < 8; i++) begin
                mem[i] <= 8'h00;
            end
        end
        else begin
            if (do_push) begin
                mem[wr_ptr] <= din;
                wr_ptr      <= wr_ptr + 1'b1;
            end

            if (do_pop) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            case ({do_push, do_pop})
                2'b10: used <= used + 1'b1;
                2'b01: used <= used - 1'b1;
                default: used <= used;
            endcase
        end
    end

endmodule


`timescale 1ns/1ps

module enc8b10b_core (
    input  logic [7:0] data,
    input  logic       is_k,
    input  logic       rd_in,
    output logic [9:0] code,
    output logic       rd_out
);

    logic [10:0] enc_word;
    logic [6:0]  data_6b;
    logic [4:0]  data_4b;

    function automatic logic [6:0] encode_data_6b(
        input logic [4:0] five,
        input logic       rd
    );
        begin
            encode_data_6b = 7'b0_000000;
            case ({rd, five})
            6'b0_00000: encode_data_6b = 7'b1_100111;
            6'b0_00001: encode_data_6b = 7'b1_011101;
            6'b0_00010: encode_data_6b = 7'b1_101101;
            6'b0_00011: encode_data_6b = 7'b0_110001;
            6'b0_00100: encode_data_6b = 7'b1_110101;
            6'b0_00101: encode_data_6b = 7'b0_101001;
            6'b0_00110: encode_data_6b = 7'b0_011001;
            6'b0_00111: encode_data_6b = 7'b0_111000;
            6'b0_01000: encode_data_6b = 7'b1_111001;
            6'b0_01001: encode_data_6b = 7'b0_100101;
            6'b0_01010: encode_data_6b = 7'b0_010101;
            6'b0_01011: encode_data_6b = 7'b0_110100;
            6'b0_01100: encode_data_6b = 7'b0_001101;
            6'b0_01101: encode_data_6b = 7'b0_101100;
            6'b0_01110: encode_data_6b = 7'b0_011100;
            6'b0_01111: encode_data_6b = 7'b1_010111;
            6'b0_10000: encode_data_6b = 7'b1_011011;
            6'b0_10001: encode_data_6b = 7'b0_100011;
            6'b0_10010: encode_data_6b = 7'b0_010011;
            6'b0_10011: encode_data_6b = 7'b0_110010;
            6'b0_10100: encode_data_6b = 7'b0_001011;
            6'b0_10101: encode_data_6b = 7'b0_101010;
            6'b0_10110: encode_data_6b = 7'b0_011010;
            6'b0_10111: encode_data_6b = 7'b1_111010;
            6'b0_11000: encode_data_6b = 7'b1_110011;
            6'b0_11001: encode_data_6b = 7'b0_100110;
            6'b0_11010: encode_data_6b = 7'b0_010110;
            6'b0_11011: encode_data_6b = 7'b1_110110;
            6'b0_11100: encode_data_6b = 7'b0_001110;
            6'b0_11101: encode_data_6b = 7'b1_101110;
            6'b0_11110: encode_data_6b = 7'b1_011110;
            6'b0_11111: encode_data_6b = 7'b1_101011;
            6'b1_00000: encode_data_6b = 7'b0_011000;
            6'b1_00001: encode_data_6b = 7'b0_100010;
            6'b1_00010: encode_data_6b = 7'b0_010010;
            6'b1_00011: encode_data_6b = 7'b1_110001;
            6'b1_00100: encode_data_6b = 7'b0_001010;
            6'b1_00101: encode_data_6b = 7'b1_101001;
            6'b1_00110: encode_data_6b = 7'b1_011001;
            6'b1_00111: encode_data_6b = 7'b1_000111;
            6'b1_01000: encode_data_6b = 7'b0_000110;
            6'b1_01001: encode_data_6b = 7'b1_100101;
            6'b1_01010: encode_data_6b = 7'b1_010101;
            6'b1_01011: encode_data_6b = 7'b1_110100;
            6'b1_01100: encode_data_6b = 7'b1_001101;
            6'b1_01101: encode_data_6b = 7'b1_101100;
            6'b1_01110: encode_data_6b = 7'b1_011100;
            6'b1_01111: encode_data_6b = 7'b0_101000;
            6'b1_10000: encode_data_6b = 7'b0_100100;
            6'b1_10001: encode_data_6b = 7'b1_100011;
            6'b1_10010: encode_data_6b = 7'b1_010011;
            6'b1_10011: encode_data_6b = 7'b1_110010;
            6'b1_10100: encode_data_6b = 7'b1_001011;
            6'b1_10101: encode_data_6b = 7'b1_101010;
            6'b1_10110: encode_data_6b = 7'b1_011010;
            6'b1_10111: encode_data_6b = 7'b0_000101;
            6'b1_11000: encode_data_6b = 7'b0_001100;
            6'b1_11001: encode_data_6b = 7'b1_100110;
            6'b1_11010: encode_data_6b = 7'b1_010110;
            6'b1_11011: encode_data_6b = 7'b0_001001;
            6'b1_11100: encode_data_6b = 7'b1_001110;
            6'b1_11101: encode_data_6b = 7'b0_010001;
            6'b1_11110: encode_data_6b = 7'b0_100001;
            6'b1_11111: encode_data_6b = 7'b0_010100;
            endcase
        end
    endfunction

    function automatic logic [4:0] encode_data_4b(
        input logic [2:0] three,
        input logic [4:0] five,
        input logic       rd_mid
    );
        begin
            encode_data_4b = 5'b0_0000;
            case ({rd_mid, three})
                4'b0_000: encode_data_4b = 5'b1_1011;
                4'b1_000: encode_data_4b = 5'b0_0100;
                4'b0_001: encode_data_4b = 5'b0_1001;
                4'b1_001: encode_data_4b = 5'b1_1001;
                4'b0_010: encode_data_4b = 5'b0_0101;
                4'b1_010: encode_data_4b = 5'b1_0101;
                4'b0_011: encode_data_4b = 5'b0_1100;
                4'b1_011: encode_data_4b = 5'b1_0011;
                4'b0_100: encode_data_4b = 5'b1_1101;
                4'b1_100: encode_data_4b = 5'b0_0010;
                4'b0_101: encode_data_4b = 5'b0_1010;
                4'b1_101: encode_data_4b = 5'b1_1010;
                4'b0_110: encode_data_4b = 5'b0_0110;
                4'b1_110: encode_data_4b = 5'b1_0110;
                4'b0_111: begin
                    if ((five == 5'd17) || (five == 5'd18) || (five == 5'd20))
                        encode_data_4b = 5'b1_0111;
                    else
                        encode_data_4b = 5'b1_1110;
                end
                4'b1_111: begin
                    if ((five == 5'd11) || (five == 5'd13) || (five == 5'd14))
                        encode_data_4b = 5'b0_1000;
                    else
                        encode_data_4b = 5'b0_0001;
                end
            endcase
        end
    endfunction

    function automatic logic [10:0] encode_k(
        input logic [7:0] k_data,
        input logic       rd
    );
        begin
            encode_k = 11'b0_0000000000;
            unique case ({rd, k_data})
            9'b0_10111100: encode_k = 11'b1_0011111010;
            9'b0_11110111: encode_k = 11'b0_1110101000;
            9'b0_11111011: encode_k = 11'b0_1101101000;
            9'b0_11111101: encode_k = 11'b0_1011101000;
            9'b1_10111100: encode_k = 11'b0_1100000101;
            9'b1_11110111: encode_k = 11'b1_0001010111;
            9'b1_11111011: encode_k = 11'b1_0010010111;
            9'b1_11111101: encode_k = 11'b1_0100010111;
                default: encode_k = 11'b0_0000000000;
            endcase
        end
    endfunction

    always_comb begin
        data_6b  = 7'b0_000000;
        data_4b  = 5'b0_0000;

        if (is_k) begin
            enc_word = encode_k(data, rd_in);
        end
        else begin
            data_6b  = encode_data_6b(data[4:0], rd_in);
            data_4b  = encode_data_4b(data[7:5], data[4:0], data_6b[6]);
            enc_word = {data_4b[4], data_6b[5:0], data_4b[3:0]};
        end

        rd_out = enc_word[10];
        code   = enc_word[9:0];
    end

endmodule

`timescale 1ns/1ps

module E1000X(
    input  logic       Clk,
    input  logic       Reset,
    input  logic       TX_EN,
    input  logic [7:0] Din,
    output logic [9:0] Dout
);

    localparam logic RD_NEG = 1'b0;

    localparam logic [7:0] K_I_COMMA = 8'hBC;
    localparam logic [7:0] D_I1      = 8'hC5;
    localparam logic [7:0] D_I2      = 8'h50;
    localparam logic [7:0] K_S       = 8'hFB;
    localparam logic [7:0] K_T       = 8'hFD;
    localparam logic [7:0] K_R       = 8'hF7;
    localparam logic [9:0] RESET_DOUT = 10'b0101111100;

    typedef enum logic [2:0] {
        ST_IDLE_K,
        ST_IDLE_D,
        ST_START,
        ST_DATA,
        ST_EPD_T,
        ST_EPD_R
    } state_t;

    state_t state;
    state_t next_state;

    logic rd;
    logic idle_after_k_rd_pos;

    logic [7:0] fifo_dout;
    logic [7:0] fifo_next_dout;
    logic [3:0] fifo_count;
    logic       fifo_empty;
    logic       fifo_full;
    logic       push_fifo;
    logic       pop_fifo;

    logic [7:0] enc_byte;
    logic       enc_is_k;
    logic [9:0] enc_code;
    logic       enc_rd_out;

    logic frame_waiting;
    logic last_data_symbol;

    fifo u_fifo (
        .clk       (Clk),
        .rst       (Reset),
        .push      (push_fifo),
        .pop       (pop_fifo),
        .din       (Din),
        .dout      (fifo_dout),
        .next_dout (fifo_next_dout),
        .count     (fifo_count),
        .empty     (fifo_empty),
        .full      (fifo_full)
    );

    // ---------------------------------------------------------------
    // Encoders for current state/rd — used for rd tracking only
    // ---------------------------------------------------------------
    logic [9:0] enc_code_rd0, enc_code_rd1;
    logic       enc_rd_out_rd0, enc_rd_out_rd1;

    enc8b10b_core u_enc0 (
        .data   (enc_byte),
        .is_k   (enc_is_k),
        .rd_in  (1'b0),
        .code   (enc_code_rd0),
        .rd_out (enc_rd_out_rd0)
    );

    enc8b10b_core u_enc1 (
        .data   (enc_byte),
        .is_k   (enc_is_k),
        .rd_in  (1'b1),
        .code   (enc_code_rd1),
        .rd_out (enc_rd_out_rd1)
    );

    always_comb begin
        if (rd) begin
            enc_code   = enc_code_rd1;
            enc_rd_out = enc_rd_out_rd1;
        end
        else begin
            enc_code   = enc_code_rd0;
            enc_rd_out = enc_rd_out_rd0;
        end
    end

    // ---------------------------------------------------------------
    // Look-ahead encoders: compute encoding for NEXT state so we can
    // register Dout at posedge using only DFFPOSX1 (library-compatible).
    // enc_rd_out is rd[N] (value after this posedge), used for selection.
    // ---------------------------------------------------------------
    logic [7:0] enc_byte_la;
    logic       enc_is_k_la;
    logic [9:0] enc_code_la_rd0, enc_code_la_rd1;

    enc8b10b_core u_enc_la0 (
        .data   (enc_byte_la),
        .is_k   (enc_is_k_la),
        .rd_in  (1'b0),
        .code   (enc_code_la_rd0),
        .rd_out ()
    );

    enc8b10b_core u_enc_la1 (
        .data   (enc_byte_la),
        .is_k   (enc_is_k_la),
        .rd_in  (1'b1),
        .code   (enc_code_la_rd1),
        .rd_out ()
    );

    always_comb begin
        enc_byte_la = K_I_COMMA;
        enc_is_k_la = 1'b1;
        case (next_state)
            ST_IDLE_K: begin
                enc_byte_la = K_I_COMMA;
                enc_is_k_la = 1'b1;
            end
            ST_IDLE_D: begin
                enc_byte_la = ((state == ST_IDLE_K) ? enc_rd_out : idle_after_k_rd_pos)
                              ? D_I2 : D_I1;
                enc_is_k_la = 1'b0;
            end
            ST_START: begin
                enc_byte_la = K_S;
                enc_is_k_la = 1'b1;
            end
            ST_DATA: begin
                enc_byte_la = fifo_next_dout;
                enc_is_k_la = 1'b0;
            end
            ST_EPD_T: begin
                enc_byte_la = K_T;
                enc_is_k_la = 1'b1;
            end
            ST_EPD_R: begin
                enc_byte_la = K_R;
                enc_is_k_la = 1'b1;
            end
            default: begin
                enc_byte_la = K_I_COMMA;
                enc_is_k_la = 1'b1;
            end
        endcase
    end

    // Posedge Dout: at posedge N registers encode(next_state, enc_rd_out=rd[N]).
    // Testbench samples between posedge N and N+1 -> reads encode(state[N], rd[N]).
    always_ff @(posedge Clk) begin
        if (Reset)
            Dout <= RESET_DOUT;
        else begin
            if (enc_rd_out)
                Dout <= {enc_code_la_rd1[0], enc_code_la_rd1[1], enc_code_la_rd1[2],
                         enc_code_la_rd1[3], enc_code_la_rd1[4], enc_code_la_rd1[5],
                         enc_code_la_rd1[6], enc_code_la_rd1[7], enc_code_la_rd1[8],
                         enc_code_la_rd1[9]};
            else
                Dout <= {enc_code_la_rd0[0], enc_code_la_rd0[1], enc_code_la_rd0[2],
                         enc_code_la_rd0[3], enc_code_la_rd0[4], enc_code_la_rd0[5],
                         enc_code_la_rd0[6], enc_code_la_rd0[7], enc_code_la_rd0[8],
                         enc_code_la_rd0[9]};
        end
    end

    always_comb begin
        push_fifo = TX_EN && !fifo_full;
        pop_fifo  = (state == ST_DATA) && !fifo_empty;

        frame_waiting    = TX_EN || !fifo_empty;
        last_data_symbol = (!TX_EN && (fifo_count == 4'd1));
    end

    always_comb begin
        enc_byte = 8'h00;
        enc_is_k = 1'b0;

        case (state)
            ST_IDLE_K: begin
                enc_byte = K_I_COMMA;
                enc_is_k = 1'b1;
            end

            ST_IDLE_D: begin
                if (idle_after_k_rd_pos) enc_byte = D_I2;
                else                     enc_byte = D_I1;
                enc_is_k = 1'b0;
            end

            ST_START: begin
                enc_byte = K_S;
                enc_is_k = 1'b1;
            end

            ST_DATA: begin
                enc_byte = fifo_dout;
                enc_is_k = 1'b0;
            end

            ST_EPD_T: begin
                enc_byte = K_T;
                enc_is_k = 1'b1;
            end

            ST_EPD_R: begin
                enc_byte = K_R;
                enc_is_k = 1'b1;
            end

            default: begin
                enc_byte = K_I_COMMA;
                enc_is_k = 1'b1;
            end
        endcase
    end

    always_comb begin
        next_state = state;

        case (state)
            ST_IDLE_K: begin
                next_state = ST_IDLE_D;
            end

            ST_IDLE_D: begin
                if (frame_waiting) next_state = ST_START;
                else               next_state = ST_IDLE_K;
            end

            ST_START: begin
                if (!fifo_empty) next_state = ST_DATA;
                else             next_state = ST_START;
            end

            ST_DATA: begin
                if (last_data_symbol) next_state = ST_EPD_T;
                else                  next_state = ST_DATA;
            end

            ST_EPD_T: begin
                if (frame_waiting) next_state = ST_EPD_R;
                else               next_state = ST_IDLE_K;
            end

            ST_EPD_R: begin
                if (frame_waiting) next_state = ST_START;
                else               next_state = ST_IDLE_K;
            end

            default: begin
                next_state = ST_IDLE_K;
            end
        endcase
    end

    always_ff @(posedge Clk) begin
        if (Reset) begin
            state               <= ST_IDLE_K;
            rd                  <= RD_NEG;
            idle_after_k_rd_pos <= 1'b0;
        end
        else begin
            state <= next_state;
            rd    <= enc_rd_out;

            if (state == ST_IDLE_K) begin
                idle_after_k_rd_pos <= enc_rd_out;
            end
        end
    end

endmodule
