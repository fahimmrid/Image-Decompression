library verilog;
use verilog.vl_types.all;
entity milestone2 is
    generic(
        pre_IDCT_Y      : vl_logic_vector(0 to 17) := (Hi0, Hi1, Hi0, Hi0, Hi1, Hi0, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        pre_IDCT_U      : vl_logic_vector(0 to 17) := (Hi1, Hi0, Hi0, Hi1, Hi0, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        pre_IDCT_V      : vl_logic_vector(0 to 17) := (Hi1, Hi0, Hi1, Hi1, Hi1, Hi0, Hi1, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        clock           : in     vl_logic;
        Resetn          : in     vl_logic;
        M2_SRAM_address : out    vl_logic_vector(17 downto 0);
        SRAM_read_data  : in     vl_logic_vector(15 downto 0);
        M2_start        : in     vl_logic;
        SRAM_we_n       : out    vl_logic;
        SRAM_write_data : out    vl_logic_vector(15 downto 0);
        M2_end          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of pre_IDCT_Y : constant is 1;
    attribute mti_svvh_generic_type of pre_IDCT_U : constant is 1;
    attribute mti_svvh_generic_type of pre_IDCT_V : constant is 1;
end milestone2;
