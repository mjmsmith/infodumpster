DROP TABLE IF EXISTS favorite;
CREATE TABLE favorite (
  id int(11) NOT NULL AUTO_INCREMENT,
  created datetime NOT NULL,
  favee_id int(11) NOT NULL,
  faver_id int(11) NOT NULL,
  post_id int(11) NOT NULL,
  comment_id int(11) NOT NULL,
  type int(11) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'favoritesdata.txt' REPLACE INTO TABLE favorite
LINES TERMINATED BY '\r\n' IGNORE 2 LINES (
  id,faver_id,favee_id,type,comment_id,post_id,created
);

DROP TABLE IF EXISTS mefi_favorite;
CREATE TABLE mefi_favorite (
  id int(11) NOT NULL AUTO_INCREMENT,
  created datetime NOT NULL,
  favee_id int(11) NOT NULL,
  faver_id int(11) NOT NULL,
  post_id int(11) NOT NULL,
  comment_id int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY favee_id (favee_id),
  KEY faver_id (faver_id),
  KEY post_id (post_id),
  KEY comment_id (comment_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
AS SELECT created,favee_id,faver_id,post_id,comment_id FROM favorite WHERE type IN (1,2);
UPDATE mefi_favorite SET post_id=comment_id, comment_id=0 WHERE post_id=0;

DROP TABLE IF EXISTS askme_favorite;
CREATE TABLE askme_favorite (
  id int(11) NOT NULL AUTO_INCREMENT,
  created datetime NOT NULL,
  favee_id int(11) NOT NULL,
  faver_id int(11) NOT NULL,
  post_id int(11) NOT NULL,
  comment_id int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY favee_id (favee_id),
  KEY faver_id (faver_id),
  KEY post_id (post_id),
  KEY comment_id (comment_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
AS SELECT created,favee_id,faver_id,post_id,comment_id FROM favorite WHERE type IN (3,4);
UPDATE askme_favorite SET post_id=comment_id, comment_id=0 WHERE post_id=0;

DROP TABLE IF EXISTS meta_favorite;
CREATE TABLE meta_favorite (
  id int(11) NOT NULL AUTO_INCREMENT,
  created datetime NOT NULL,
  favee_id int(11) NOT NULL,
  faver_id int(11) NOT NULL,
  post_id int(11) NOT NULL,
  comment_id int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY favee_id (favee_id),
  KEY faver_id (faver_id),
  KEY post_id (post_id),
  KEY comment_id (comment_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
AS SELECT created,favee_id,faver_id,post_id,comment_id FROM favorite WHERE type IN (5,6);
UPDATE meta_favorite SET post_id=comment_id, comment_id=0 WHERE post_id=0;

DROP TABLE IF EXISTS music_favorite;
CREATE TABLE music_favorite (
  id int(11) NOT NULL AUTO_INCREMENT,
  created datetime NOT NULL,
  favee_id int(11) NOT NULL,
  faver_id int(11) NOT NULL,
  post_id int(11) NOT NULL,
  comment_id int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY favee_id (favee_id),
  KEY faver_id (faver_id),
  KEY post_id (post_id),
  KEY comment_id (comment_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
AS SELECT created,favee_id,faver_id,post_id,comment_id FROM favorite WHERE type IN (8,9);
UPDATE music_favorite SET post_id=comment_id, comment_id=0 WHERE post_id=0;

DROP TABLE favorite;
