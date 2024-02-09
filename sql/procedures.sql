/*
How many keys from blcoks have been checked, and how many are left
*/
select
SUM(((entry_22_end - entry_22_start) + 1) * (entry_23_end - entry_23_start)-2) As total_left_to_check
from blocks
where time_checked_in IS NULL
select
SUM(((entry_22_end - entry_22_start) + 1) * (entry_23_end - entry_23_start)-2) As total_checked
from blocks
where time_checked_in IS NOT NULL


/* find duplicate results */
select entry_22, entry_23, count(*) 
from results group by entry_22, entry_23 having count(*)>1


/* get a new block */


DROP PROC sp_get_new_block
GO
CREATE PROC sp_get_new_block (
	@username varchar(16),
	@block_id int = NULL
) AS

	BEGIN TRANSACTION get_block

		/* get a block... try to get one that only has one result try in it.*/
		SELECT TOP 1 @block_id=block_id FROM blocks WHERE time_checked_out IS NULL
		AND entry_22_start=entry_22_end AND entry_23_start=entry_23_end

		/* if there are no more with just one result, just get any one.	*/
		IF @block_id IS NULL
			SELECT TOP 1 @block_id = block_id FROM blocks WHERE time_checked_out IS NULL

		/*check out the block.	*/
		UPDATE blocks SET time_checked_out = GETDATE(), username=@username WHERE block_id=@block_id
		SELECT * FROM blocks WHERE block_id = @block_id
		
	COMMIT TRANSACTION get_block
GO
GRANT  EXECUTE 	ON sp_get_new_block TO perceive_cloudmakers

INSERT INTO users (username, email, password) VALUES ('e_vitiello_jr','eric@perceive.net','PASSWORD')


DROP PROC sp_add_result
GO
CREATE PROC sp_add_result (
	@entry_11					int,
	@entry_12					int,
	@entry_13					int,
	@pick_1						tinyint,

	@entry_21					int,
	@entry_22					int,
	@entry_23					int,
	@pick_2						tinyint,

	@entry_31					int,
	@entry_32					int,
	@entry_33					int,
	@pick_3						tinyint,

	@result_size			int,
	@username					varchar(16),
	
	@result_id				int	= NULL
	
) AS

	BEGIN TRANSACTION add_result

		SELECT @result_id = result_id FROM results
			WHERE 
				/*entry_11=@entry_11 AND entry_12=@entry_12 AND entry_13=@entry_13 AND pick_1=@pick_1
				AND entry_21=@entry_21 AND */entry_22=@entry_22 AND entry_23=@entry_23/* AND pick_2=@pick_2
				AND entry_31=@entry_31 AND entry_32=@entry_32 AND entry_33=@entry_33 AND pick_3=@pick_3*/

		IF @result_id IS NULL
			/* check in the result, otherwise, this is a duplicate.*/
			INSERT INTO results
				(
				entry_11,entry_12,entry_13,pick_1,entry_21,entry_22,entry_23,pick_2,entry_31,entry_32,entry_33,pick_3,
				result_size,time_reported,username
				) VALUES (
					@entry_11, @entry_12, @entry_13, @pick_1,
					@entry_21, @entry_22, @entry_23, @pick_2,
					@entry_31, @entry_32, @entry_33, @pick_3,
					@result_size, GETDATE(), @username
				)
	COMMIT TRANSACTION add_result
GO
GRANT EXECUTE ON sp_add_result TO perceive_cloudmakers



DROP PROC sp_add_result_3
GO
CREATE PROC sp_add_result_3 (
	@entry_22_start				int,
	@entry_22_end					int,
	@entry_23_start				int,
	@entry_23_end					int,

	@result_size			int,
	@block_id					int,
	@username					varchar(16),
	
	@result_id				int	= NULL
	
) AS

	BEGIN TRANSACTION add_result

		SELECT @result_id = result_id FROM results_2
			WHERE 
				entry_22_start=@entry_22_start AND entry_23_start=@entry_23_start
				AND entry_22_end=@entry_22_end AND entry_23_end=@entry_23_end

		IF @result_id IS NULL
			/* check in the result, otherwise, this is a duplicate.*/
			INSERT INTO results_2
				(
				entry_22_start,entry_22_end,entry_23_start,entry_23_end,
				result_size,time_reported,username,block_id
				) VALUES (
					@entry_22_start, @entry_22_end, @entry_23_start, @entry_23_end,
					@result_size, GETDATE(), @username, @block_id
				)
	COMMIT TRANSACTION add_result
GO
GRANT EXECUTE ON sp_add_result_3 TO perceive_cloudmakers