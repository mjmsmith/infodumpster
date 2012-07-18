# Create and load the _post table.

DROP TABLE IF EXISTS ${site}_post;
CREATE TABLE ${site}_post (
  id int(11) NOT NULL AUTO_INCREMENT,
  post_id int(11) NOT NULL,
  user_id int(11) NOT NULL,
  created datetime NOT NULL,
  category int(11) NOT NULL,
  comments_count int(11) NOT NULL,
  favorites_count int(11) NOT NULL,
  length int(11) NOT NULL,
  deleted int(11) NOT NULL,
  reason varchar(255) NOT NULL,
  title varchar(255) NOT NULL,
  PRIMARY KEY (id),
  KEY user_id (user_id),
  UNIQUE KEY post_id (post_id),
  KEY comments_count (comments_count),
  KEY favorites_count (favorites_count),
  KEY length (length)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'postdata_${site}.txt' REPLACE INTO TABLE ${site}_post CHARACTER SET utf8
LINES TERMINATED BY '\r\n' IGNORE 2 LINES (
  post_id,user_id,created,category,comments_count,favorites_count,deleted,reason
);

# Create and load the temp post title table.

DROP TABLE IF EXISTS title;
CREATE TABLE title (
  id int(11) NOT NULL AUTO_INCREMENT,
  post_id int(11) NOT NULL,
  title varchar(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'posttitles_${site}.txt' REPLACE INTO TABLE title CHARACTER SET utf8
LINES TERMINATED BY '\r\n' IGNORE 2 LINES (
  post_id,title
);

# Update the _post table and drop the temp title table.

UPDATE ${site}_post p, title t SET p.title = t.title WHERE p.post_id = t.post_id;
UPDATE ${site}_post SET title = CONCAT('(',post_id,')') WHERE title = '';
UPDATE ${site}_post SET reason = '' WHERE reason = '[NULL]';
DROP TABLE title;

# Create and load the temp post length table.

DROP TABLE IF EXISTS length;
CREATE TABLE length (
  id int(11) NOT NULL AUTO_INCREMENT,
  post_id int(11) NOT NULL,
  title int(11) NOT NULL,
  above int(11) NOT NULL,
  below int(11) NOT NULL,
  url int(11) NOT NULL,
  urldesc int(11) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'postlength_${site}.txt' REPLACE INTO TABLE length CHARACTER SET utf8
LINES TERMINATED BY '\r\n' IGNORE 2 LINES (
  post_id,title,above,below,url,urldesc
);

# Update the _post table and drop the temp length table.

UPDATE ${site}_post p, length l SET p.length = (l.above + l.below + l.urldesc) WHERE p.post_id = l.post_id;
DROP TABLE length;

# Create and load the _comment table.

DROP TABLE IF EXISTS ${site}_comment;
CREATE TABLE ${site}_comment (
  id int(11) NOT NULL AUTO_INCREMENT,
  best int(11) NOT NULL,
  comment_id int(11) NOT NULL,
  created datetime NOT NULL,
  post_id int(11) NOT NULL,
  user_id int(11) NOT NULL,
  favorites_count int(11) NOT NULL,
  length int(11) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY comment_id (comment_id),
  KEY post_id (post_id),
  KEY user_id (user_id),
  KEY favorites_count (favorites_count),
  KEY length (length)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'commentdata_${site}.txt' REPLACE INTO TABLE ${site}_comment CHARACTER SET utf8
LINES TERMINATED BY '\r\n' IGNORE 2 LINES (
  comment_id,post_id,user_id,created,favorites_count,best
);

# Create and load the temp commment length table.

DROP TABLE IF EXISTS length;
CREATE TABLE length (
  id int(11) NOT NULL AUTO_INCREMENT,
  comment_id int(11) NOT NULL,
  length int(11) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'commentlength_${site}.txt' REPLACE INTO TABLE length CHARACTER SET utf8
LINES TERMINATED BY '\r\n' IGNORE 2 LINES (
  comment_id,length
);

# Update the _comment table and drop the temp length table.

UPDATE ${site}_comment c, length l SET c.length = l.length WHERE c.comment_id = l.comment_id;
DROP TABLE length;

# Create and load the _tag table.

DROP TABLE IF EXISTS ${site}_tag;
CREATE TABLE ${site}_tag (
  id int(11) NOT NULL AUTO_INCREMENT,
  post_id int(11) NOT NULL,
  created datetime NOT NULL,
  name varchar(255) NOT NULL,
  PRIMARY KEY (id),
  KEY post_id (post_id),
  KEY name (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'tagdata_${site}.txt' REPLACE INTO TABLE ${site}_tag CHARACTER SET utf8
LINES TERMINATED BY '\r\n' IGNORE 2 LINES (
  id,post_id,created,name
);

