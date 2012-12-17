mysql = require('mysql')

conn = new mysql.Client()
conn.user = process.env['MYSQL_USER']
conn.password = process.env['MYSQL_PASSWORD']
conn.database = 'mefi'

connDataDate = null
queryLimit = 200

exports.commentsBested = ({commenter, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select c.comment_id, c.post_id, c.created, p.title, p.deleted"
    "from #{site}_comment c"
    "join #{site}_post p on c.post_id = p.post_id"
    "where c.user_id = #{commenter.id} and c.best = 1"
    "and p.category = #{category}" if category
    "and c.created >= '#{expandStartDate(startDate)}'" if startDate
    "and c.created <= '#{expandEndDate(endDate)}'" if endDate
    "order by c.comment_id desc"
  ].join(" ")

  rows(sql, page, cb)

exports.commentsFavorited = ({commenter, faver, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select c.comment_id, c.post_id, c.created, p.title, p.deleted"
    "from #{site}_comment c"
    "join #{site}_post p on p.post_id = c.post_id"
    "join #{site}_favorite f on f.comment_id = c.comment_id"
    "where f.favee_id = #{commenter.id} and f.faver_id = #{faver.id}"
    "and p.category = #{category}" if category
    "and c.created >= '#{expandStartDate(startDate)}'" if startDate
    "and c.created <= '#{expandEndDate(endDate)}'" if endDate
    "order by c.comment_id desc"
  ].join(" ")

  rows(sql, page, cb)

exports.commentsFavorites = ({commenter, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select c.comment_id, c.favorites_count, c.post_id, c.created, p.title, p.deleted, c.user_id, u.name"
    "from #{site}_comment c"
    "join #{site}_post p on c.post_id = p.post_id"
    "join user u on c.user_id = u.id"
    "where c.favorites_count > 0"
    "and c.user_id = #{commenter.id}" if commenter
    "and p.category = #{category}" if category
    "and c.created >= '#{expandStartDate(startDate)}'" if startDate
    "and c.created <= '#{expandEndDate(endDate)}'" if endDate
    "order by c.favorites_count desc"
  ].join(" ")
  
  rows(sql, page, cb)

exports.commentsLongest = ({commenter, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select c.comment_id, c.length, c.created, c.post_id, p.title, p.deleted, c.user_id, u.name"
    "from #{site}_comment c"
    "join #{site}_post p on c.post_id = p.post_id"
    "join user u on c.user_id = u.id"
    "where 1"
    "and c.user_id = #{commenter.id}" if commenter
    "and p.category = #{category}" if category
    "and c.created >= '#{expandStartDate(startDate)}'" if startDate
    "and c.created <= '#{expandEndDate(endDate)}'" if endDate
    "order by c.length desc"
  ].join(" ")
        
  rows(sql, page, cb)

exports.faveesComments = ({faver, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  if faver
    sql = [
      "select u.id, u.name, count(u.id) as favorites_count"
      "from user u"
      "join #{site}_favorite f on f.favee_id = u.id"
      "join #{site}_comment c on f.comment_id = c.comment_id"
      "join #{site}_post p on c.post_id = p.post_id" if category
      "where c.favorites_count > 0"
      "and f.faver_id = #{faver.id}"
      "and p.category = #{category}" if category
      "and c.created >= '#{expandStartDate(startDate)}'" if startDate
      "and c.created <= '#{expandEndDate(endDate)}'" if endDate
      "group by c.user_id"
      "order by favorites_count desc"
    ].join(" ")
  else
    sql = [
      "select u.id, u.name, sum(c.favorites_count) as favorites_count"
      "from user u"
      "join #{site}_comment c on u.id = c.user_id"
      "join #{site}_post p on c.post_id = p.post_id" if category
      "where c.favorites_count > 0"
      "and p.category = #{category}" if category
      "and c.created >= '#{expandStartDate(startDate)}'" if startDate
      "and c.created <= '#{expandEndDate(endDate)}'" if endDate
      "group by c.user_id" 
      "order by favorites_count desc"
    ].join(" ")

  rows(sql, page, cb)

exports.faveesPosts = ({faver, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  if faver
    sql = [
      "select u.id, u.name, count(u.id) as favorites_count"
      "from user u"
      "join #{site}_favorite f on f.favee_id = u.id"
      "join #{site}_post p on f.post_id = p.post_id"
      "where favorites_count > 0"
      "and f.faver_id = #{faver.id}"
      "and f.comment_id = 0"
      "and p.category = #{category}" if category
      "and p.created >= '#{expandStartDate(startDate)}'" if startDate
      "and p.created <= '#{expandEndDate(endDate)}'" if endDate
      "group by u.id"
      "order by favorites_count desc"
    ].join(" ")
  else
    sql = [
      "select u.id, u.name, sum(p.favorites_count) as favorites_count"
      "from user u"
      "join #{site}_post p on u.id = p.user_id"
      "where favorites_count > 0"
      "and p.category = #{category}" if category
      "and p.created >= '#{expandStartDate(startDate)}'" if startDate
      "and p.created <= '#{expandEndDate(endDate)}'" if endDate
      "group by u.id"
      "order by favorites_count desc"
    ].join(" ")

  rows(sql, page, cb)

exports.faversComments = ({commenter, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0
  
  sql = [
    "select u.id, u.name, count(f.faver_id) as count"
    "from user u"
    "join #{site}_favorite f on f.faver_id = u.id"
    "join #{site}_post p on f.post_id = p.post_id" if category
    "where f.favee_id = #{commenter.id} and f.comment_id != 0"
    "and p.category = #{category}" if category
    "and f.created >= '#{expandStartDate(startDate)}'" if startDate
    "and f.created <= '#{expandEndDate(endDate)}'" if endDate
    "group by f.faver_id"
    "order by count desc"
  ].join(" ")

  rows(sql, page, cb)

exports.faversPosts = ({poster, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0
  
  sql = [
    "select u.id, u.name, count(f.faver_id) as count"
    "from user u"
    "join #{site}_favorite f on f.faver_id = u.id"
    "join #{site}_post p on f.post_id = p.post_id" if category
    "where f.favee_id = #{poster.id} and f.comment_id = 0"
    "and p.category = #{category}" if category
    "and f.created >= '#{expandStartDate(startDate)}'" if startDate
    "and f.created <= '#{expandEndDate(endDate)}'" if endDate
    "group by f.faver_id"
    "order by count desc"
  ].join(" ")

  rows(sql, page, cb)

exports.postsComments = ({poster, tag, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate, tag] = escapeQuotes(site, startDate, endDate, tag)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select p.post_id, p.title, p.deleted, p.comments_count, p.user_id, p.created, u.name"
    "from #{site}_post p"
    "join user u on p.user_id = u.id"
    "join #{site}_tag t on t.post_id = p.post_id" if tag
    "where p.comments_count > 0"
    "and p.user_id = #{poster.id}" if poster
    "and p.category = #{category}" if category
    "and p.created >= '#{expandStartDate(startDate)}'" if startDate
    "and p.created <= '#{expandEndDate(endDate)}'" if endDate
    "and t.name = '#{tag}'" if tag
    "order by p.comments_count desc"
  ].join(" ")

  rows(sql, page, cb)

exports.postsFavorited = ({poster, faver, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select p.post_id, p.title, p.deleted, p.created"
    "from #{site}_post p"
    "join #{site}_favorite f on f.post_id = p.post_id"
    "where f.favee_id = #{poster.id} and f.faver_id = #{faver.id} and f.comment_id = 0"
    "and p.category = #{category}" if category
    "and p.created >= '#{expandStartDate(startDate)}'" if startDate
    "and p.created <= '#{expandEndDate(endDate)}'" if endDate
    "order by p.post_id desc"
  ].join(" ")

  rows(sql, page, cb)

exports.postsFavorites = ({poster, tag, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate, tag] = escapeQuotes(site, startDate, endDate, tag)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select p.post_id, p.title, p.deleted, p.favorites_count, p.user_id, p.created, u.name"
    "from #{site}_post p"
    "join user u on p.user_id = u.id"
    "join #{site}_tag t on t.post_id = p.post_id" if tag
    "where p.favorites_count > 0"
    "and p.user_id = #{poster.id}" if poster
    "and p.category = #{category}" if category
    "and p.created >= '#{expandStartDate(startDate)}'" if startDate
    "and p.created <= '#{expandEndDate(endDate)}'" if endDate
    "and t.name = '#{tag}'" if tag
    "order by p.favorites_count desc"
  ].join(" ")

  rows(sql, page, cb)

exports.postsFavoritesCommentsRatio = ({poster, tag, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate, tag] = escapeQuotes(site, startDate, endDate, tag)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select p.post_id, p.title, p.deleted, p.favorites_count, p.comments_count, p.user_id, p.created, u.name"
    "from #{site}_post p"
    "join user u on p.user_id = u.id"
    "join #{site}_tag t on t.post_id = p.post_id" if tag
    "where p.comments_count > 0 and p.favorites_count > 0"
    "and p.user_id = #{poster.id}" if poster
    "and p.category = #{category}" if category
    "and p.created >= '#{expandStartDate(startDate)}'" if startDate
    "and p.created <= '#{expandEndDate(endDate)}'" if endDate
    "and t.name = '#{tag}'" if tag
    "order by (p.favorites_count / p.comments_count) desc"
  ].join(" ")

  rows(sql, page, cb)

exports.postsFind = ({username, title, tag, reason, commentsCount, favoritesCount, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate, username, title, tag, reason] = escapeQuotes(site, startDate, endDate, username, title, tag, reason)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0
  commentsCount = parseInt(commentsCount, 10)
  favoritesCount = parseInt(favoritesCount, 10)

  sql = [
    "select p.*, u.name as username"
    "from #{site}_post p"
    "join user u on p.user_id = u.id"
    "join #{site}_tag t on p.post_id = t.post_id" if tag
    "where 1"
    "and p.category = #{category}" if category
    "and p.created >= '#{expandStartDate(startDate)}'" if startDate
    "and p.created <= '#{expandEndDate(endDate)}'" if endDate
    "and u.name like '%#{username}%'" if username
    "and p.title like '%#{title}%'" if title
    "and t.name like '%#{tag}%'" if tag
    "and p.reason like '%#{reason}%'" if reason
    "and p.comments_count >= #{commentsCount}" if commentsCount > 0
    "and p.favorites_count >= #{favoritesCount}" if favoritesCount > 0
    "group by p.id"
    "order by p.id desc"
  ].join(" ")

  rows(sql, page, cb)

exports.postsLongest = ({poster, tag, site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate, tag] = escapeQuotes(site, startDate, endDate, tag)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select p.post_id, p.title, p.deleted, p.length, p.user_id, p.created, u.name"
    "from #{site}_post p"
    "join user u on p.user_id = u.id"
    "join #{site}_tag t on t.post_id = p.post_id" if tag
    "where 1"
    "and p.user_id = #{poster.id}" if poster
    "and p.category = #{category}" if category
    "and p.created >= '#{expandStartDate(startDate)}'" if startDate
    "and p.created <= '#{expandEndDate(endDate)}'" if endDate
    "and t.name = '#{tag}'" if tag
    "order by p.length desc"
  ].join(" ")

  rows(sql, page, cb)

exports.usersBest = ({site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select u.id, u.name, count(u.id) as comments_count"
    "from user u"
    "join #{site}_comment c on u.id = c.user_id"
    "join #{site}_post p on c.post_id = p.post_id"
    "where c.best = 1"
    "and p.category = #{category}" if category
    "and c.created >= '#{expandStartDate(startDate)}'" if startDate
    "and c.created <= '#{expandEndDate(endDate)}'" if endDate
    "group by u.id"
    "order by comments_count desc"
  ].join(" ")

  rows(sql, page, cb)

exports.usersComments = ({site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select u.id, u.name, count(c.user_id) as comments_count"
    "from user u"
    "join #{site}_comment c on u.id = c.user_id"
    "join #{site}_post p on c.post_id = p.post_id" if category
    "where 1"
    "and p.category = #{category}" if category
    "and c.created >= '#{expandStartDate(startDate)}'" if startDate
    "and c.created <= '#{expandEndDate(endDate)}'" if endDate
    "group by u.id"
    "order by comments_count desc"
  ].join(" ")

  rows(sql, page, cb)

exports.usersFind = ({username, page}, cb) ->
  [username] = escapeQuotes(username)
  page = parseInt(page, 10) || 0
  sql = [
    "select u.id, u.name"
    "from user u"
    "where 1"
    "and u.name like '%#{username}%'" if username
    "group by u.id"
  ].join(" ")

  rows(sql, page, cb)

exports.usersPosts = ({site, category, startDate, endDate, page}, cb) ->
  [site, startDate, endDate] = escapeQuotes(site, startDate, endDate)
  category = parseInt(category, 10) if category
  page = parseInt(page, 10) || 0

  sql = [
    "select u.id, u.name, count(p.user_id) as posts_count"
    "from user u"
    "join #{site}_post p on u.id = p.user_id"
    "where 1"
    "and p.category = #{category}" if category
    "and p.created >= '#{expandStartDate(startDate)}'" if startDate
    "and p.created <= '#{expandEndDate(endDate)}'" if endDate
    "group by p.user_id"
    "order by posts_count desc"
  ].join(" ")

  rows(sql, page, cb)

exports.userByName = (name, cb) ->
  return cb(null) if !name

  [name] = escapeQuotes(name)
  sql = "select * from user where name = '#{name}'"
  
  conn.query(sql, (errors, results, fields) ->
    console.error(errors) if errors
    cb(results?[0] || null)
  )

exports.userByID = (id, cb) ->
  return cb(null) if !id

  id = parseInt(id, 10)
  sql = "select * from user where id = #{id}"

  conn.query(sql, (errors, results, fields) ->
    console.error(errors) if errors
    cb(results?[0] || null)
  )

exports.dataDate = (cb) ->
  if connDataDate
    cb(connDataDate)
    return
    
  sql = 'select created from mefi_post order by created desc limit 1'

  conn.query(sql, (errors, results, fields) ->
    connDataDate = results[0].created
    cb(connDataDate)
  )

rows = (sql, page, cb) ->
  console.log(sql)
  conn.query("#{sql} limit #{queryLimit} offset #{page * queryLimit}", (errors, results, fields) ->
    console.error(errors) if errors
    cb(v for k,v of results)
  )

escapeQuotes = (args...) ->
  (if arg then arg.replace(/'/g, "''") else null) for arg in args
  
expandStartDate = (date) ->
  [y,m,d] = date.match(/^(\d\d\d\d)(?:-(\d\d))?(?:-(\d\d))?$/)[1..3]

  m = '01' if !m
  d = '01' if !d

  "#{y}-#{m}-#{d} 00:00:00"

expandEndDate = (date) ->
  [y,m,d] = date.match(/^(\d\d\d\d)(?:-(\d\d))?(?:-(\d\d))?$/)[1..3]

  m = '12' if !m
  d = '31' if !d

  "#{y}-#{m}-#{d} 23:59:59"
