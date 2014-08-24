express 		= require 'express'
Q 					= require 'q'
xxhash  		= require 'xxhash'
bodyParser 	= require 'body-parser'

mongo   = require 'mongodb'
BSON = mongo.BSONPure;

l = console.log.bind console


config = 
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


  
setupServer = -> 

  app = express()
  app.use bodyParser.json() 

  handleError = (err, res) ->
    if err
      true

  mongo =
    query: (collection, query) ->
      Q.ninvoke db, "collection", collection
        .then (col) -> Q.ninvoke col, "find", query
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
      respond res, mongo.insert req.params.collection, req.body
    .get (req, res) -> 
      respond res, mongo.query  req.params.collection, {}

  app.options '*', (req, res) ->
    setCORS res
    res.send ""

  app.get '/', (req, res) ->
    res.send 'ok'


  app.listen 3000
