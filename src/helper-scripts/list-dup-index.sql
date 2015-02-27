---Duplicate Indexes with same definition

;WITH Ori_Index as 
(
	SELECT ic.object_id ,IC.index_id IC_INDEX_ID,SUM(IC.Column_ID) IC_COL_SUM
	--SELECT *
	FROM sys.index_columns IC
	WHERE object_id > 100
	GROUP BY ic.object_id ,IC.index_id
),
Dup_Index AS
(
	SELECT ic.object_id ,IC.index_id IC_INDEX_ID,IC_Dup.index_id IC_DUP_INDEX_ID,SUM(IC_Dup.Column_ID) DUP_COL_SUM
	--SELECT *
	FROM sys.index_columns IC
	INNER JOIN sys.index_columns IC_Dup
	ON IC.object_id = IC_Dup.object_id
		AND IC.column_id = IC_Dup.column_id
		AND IC.key_ordinal = IC_Dup.key_ordinal
		AND ic.index_column_id = ic_dup.index_column_id
		AND IC.Index_id < IC_Dup.Index_id
	INNER JOIN sys.indexes I_Dup ON I_Dup.index_id = IC_Dup.Index_id AND I_Dup.object_id = IC_Dup.object_id
	WHERE IC.object_id > 100
		AND I_Dup.type <> 1
	GROUP BY ic.object_id, IC.index_id,IC_Dup.index_id
)
SELECT 
	i.object_id,OBJECT_NAME(i.object_id) tbl_name,
	i.IC_INDEX_ID,
	ii.name,
	d.IC_DUP_INDEX_ID,
	id.name
FROM Ori_Index i 
INNER JOIN Dup_Index d 
	ON i.object_id = d.object_id 
		AND i.IC_INDEX_ID = d.IC_INDEX_ID AND i.IC_COL_SUM = d.DUP_COL_SUM
INNER JOIN sys.indexes ii 
	ON ii.index_id = i.IC_INDEX_ID 
		AND ii.object_id = i.object_id
INNER JOIN sys.indexes id 
	ON id.index_id = d.IC_DUP_INDEX_ID 
		AND id.object_id = i.object_id
ORDER BY tbl_name,ic_index_id
