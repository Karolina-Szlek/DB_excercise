-- Karolina Szlęk, mpy

-- Zadanie 1

(SELECT id, displayname, reputation, count  
FROM (SELECT owneruserid, COUNT(*) 
FROM (SELECT owneruserid, postid 
FROM (SELECT postid FROM public.postlinks
	WHERE linktypeid = 3) X
JOIN posts ON(X.postid = posts.id)) as A GROUP BY 1) as Y
JOIN users ON (Y.owneruserid = users.id))
ORDER BY 4 DESC, displayname;


-- Zadanie 2

SELECT u.id, u.displayname, u.reputation, COUNT(c.postid) AS commentsCount, AVG(c.score) AS averagePostsScore
FROM users u
	JOIN badges b ON u.id = b.userid
    LEFT JOIN posts p ON u.id = p.owneruserid 
    LEFT JOIN comments c ON p.id = c.postid
WHERE b.name LIKE 'Fanatic'
GROUP BY u.id, u.displayname, u.reputation
HAVING COUNT(c.postid) < 101
ORDER BY 4 DESC, 2 ASC
LIMIT 20;


SELECT *
FROM(SELECT users.Id AS id,users.displayname AS displayname,users.reputation AS reputation,SUM(posts.CommentCount) AS sum
	FROM badges JOIN users ON badges.UserId=users.Id 
		JOIN posts ON posts.OwnerUserId=users.Id
	WHERE badges.Name = 'Fanatic'
	GROUP BY users.ID,users.displayname,users.reputation
	HAVING SUM(posts.CommentCount) <= 100 ) AS FQ
	NATURAL LEFT JOIN
	(SELECT users.Id AS id,users.displayname AS displayname,users.reputation AS reputation,AVG(comments.Score) AS avg
	FROM badges JOIN users ON badges.UserId=users.Id 
		JOIN posts ON posts.OwnerUserId=users.Id
		JOIN comments ON posts.Id=comments.PostId
	WHERE badges.Name = 'Fanatic'             
	GROUP BY users.ID,users.displayname,users.reputation) AS SQ
ORDER BY 4 DESC,2
LIMIT 20;


-- Zadanie 3

ALTER TABLE users 
ADD CONSTRAINT id PRIMARY KEY(id);
ALTER TABLE badges
ADD CONSTRAINT userid FOREIGN KEY(userid)
REFERENCES users(id);
ALTER TABLE posts
DROP COLUMN viewcount;
DELETE FROM posts 
WHERE posts.body IS NULL OR posts.body like '';


-- Zadanie 4

CREATE SEQUENCE posts_id_seq;
SELECT setval('posts_id_seq', MAX(id)) 
FROM posts;
ALTER TABLE posts 
ALTER COLUMN id SET DEFAULT nextval('posts_id_seq');
ALTER SEQUENCE posts_id_seq OWNED BY posts.id;
INSERT INTO posts (posttypeid, parentid, owneruserid, body, score, creationdate)
SELECT 3, c.postid, c.userid, c.text, c.score, c.creationdate
FROM comments c;




