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

  mongoQuery = (collection, query) ->
    dfd = Q.defer()
    db.collection collection, (err, collection) ->
      dfd.reject err if err
      collection.find query, (err, cursor) ->
        dfd.reject err if err
        cursor.toArray (err, docs) ->
          dfd.reject err if err

          dfd.resolve docs

    dfd.promise
    
    
  mongoRemove = (collection, query) ->
    dfd = Q.defer()
    db.collection collection, (err, collection) ->
      dfd.reject err if err
      collection.remove query, { single: true }, (err) ->
        dfd.reject err if err
        
        dfd.resolve {}

    dfd.promise
    
  mongoUpdate = (collection, query, data) ->
    delete data._id;
    
    dfd = Q.defer()
    db.collection collection, (err, collection) ->
      dfd.reject err if err
      collection.update query, data, (err) ->
        dfd.reject err if err
        
        dfd.resolve {}

    dfd.promise
    
  mongoInsert = (collection, data) ->
    dfd = Q.defer()
    db.collection collection, (err, collection) ->
      dfd.reject err if err
      collection.insert data, (err, docs) ->
        dfd.reject err if err

        dfd.resolve docs[0]

    dfd.promise
    
    
  mongoDrop = (collection) ->
    dfd = Q.defer()
    db.collection collection, (err, collection) ->
      dfd.reject err if err
      collection.drop (err) ->
        dfd.reject err if err
        
        dfd.resolve {}

    dfd.promise
    
  app.options '*', (req, res) ->
    setCORS res
    res.send ""

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

  app.post '/clear', (req, res) ->
    respond res, mongoDrop('task') 
    
  app.route '/:collection/:id'
    .get (req, res) -> 
      respond res, mongoQuery req.params.collection, {'_id': new BSON.ObjectID(req.params.id)}
    .put (req, res) -> 
      respond res, mongoUpdate req.params.collection, {'_id': new BSON.ObjectID(req.params.id)}, req.body
    .delete (req, res) -> 
      respond res, mongoRemove req.params.collection, {'_id': new BSON.ObjectID(req.params.id)}

  app.route '/:collection'
    .get (req, res) -> 
      respond res, mongoQuery req.params.collection, {}
    .post (req, res) -> 
      respond res, mongoInsert req.params.collection, req.body



  app.get '/', (req, res) ->
    res.send 'ok'

  app.listen 3000
