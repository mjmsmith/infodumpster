SITE_NAMES = {'mefi': 'MetaFilter', 'askme': 'Ask MetaFilter', 'meta': 'MetaTalk', 'music': 'Music'}
SITE_COLORS = {'mefi': '#006699', 'askme': '#426746', 'meta': '#666666', 'music': '#333333'}
SITE_PREFIXES = {'mefi': 'www', 'askme': 'ask', 'meta': 'metatalk', 'music': 'music'}
SITE_SUFFIXES = {'mefi': 'mefi', 'askme': 'ask', 'meta': 'meta', 'music': 'music'}
SITE_INDEXES = {'mefi': 1, 'askme': 3, 'meta': 5, 'music': 8}
SITE_CATEGORIES = {
  'mefi': [
  ],
  'askme': [
    'computers &amp; internet',
    'technology',
    'home & garden',
    'work & money',
    'sports, hobbies, & recreation',
    'society & culture',
    'travel & transportation',
    'science & nature',
    'education',
    'health & fitness',
    'shopping',
    'food & drink',
    'writing & language',
    'human relations',
    'media & arts',
    'pets & animals',
    'religion & philosophy',
    'clothing, beauty, & fashion',
    'law & government',
    'grab bag'
  ],
  'meta': [
    'bugs',
    'feature requests',
    'etiquette/policy',
    'uptime',
    'MetaFilter-related',
    'general weblog-related',
    'ticketstub project',
    'MetaFilter gatherings',
    'MetaFilter Music',
    'Ask MetaFilter',
    'MeFi Podcast'
  ],
  'music': [
    'song',
    'talk post'
  ]
}

exports.helpers = {
  siteName: (site) ->
    SITE_NAMES[site]
  
  siteColor: (site) ->
    SITE_COLORS[site]

  siteCategories: (site) ->
    SITE_CATEGORIES[site]
  
  titleSuffix: (site, category, startDate, endDate) ->
    title = SITE_NAMES[site]
    
    if category
      title += " category \"#{SITE_CATEGORIES[site][category-1]}\""

    if startDate || endDate
      if startDate == endDate
        title += ' during ' + startDate
      else
        title += ' from ' + (startDate || 'day one')
        title += ' through ' + (endDate || 'now')
    title

  postsFindTitle: (username, title, tag, reason, commentsCount, favoritesCount, site, category, startDate, endDate) ->
    phrases = []
    
    phrases.push("the author's username contains \"#{username}\"") if username
    phrases.push("the title contains \"#{title}\"") if title
    phrases.push("a tag contains \"#{tag}\"") if tag
    phrases.push("the deletion reason contains \"#{reason}\"") if reason
    phrases.push("there are #{commentsCount} or more comments") if commentsCount
    phrases.push("there are #{favoritesCount} or more favorites") if favoritesCount
    title = "Find posts in #{exports.helpers.titleSuffix(site, category, startDate, endDate)}"
    title += " where #{phrases.join ' and '}" if phrases.length > 0
    
    title + "."

  postUrl: (site, id) ->
    "http://#{SITE_PREFIXES[site]}.metafilter.com/#{id}/"

  postsActivityUrl: (site, id) ->
    "http://metafilter.com/activity/#{id}/posts/#{SITE_SUFFIXES[site]}/"

  postFavoritesUrl: (site, id) ->
    "http://#{SITE_PREFIXES[site]}.metafilter.com/favorited/#{SITE_INDEXES[site]}/#{id}"

  postsFavoritedUrl: (site, category, posterID, faverID, startDate, endDate) ->
    "/posts/favorited?site=#{site}&category=#{category}&poster_id=#{posterID}&faver_id=#{faverID}&start_date=#{startDate}&end_date=#{endDate}"

  commentUrl: (site, postID, commentID) ->
    "http://#{SITE_PREFIXES[site]}.metafilter.com/#{postID}##{commentID}"

  commentsActivityUrl: (site, id) ->
    "http://metafilter.com/activity/#{id}/comments/#{SITE_SUFFIXES[site]}/"

  commentFavoritesUrl: (site, id) ->
    "http://#{SITE_PREFIXES[site]}.metafilter.com/favorited/#{SITE_INDEXES[site]+1}/#{id}"

  commentsFavoritedUrl: (site, category, commenterID, faverID, startDate, endDate) ->
    "/comments/favorited?site=#{site}&category=#{category}&commenter_id=#{commenterID}&faver_id=#{faverID}&start_date=#{startDate}&end_date=#{endDate}"

  commentsBestedUrl: (site, category, commenterID, startDate, endDate) ->
    "/comments/bested?site=#{site}&category=#{category}&commenter_id=#{commenterID}&start_date=#{startDate}&end_date=#{endDate}"

  titleHtml: (title, deleted) ->
    klass = if deleted then "deleted" else ""
    "<span class=\"#{klass}\">#{title}</span>"

  profileUrl: (id) ->
    "http://metafilter.com/user/#{id}"
    
  date: (d) ->
    d.format("yyyy-MM-dd")
}
