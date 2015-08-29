ReactBackboneCoffeescript
=========================

Experiments in React, Backbone models and collections and Cofeescript


Recent changes:

Toy PHP backend was obsoleted.

New backend was implemented as express.js web app.

To start backend (http://localhost:3000/) you need to have mongodb and cofeescript installed on your machine and do:

	sudo npm install -g bower supervisor gulp
	npm install
	cd backend
	supervisor -x coffee --watch backend.coffee -- backend.coffee <google_client_id> <google_client_secret>

To start serving frontend (http://localhost:8080/) you need to do:

	gulp
