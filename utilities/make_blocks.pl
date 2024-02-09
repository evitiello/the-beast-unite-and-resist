#
#  create the block inserts
#

open OUTFILE, ">>blocks.txt";

# In Database:
# F000-FFFF F000-FFFF   12288 blocks per set.
# A000-AFFF F000-FFFF
# A000-AFFF A000-AFFF
# F000-FFFF A000-AFFF

# To Add:
#
#


for ($iteration = 61440; $iteration <= 65535; $iteration++) {

print OUTFILE <<END;

INSERT INTO blocks (
	entry_11_start, entry_11_end, entry_12_start,	entry_12_end, entry_13_start,	entry_13_end,
	entry_21_start,	entry_21_end, entry_22_start,	entry_22_end, entry_23_start,	entry_23_end,
	entry_31_start,	entry_31_end,	entry_32_start,	entry_32_end,	entry_33_start,	entry_33_end,
	pick_1_start,	pick_1_end,	pick_2_start,	pick_2_end,	pick_3_start,	pick_3_end
) VALUES (
	65535,65535,45007,45007,61695,61695,65535,65535,
	$iteration,$iteration,40960,43007,
	64575,64575,65535,65535,43690,43690,12,12,9,9,13,13
)
GO
INSERT INTO blocks (
	entry_11_start, entry_11_end, entry_12_start,	entry_12_end, entry_13_start,	entry_13_end,
	entry_21_start,	entry_21_end, entry_22_start,	entry_22_end, entry_23_start,	entry_23_end,
	entry_31_start,	entry_31_end,	entry_32_start,	entry_32_end,	entry_33_start,	entry_33_end,
	pick_1_start,	pick_1_end,	pick_2_start,	pick_2_end,	pick_3_start,	pick_3_end
) VALUES (
	65535,65535,45007,45007,61695,61695,65535,65535,
	$iteration,$iteration,63008,45055,
	64575,64575,65535,65535,43690,43690,12,12,9,9,13,13
)
GO
END

}
close OUTFILE;