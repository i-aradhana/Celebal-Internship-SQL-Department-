--FINAL PROJECT
--ARADHANA KIIT UNIVERSITY
--FILE SYSTEM
create table FileSystem
(NodeID int primary key,
NodeName nvarchar(20),
ParentID int,
SizeBytes int)

insert into FileSystem values(1,'Documents',NULL,NULL)
insert into FileSystem values(2,'Pictures',NULL,NULL)
insert into FileSystem values(3,'File1.txt',1,500)
insert into FileSystem values(4,'Folder1',1,NULL)
insert into FileSystem values(5,'Image.jpg',2,1200)
insert into FileSystem values(6,'Subfolder1',4,NULL)
insert into FileSystem values(7,'File2.txt',4,750)
insert into FileSystem values(8,'File3.txt',6,300)
insert into FileSystem values(9,'Folder2',2,NULL)
insert into FileSystem values(10,'File4.txt',9,250)

select * from FileSystem

WITH RecursiveCTE AS (
    -- Base case: Select all nodes with their immediate sizes
    SELECT 
        NodeID, 
        NodeName, 
        ParentID, 
        COALESCE(SizeBytes, 0) as SizeBytes
    FROM FileSystem
    WHERE SizeBytes IS NOT NULL

    UNION ALL

    -- Recursive case: Join each node with its parent, adding sizes
    SELECT 
        fs.NodeID,
        fs.NodeName,
        fs.ParentID,
        rcte.SizeBytes
    FROM FileSystem fs
    JOIN RecursiveCTE rcte ON fs.NodeID = rcte.ParentID
)
-- Aggregate the sizes for each node
SELECT 
    fs.NodeID, 
    fs.NodeName, 
    COALESCE(SUM(rcte.SizeBytes), 0) as SizeBytes
FROM FileSystem fs
LEFT JOIN RecursiveCTE rcte ON fs.NodeID = rcte.NodeID
GROUP BY fs.NodeID, fs.NodeName
ORDER BY fs.NodeID;

