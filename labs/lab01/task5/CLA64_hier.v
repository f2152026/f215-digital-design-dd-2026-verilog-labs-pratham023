// cla64_hier.v

// BONUS -- open-ended. No detailed scaffold is provided; this is meant to

// be a genuine design exercise. Not required for lab submission.

//

// You will likely need to modify cla4.v (or add signals alongside it) so

// that block-generate/block-propagate summaries of its own Gi, Pi signals

// are exposed as outputs, since the second-level lookahead unit below

// needs them. As with every module in this lab from Task 2 onward, every

// gate/assign you add should carry an explicit delay.

//

// Starting point (from Tutorial 3, Q4(d)):

//   - Reuse 16 four-bit CLA blocks (your cla4.v) -- their internal logic

//     doesn't change.

//   - For each block k, define:

//       Gblk_k = "this block produces a carry regardless of its incoming

//                 carry" -- a Boolean function of that block's own 4

//                 bit-level Gi, Pi signals.

//       Pblk_k = "an incoming carry sails straight through this whole

//                 block" -- likewise a function of its own Gi, Pi.

//   - Build a second-level lookahead unit -- structurally identical to

//     cla4.v, just one level up -- that computes each block's carry-in

//     directly from Gblk_0..Gblk_15, Pblk_0..Pblk_15, and cin, instead of

//     rippling block to block.

//

// To test this, wire it into dut.v as a fourth option (copy the pattern

// used for the other three) and run it through the same tb.v. Compare

// your final delay to cla64_blocked.v from Task 4.

