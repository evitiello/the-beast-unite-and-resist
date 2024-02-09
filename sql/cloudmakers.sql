/*
cloudmakers RUR-14 crack SQL
*/
DROP table users
GO
CREATE TABLE users (
	username			varchar(16),
	email					varchar(128),
	password			varchar(12),
	PRIMARY KEY (username)
)

DROP TABLE results
GO
CREATE TABLE results (
	result_id			int		IDENTITY,
	entry_11			int,
	entry_12			int,
	entry_13			int,
	entry_21			int,
	entry_22			int,
	entry_23			int,
	entry_31			int,
	entry_32			int,
	entry_33			int,
	pick_1				tinyint,
	pick_2				tinyint,
	pick_3				tinyint,
	time_reported	smalldatetime,
	username			varchar(16),
	result_size		int,
	checked_by		int,
	time_checked	smalldatetime	
)
GRANT  SELECT, INSERT, UPDATE 	ON results TO perceive_cloudmakers

DROP TABLE results_2
GO
CREATE TABLE results_2 (
	result_id				int			IDENTITY,
	entry_22_start	int,
	entry_22_end		int,
	entry_23_start	int,
	entry_23_end		int,
	time_reported	smalldatetime,
	username			varchar(16),
	result_size		int,
	checked_by		int,
	time_checked	smalldatetime,
	block_id			int
)
GRANT  SELECT, INSERT, UPDATE 	ON results_2 TO perceive_cloudmakers


CREATE TABLE pick_values (
	pick_id						tinyint,
	pick_description	varchar(32)
)
GRANT  SELECT, INSERT, UPDATE 	ON pick_values TO perceive_cloudmakers

drop table blocks
go
CREATE TABLE blocks (
	block_id					int		IDENTITY,
	entry_11_start		int,
	entry_11_end			int,
	entry_12_start		int,
	entry_12_end			int,
	entry_13_start		int,
	entry_13_end			int,
	entry_21_start		int,
	entry_21_end			int,
	entry_22_start		int,
	entry_22_end			int,
	entry_23_start		int,
	entry_23_end			int,
	entry_31_start		int,
	entry_31_end			int,
	entry_32_start		int,
	entry_32_end			int,
	entry_33_start		int,
	entry_33_end			int,
	pick_1_start			tinyint,
	pick_1_end				tinyint,
	pick_2_start			tinyint,
	pick_2_end				tinyint,
	pick_3_start			tinyint,
	pick_3_end				tinyint,
	time_checked_out	smalldatetime,
	time_checked_in		smalldatetime,
	username					varchar(16),
)
GRANT  SELECT, INSERT, UPDATE 	ON blocks TO perceive_cloudmakers