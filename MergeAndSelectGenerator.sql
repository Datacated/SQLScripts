/* 
Declare the schema and table name here. 
If this is going to be a select/insert and the names are slightly different, run this for both tables.
*/
DECLARE @SchemaName varchar(100) = 'dbo'
DECLARE @TableName VARCHAR(100) = 'TableA'

/*
This part will return code you can copy and paste for a straight update.
Note that this one doesn't reference a alias as opposed to the comparison block.
*/
SELECT '[' + c.name + '] = ' + 'src.[' + c.name + '],' AS UpdateCode
FROM 
sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
INNER JOIN sys.columns c ON c.object_id = o.object_id
WHERE s.name = @SchemaName AND 
o.name = @TableName
ORDER BY c.column_id

/*
This is a dual selector for viewing the contents of both tables side by side on columns. 
Helpful if you're wanting to see results of wide tables and compare each value side by side
*/
SELECT 'tgt.[' + c.name + '], ' + 'src.[' + c.name + '],' AS DualTableSelector
FROM 
sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
INNER JOIN sys.columns c ON c.object_id = o.object_id
WHERE s.name = @SchemaName AND 
o.name = @TableName
ORDER BY c.column_id

/*
This block casts everything as nvarchar(2000) and compares it to the value in another table.
I've used this for large staging tables combined with the dual selector above to pin down 
differences in values. It's a nasty table scan but when you need it at 3am it helps to have it.
*/
SELECT 'OR isnull(cast(tgt.[' + c.name + '] as nvarchar(2000)),'''') <> ' + 'isnull(cast(src.[' + c.name + '] as nvarchar(2000)),'''')' AS Comparison
FROM 
sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
INNER JOIN sys.columns c ON c.object_id = o.object_id
WHERE s.name = @SchemaName AND 
o.name = @TableName
ORDER BY c.column_id

/*
This generates the set statement code for a merge
*/
SELECT 'tgt.[' + c.name + '] = ' + 'src.[' + c.name + '],' AS MergeSet FROM 
sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
INNER JOIN sys.columns c ON c.object_id = o.object_id
WHERE s.name = @SchemaName AND 
o.name = @TableName
ORDER BY c.column_id

/*
Not super useful on its own but when you're generating anything else here like a merge I figured it was handy to have
*/
SELECT '[' + c.name + '],' AS SingleSelector
FROM 
sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
INNER JOIN sys.columns c ON c.object_id = o.object_id
WHERE s.name = @SchemaName AND 
o.name = @TableName
ORDER BY c.column_id

/*
Select from single table with src. alias appended
Not super useful on its own but when you're generating anything else here like a merge I figured it was handy to have
*/
SELECT 'src.[' + c.name + '],' AS SRCSelector 
FROM 
sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
INNER JOIN sys.columns c ON c.object_id = o.object_id
WHERE s.name = @SchemaName AND 
o.name = @TableName
ORDER BY c.column_id