module cla64_hier(

  input  [63:0] a,

  input  [63:0] b,

  input         cin,

  output [63:0] sum,

  output        cout

);

  // TODO: your hierarchical design goes here.

  wire [63:0] p;
  wire [63:0] g;

  wire [15:0] Pblk;
  wire [15:0] Gblk;

  wire [15:1] cblk;

  wire [15:0] cla_cout;


  // ------------------------------------------------------------
  // Bit-level propagate and generate signals
  // ------------------------------------------------------------

  genvar i;

  generate
    for (i = 0; i < 64; i = i + 1) begin : BIT_PG

      xor #(2) (p[i], a[i], b[i]);

      and #(2) (g[i], a[i], b[i]);

    end
  endgenerate


  // ------------------------------------------------------------
  // Block propagate and block generate signals
  //
  // Pblk[k] =
  //   p3 p2 p1 p0
  //
  // Gblk[k] =
  //   g3
  // + p3 g2
  // + p3 p2 g1
  // + p3 p2 p1 g0
  // ------------------------------------------------------------

  genvar k;

  generate
    for (k = 0; k < 16; k = k + 1) begin : BLOCK_PG

      wire gt1;
      wire gt2;
      wire gt3;

      and #(2) (
        Pblk[k],
        p[4*k],
        p[4*k+1],
        p[4*k+2],
        p[4*k+3]
      );

      and #(2) (
        gt1,
        p[4*k+3],
        g[4*k+2]
      );

      and #(2) (
        gt2,
        p[4*k+3],
        p[4*k+2],
        g[4*k+1]
      );

      and #(2) (
        gt3,
        p[4*k+3],
        p[4*k+2],
        p[4*k+1],
        g[4*k]
      );

      or #(2) (
        Gblk[k],
        g[4*k+3],
        gt1,
        gt2,
        gt3
      );

    end
  endgenerate


  // ------------------------------------------------------------
  // Second-level carry lookahead
  //
  // These are NON-RECURSIVE block carry equations.
  // None of cblk[2], cblk[3], ... depends on cblk[n-1].
  // ------------------------------------------------------------

  assign #(2) cblk[1] =
      Gblk[0]
    | (Pblk[0] & cin);


  assign #(2) cblk[2] =
      Gblk[1]
    | (Pblk[1] & Gblk[0])
    | (Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[3] =
      Gblk[2]
    | (Pblk[2] & Gblk[1])
    | (Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[4] =
      Gblk[3]
    | (Pblk[3] & Gblk[2])
    | (Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[5] =
      Gblk[4]
    | (Pblk[4] & Gblk[3])
    | (Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[6] =
      Gblk[5]
    | (Pblk[5] & Gblk[4])
    | (Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[7] =
      Gblk[6]
    | (Pblk[6] & Gblk[5])
    | (Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[8] =
      Gblk[7]
    | (Pblk[7] & Gblk[6])
    | (Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[9] =
      Gblk[8]
    | (Pblk[8] & Gblk[7])
    | (Pblk[8] & Pblk[7] & Gblk[6])
    | (Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[10] =
      Gblk[9]
    | (Pblk[9] & Gblk[8])
    | (Pblk[9] & Pblk[8] & Gblk[7])
    | (Pblk[9] & Pblk[8] & Pblk[7] & Gblk[6])
    | (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[11] =
      Gblk[10]
    | (Pblk[10] & Gblk[9])
    | (Pblk[10] & Pblk[9] & Gblk[8])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Gblk[7])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Gblk[6])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[12] =
      Gblk[11]
    | (Pblk[11] & Gblk[10])
    | (Pblk[11] & Pblk[10] & Gblk[9])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Gblk[8])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Gblk[7])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Gblk[6])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[13] =
      Gblk[12]
    | (Pblk[12] & Gblk[11])
    | (Pblk[12] & Pblk[11] & Gblk[10])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Gblk[9])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Gblk[8])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Gblk[7])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Gblk[6])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[14] =
      Gblk[13]
    | (Pblk[13] & Gblk[12])
    | (Pblk[13] & Pblk[12] & Gblk[11])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Gblk[10])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Gblk[9])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Gblk[8])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Gblk[7])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Gblk[6])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  assign #(2) cblk[15] =
      Gblk[14]
    | (Pblk[14] & Gblk[13])
    | (Pblk[14] & Pblk[13] & Gblk[12])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Gblk[11])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Gblk[10])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Gblk[9])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Gblk[8])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Gblk[7])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Gblk[6])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  // ------------------------------------------------------------
  // Final carry-out
  // ------------------------------------------------------------

  assign #(2) cout =
      Gblk[15]
    | (Pblk[15] & Gblk[14])
    | (Pblk[15] & Pblk[14] & Gblk[13])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Gblk[12])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Gblk[11])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Gblk[10])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Gblk[9])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Gblk[8])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Gblk[7])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Gblk[6])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0])
    | (Pblk[15] & Pblk[14] & Pblk[13] & Pblk[12] & Pblk[11] & Pblk[10] & Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


  // ------------------------------------------------------------
  // Sixteen 4-bit CLA blocks
  // ------------------------------------------------------------

  cla4 CLA0 (
    .a(a[3:0]),
    .b(b[3:0]),
    .cin(cin),
    .sum(sum[3:0]),
    .cout(cla_cout[0])
  );

  cla4 CLA1 (
    .a(a[7:4]),
    .b(b[7:4]),
    .cin(cblk[1]),
    .sum(sum[7:4]),
    .cout(cla_cout[1])
  );

  cla4 CLA2 (
    .a(a[11:8]),
    .b(b[11:8]),
    .cin(cblk[2]),
    .sum(sum[11:8]),
    .cout(cla_cout[2])
  );

  cla4 CLA3 (
    .a(a[15:12]),
    .b(b[15:12]),
    .cin(cblk[3]),
    .sum(sum[15:12]),
    .cout(cla_cout[3])
  );

  cla4 CLA4 (
    .a(a[19:16]),
    .b(b[19:16]),
    .cin(cblk[4]),
    .sum(sum[19:16]),
    .cout(cla_cout[4])
  );

  cla4 CLA5 (
    .a(a[23:20]),
    .b(b[23:20]),
    .cin(cblk[5]),
    .sum(sum[23:20]),
    .cout(cla_cout[5])
  );

  cla4 CLA6 (
    .a(a[27:24]),
    .b(b[27:24]),
    .cin(cblk[6]),
    .sum(sum[27:24]),
    .cout(cla_cout[6])
  );

  cla4 CLA7 (
    .a(a[31:28]),
    .b(b[31:28]),
    .cin(cblk[7]),
    .sum(sum[31:28]),
    .cout(cla_cout[7])
  );

  cla4 CLA8 (
    .a(a[35:32]),
    .b(b[35:32]),
    .cin(cblk[8]),
    .sum(sum[35:32]),
    .cout(cla_cout[8])
  );

  cla4 CLA9 (
    .a(a[39:36]),
    .b(b[39:36]),
    .cin(cblk[9]),
    .sum(sum[39:36]),
    .cout(cla_cout[9])
  );

  cla4 CLA10 (
    .a(a[43:40]),
    .b(b[43:40]),
    .cin(cblk[10]),
    .sum(sum[43:40]),
    .cout(cla_cout[10])
  );

  cla4 CLA11 (
    .a(a[47:44]),
    .b(b[47:44]),
    .cin(cblk[11]),
    .sum(sum[47:44]),
    .cout(cla_cout[11])
  );

  cla4 CLA12 (
    .a(a[51:48]),
    .b(b[51:48]),
    .cin(cblk[12]),
    .sum(sum[51:48]),
    .cout(cla_cout[12])
  );

  cla4 CLA13 (
    .a(a[55:52]),
    .b(b[55:52]),
    .cin(cblk[13]),
    .sum(sum[55:52]),
    .cout(cla_cout[13])
  );

  cla4 CLA14 (
    .a(a[59:56]),
    .b(b[59:56]),
    .cin(cblk[14]),
    .sum(sum[59:56]),
    .cout(cla_cout[14])
  );

  cla4 CLA15 (
    .a(a[63:60]),
    .b(b[63:60]),
    .cin(cblk[15]),
    .sum(sum[63:60]),
    .cout(cla_cout[15])
  );

endmodule