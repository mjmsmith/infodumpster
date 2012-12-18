express = require("express")
stylus = require("stylus")
argv = require("optimist").default("port", 3000).argv

require("./lib/date")
db = require("./db")

renderError = (err, req, res) ->
  res.render "error", {
    error: err.message
    site: req.query.site
  }

preprocessQuery = (req, res, next) ->
  for own key, value of req.query
    req.query[key] = value[0] if Object.prototype.toString.call(value) == "[object Array]"
  next()

baseArgs = (req) ->
  {
    site: req.query.site
    category: req.query.category
    startDate: req.query.start_date
    endDate: req.query.end_date
    page: req.query.page
  }

app = module.exports = express()

app.configure ->
  app.set('views', "#{__dirname}/views")
  app.set("view engine", "jade")
  app.use(express.errorHandler({dumpExceptions: true, showStack: true}))
  app.use(express.favicon())
  app.use(stylus.middleware({src: "#{__dirname}/views", dest: "#{__dirname}/public"}))
  app.use(express.static("#{__dirname}/public"))
  app.locals(require('./helpers').helpers)

app.get "/", (req, res) ->
  db.dataDate (date) ->
    res.render "index", {
      dataDate: date.format("dd MMM yyyy")
      site: "mefi"
    }
  
app.get "/comments/bested", preprocessQuery, (req, res) ->
  db.userByID req.query.commenter_id, (commenter) ->
    return renderError(new Error("Unknown user."), req, res) if !commenter
    args = baseArgs req
    args.commenter = commenter
    db.commentsBested args, (comments) ->
      args.comments = comments
      res.render "comments_bested", args

app.get "/comments/favorited", preprocessQuery, (req, res) ->
  db.userByID req.query.commenter_id, (commenter) ->
    return renderError(new Error("Unknown user."), req, res) if !commenter
    db.userByID req.query.faver_id, (faver) ->
      return renderError(new Error("Unknown user."), req, res) if !faver
      args = baseArgs req
      args.commenter = commenter
      args.faver = faver
      db.commentsFavorited args, (comments) ->
        args.comments = comments
        res.render "comments_favorited", args

app.get "/comments/favorites", preprocessQuery, (req, res) ->
  db.userByName req.query.commenter_name, (commenter) ->
    return renderError(new Error("Unknown username."), req, res) if req.query.commenter_name && !commenter
    args = baseArgs req
    args.commenter = commenter
    db.commentsFavorites args, (comments) ->
      args.comments = comments
      res.render "comments_favorites", args

app.get "/comments/longest", preprocessQuery, (req, res) ->
  db.userByName req.query.commenter_name, (commenter) ->
    return renderError(new Error("Unknown username."), req, res) if req.query.commenter_name && !commenter
    args = baseArgs req
    args.commenter = commenter
    db.commentsLongest args, (comments) ->
      args.comments = comments
      res.render "comments_longest", args

app.get "/favees/comments", preprocessQuery, (req, res) ->
  db.userByName req.query.faver_name, (faver) ->
    return renderError(new Error("Unknown username."), req, res) if req.query.faver_name && !faver
    args = baseArgs req
    args.faver = faver
    db.faveesComments args, (users) ->
      args.users = users
      res.render "favees_comments", args

app.get "/favees/posts", preprocessQuery, (req, res) ->
  db.userByName req.query.faver_name, (faver) ->
    return renderError(new Error("Unknown username."), req, res) if req.query.faver_name && !faver
    args = baseArgs req
    args.faver = faver
    db.faveesPosts args, (users) ->
      args.users = users
      res.render "favees_posts", args

app.get "/favers/comments", preprocessQuery, (req, res) ->
  db.userByName req.query.commenter_name, (commenter) ->
    return renderError(new Error("Unknown username."), req, res) if !commenter
    args = baseArgs req
    args.commenter = commenter
    db.faversComments args, (favers) ->
      args.favers = favers
      res.render "favers_comments", args

app.get "/favers/posts", preprocessQuery, (req, res) ->
  db.userByName req.query.poster_name, (poster) ->
    return renderError(new Error("Unknown username."), req, res) if !poster
    args = baseArgs req
    args.poster = poster
    db.faversPosts args, (favers) ->
      args.favers = favers
      res.render "favers_posts", args

app.get "/posts/comments", preprocessQuery, (req, res) ->
  db.userByName req.query.poster_name, (poster) ->
    return renderError(new Error("Unknown username."), req, res) if req.query.poster_name && !poster
    args = baseArgs req
    args.tag = req.query.tag
    args.poster = poster
    db.postsComments args, (posts) ->
      args.posts = posts
      res.render "posts_comments", args

app.get "/posts/favorited", preprocessQuery, (req, res) ->
  db.userByID req.query.poster_id, (poster) ->
    return renderError(new Error("Unknown user."), req, res) if !poster
    db.userByID req.query.faver_id, (faver) ->
      return renderError(new Error("Unknown user."), req, res) if !faver
      args = baseArgs req
      args.poster = poster
      args.faver = faver
      db.postsFavorited args, (posts) ->
        args.posts = posts
        res.render "posts_favorited", args

app.get "/posts/favorites", preprocessQuery, (req, res) ->
  db.userByName req.query.poster_name, (poster) ->
    return renderError(new Error("Unknown username."), req, res) if req.query.poster_name && !poster
    args = baseArgs req
    args.tag = req.query.tag
    args.poster = poster
    db.postsFavorites args, (posts) ->
      args.posts = posts
      res.render "posts_favorites", args

app.get "/posts/favorites_comments_ratio", preprocessQuery, (req, res) ->
  db.userByName req.query.poster_name, (poster) ->
    return renderError(new Error("Unknown username."), req, res) if req.query.poster_name && !poster
    args = baseArgs req
    args.tag = req.query.tag
    args.poster = poster
    db.postsFavoritesCommentsRatio args, (posts) ->
      args.posts = posts
      res.render "posts_favorites_comments_ratio", args

app.get "/posts/find", preprocessQuery, (req, res) ->
  args = baseArgs req
  args.username = req.query.username
  args.title = req.query.title
  args.tag = req.query.tag
  args.reason = req.query.reason
  args.commentsCount = req.query.comments_count
  args.favoritesCount = req.query.favorites_count
  db.postsFind args, (posts) ->
    args.posts = posts
    res.render "posts_find", args

app.get "/posts/longest", preprocessQuery, (req, res) ->
  db.userByName req.query.poster_name, (poster) ->
    return renderError(new Error("Unknown username."), req, res) if req.query.poster_name && !poster
    args = baseArgs req
    args.tag = req.query.tag
    args.poster = poster
    db.postsLongest args, (posts) ->
      args.posts = posts
      res.render "posts_longest", args

app.get "/users/best", preprocessQuery, (req, res) ->
  args = baseArgs req
  db.usersBest args, (users) ->
    args.users = users
    res.render "users_best", args

app.get "/users/comments", preprocessQuery, (req, res) ->
  args = baseArgs req
  db.usersComments args, (users) ->
    args.users = users
    res.render "users_comments", args

app.get "/users/find", preprocessQuery, (req, res) ->
  args = baseArgs req
  args.username = req.query.username
  db.usersFind args, (users) ->
    args.users = users
    res.render "users_find", args

app.get "/users/posts", preprocessQuery, (req, res) ->
  args = baseArgs req
  db.usersPosts args, (users) ->
    args.users = users
    res.render "users_posts", args

app.listen(argv.port)

console.log("running on port #{argv.port}...")
