// tb.v
// Starter testbench template -- YOU complete this file.

module tb;

  // TODO: declare the inputs and outputs
  reg  [1:0] t_sel;
  wire [7:0] t_dout;

  // TODO: instantiate DUT here
  DUT U1 (
    .sel  (t_sel),
    .dout (t_dout)
  );

  // Waveform dump configuration (DO NOT CHANGE)
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    // TODO: apply different input combinations
    t_sel = 0; #5;
    t_sel = 1; #5;
    t_sel = 2; #5;
    t_sel = 3; #5;

    $finish;
  end

  initial
    $monitor($time, " sel=%b | dout=%b", t_sel, t_dout);

endmodule