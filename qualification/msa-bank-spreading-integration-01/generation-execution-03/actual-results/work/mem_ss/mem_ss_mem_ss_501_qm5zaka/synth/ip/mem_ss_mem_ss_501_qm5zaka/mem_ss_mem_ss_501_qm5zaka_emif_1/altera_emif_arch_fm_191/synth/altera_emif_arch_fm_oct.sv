// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



module altera_emif_arch_fm_oct #(
   parameter PHY_CALIBRATED_OCT = 0
) (
   input  logic oct_rzqin, 
   output logic oct_termin 
);
   localparam OCT_USER_OCT = "A_OCT_USER_OCT_OFF";

   generate if (PHY_CALIBRATED_OCT == 1) begin
     tennm_termination term_inst (
       .req_recal (1'b0),
       .ack_recal (/*open*/),
       .rzqin     (oct_rzqin),
       .serdataout(oct_termin)
     );
   end
   endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPG5KD9yHt6GCEJLStVvrkbispWACo3KA5x1H84h9dQZexbcvCw+INN5kdT/2LBCpc5uI7rw537jlLM5P3ro/0EWulE+sC/zXzk/OkPR1lR6Nk1K1PlrZQh4GLctEb4K8Y9C8v4gLFjeTBPqxskUopsIqhbh48+ySRHewRttOMQaiD03CzCG7RNr4ilxaqeXnz4JeiTAs3na4eBE47QUqmH2QaNPx3pqDpLrwhOleo2MWspUwLqpGh43zlGeU1xfAGMNycJJC4DPjFwTcrRb5so3KzpNwB93T2DCTHG5yQuLLiXnErleRj+dVNETFA60STynRLxRReYbx2iWFUzeyWK0WbLf652CcwJPqhYxcdxAj1GS68itfJ21sg+Fj1Wc+w/CjfwGaO+oDId/wLywSPOK8xxs7kvxBvZhQKZVyZkiil4w1x6NRq4ms6WLhtMFWXx3YKAxe00dkezSte5lQx8S4PKtGTI+VmD1aw+kgfx0ufIvT3JWb22vdYd5vRXsvZjK+MkEUl4o8KvghEkRdcj3/VbEegTVgcH28wl7bX862VXsajQ/p51Qj1BR8IU7D3GmFJQ21YsuWGJVdxrnIrZgShkCCCJX/hu6G/M6hEkluQEMiaviKNJ5CynULqZRpXQNwyZ5+mI5jUVOwwl+zqe2unqcD/qakrVEVNlxGuSvbxm8JSbJeEtASq54r0THA1YckHJgIAWGG4FDII+ZgRamYyMnkrErJ1oSjiRxuAGrhDvlX34iGUznd4z30ZkV/BgW1Z0TT69yDfLqV4AvDl0F"
`endif