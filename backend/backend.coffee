express     = require 'express'
session     = require 'express-session'
Q           = require 'q'
xxhash      = require 'xxhash'
bodyParser  = require 'body-parser'
passport    = require 'passport'
util        = require 'util'

mongoSessionStore = require 'connect-mongodb'

GoogleStrategy = require('passport-google').Strategy


mongo   = require 'mongodb'
BSON = mongo.BSONPure;

l = (msg) -> 
  console.log util.inspect(msg) + "\n" + ((new Error).stack.split "\n")[2]
  


config = 
  url:
    backend:    'http://localhost:3000'
    frontend:   'http://localhost:8080'
    
    home:       '/'
      
    auth:       '/auth/google'
    authReturn: '/auth/google/return'
    logout:     '/auth/logout'
  db:
    host: 'localhost'
    port: 27017
    name: 'worklog'
    
serverParams = 
  auto_reconnect: true

dbParams = 
  w: 1 # Default write concern.

db = new mongo.Db(config.db.name, new mongo.Server(config.db.host, config.db.port, serverParams), dbParams)

db.open (err,db) ->
  if err
    console.error "Can't connect!"
  db.authenticate config.db.username, config.db.password, () ->
    if err
      console.error "Can't authenticate!"
    setupServer()

mongo =
  query: (collection, query) ->
    Q.ninvoke db, "collection", collection
      .then (col) -> Q.ninvoke col, "find", query, { sort: [['order', 1]] }
      .then (cursor) -> Q.ninvoke cursor, "toArray"
    
  remove: (collection, query) ->
    Q.ninvoke db, "collection", collection
      .then (col) -> Q.ninvoke col, "remove", query, { single: true }
    
  update: (collection, query, data) ->
    delete data._id;
    Q.ninvoke db, "collection", collection
      .then (col) -> Q.ninvoke col, "update", query, data
    
  insert: (collection, data) ->
    Q.ninvoke db, "collection", collection
      .then (col) -> Q.ninvoke col, "insert", data
      .then (docs) -> docs[0]
    
  drop: (collection) ->
    Q.ninvoke db, "collection", collection
      .then (col) -> Q.ninvoke col, "drop"      

  upsert: (collection, query, update) ->
    Q.ninvoke db, "collection", collection
      .then (col) -> Q.ninvoke col, "findAndModify", query, [['_id', 1]], update, { upsert: true, new: true }
        .then ([doc, fullResult]) -> doc # findAndModify passes fullResult to its callback as last parameter on success


setupServer = -> 
  app = express()
  app.use bodyParser.json()
  
  app.use session
    secret: "dsfdfsdfsbcvbcvb###@$3423adsad"
    saveUninitialized: true
    resave: true
    store: new mongoSessionStore { db: db }

  app.use passport.initialize()
  app.use passport.session()
  
  app.get config.url.auth, passport.authenticate('google')
  app.get config.url.authReturn, passport.authenticate('google', { 
    successRedirect: config.url.frontend + config.url.home
    failureRedirect: config.url.frontend + config.url.home 
  })    

  passport.use new GoogleStrategy {
      returnURL: config.url.backend + config.url.authReturn
      realm: config.url.backend
  }, (identifier, profile, done) ->
    mongo.upsert "user", { openId: identifier }, { $set: profile }
      .then (user) ->
        l user
        done(null, user);
      .done()
      
  passport.serializeUser (user, done) ->
    done(null, user);
  
  passport.deserializeUser (user, done) ->
    done(null, user);
  

  setCORS = (res) ->
    res.set 'Access-Control-Allow-Origin', 'http://localhost:8080'
    res.set 'Access-Control-Allow-Methods', 'GET,PUT,DELETE,POST'
    res.set 'Access-Control-Allow-Headers', 'Content-Type'
    res.set 'Access-Control-Allow-Credentials', 'true'
    
  respond = (res, promise) ->
    promise
      .then (result) ->
        responseText = new Buffer(JSON.stringify(result), 'utf-8')
        res.set 'ETag', xxhash.hash(responseText, 0xCAFEBABE)
        res.set 'Content-Type', 'application/json'
        
        setCORS res
        
        res.send responseText
        
      .catch (err) ->
        setCORS res
        res.status(500).send({ message: err.err || err.errmsg })

  ID = (value) ->
    return new BSON.ObjectID(value)

  app.use /^((?!\/auth).)*$/, (req, res, next) ->
    if req.user || req.method == "OPTIONS"
      next()
    else
      setCORS res
      res.status(401).send('Unauthorized');

  app.get '/auth/google/logout', (req, res) ->
    req.logout();
    res.redirect("http://localhost:8080");
    
  app.post '/clear', (req, res) ->
    respond res, mongoDrop('task') 
    
  app.route '/:collection/:id'
    .get (req, res) -> 
      respond res, mongo.query  req.params.collection, { _id: ID(req.params.id) }
    .delete (req, res) -> 
      respond res, mongo.remove req.params.collection, { _id: ID(req.params.id) }
    .put (req, res) -> 
      respond res, mongo.update req.params.collection, { _id: ID(req.params.id) }, req.body

  app.route '/:collection'
    .post (req, res) -> 
      mongo.upsert "sequence", { name: req.params.collection }, { $inc: { lastOrder: 1 } }
        .then (r) ->
          respond res, mongo.insert req.params.collection, util._extend(req.body, { order: r.lastOrder })
    .get (req, res) -> 
      respond res, mongo.query  req.params.collection, {}

  app.options '*', (req, res) ->
    setCORS res
    res.send ""

  app.get '/', (req, res) ->
    res.send 'ok'


  app.listen 3000
