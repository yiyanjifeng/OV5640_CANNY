module canny_edge_detect_top#(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 1024
)(
    input wire clk,
    input wire rst_n,
    input wire pre_frame_vsync,
    input wire pre_frame_href,
    input wire pre_frame_de,
    input wire [15:0] pre_rgb,
    output wire post_frame_vsync,
    output wire post_frame_href,
    output wire post_frame_de,
    output wire [15:0] post_rgb
);

    wire [15:0] gra_path;
    wire [7:0] img_y;
    wire grandient_hs;
    wire grandient_vs;
    wire grandient_de;

    wire nonLocalMax_hs;
    wire nonLocalMax_vs;
    wire nonLocalMax_de;

    wire pe_frame_vsync;
    wire pe_frame_href;
    wire pe_frame_clken;

    wire gauss_vsync;
    wire gauss_hsync;
    wire gauss_de;
    wire [7:0] img_gauss;

    wire post_img_bit;

    // 初始化 post_img_bit
    assign post_img_bit = 1'b0;

    // 计算 post_rgb
    assign post_rgb = {16{~post_img_bit}};

    // 同步复位信号
    wire sync_rst_n;
    sync_flop  u_sync_flop(
        .clk(clk),
        .async_rst_n(rst_n),
        .sync_rst_n(sync_rst_n)
    );

    rgb2ycbcr u_rgb2ycbcr (
        .clk(clk),
        .rst_n(sync_rst_n),
        .pre_frame_vsync(pre_frame_vsync),
        .pre_frame_href(pre_frame_href),
        .pre_frame_de(pre_frame_de),
        .img_red(pre_rgb[15:11]),
        .img_green(pre_rgb[10:5]),
        .img_blue(pre_rgb[4:0]),
        .post_frame_vsync(pe_frame_vsync),
        .post_frame_href(pe_frame_href),
        .post_frame_de(pe_frame_clken),
        .img_y(img_y),
        .img_cb(1'b0),
        .img_cr(1'b0)
    );

    image_gaussian_filter u_image_gaussian_filter (
        .clk(clk),
        .rst_n(sync_rst_n),
        .per_frame_vsync(pe_frame_vsync),
        .per_frame_href(pe_frame_href),
        .per_frame_clken(pe_frame_clken),
        .per_img_gray(img_y),
        .post_frame_vsync(gauss_vsync),
        .post_frame_href(gauss_hsync),
        .post_frame_clken(gauss_de),
        .post_img_gray(img_gauss)
    );

    canny_edge_detect_top#(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) u_canny_edge_detect_top (
        .clk(clk),
        .rst_n(sync_rst_n),
        .per_frame_vsync(gauss_vsync),
        .per_frame_href(gauss_hsync),
        .per_frame_clken(gauss_de),
        .per_img_y(img_gauss),
        .post_frame_vsync(post_frame_vsync),
        .post_frame_href(post_frame_href),
        .post_frame_de(post_frame_de),
        .post_img_bit(post_img_bit)
    );

    // 参数检查
    initial begin
        if (DATA_WIDTH < 1 || DATA_WIDTH > 16) begin
            $fatal("DATA_WIDTH must be between 1 and 16");
        end
        if (DATA_DEPTH < 1 || DATA_DEPTH > 4096) begin
            $fatal("DATA_DEPTH must be between 1 and 4096");
        end
    end

    // 复位逻辑
    always @(posedge clk or negedge sync_rst_n) begin
        if (!sync_rst_n) begin
            post_frame_vsync <= 1'b0;
            post_frame_href <= 1'b0;
            post_frame_de <= 1'b0;
            post_rgb <= 16'b0;
        end
    end

endmodule