infodumpster
============

The **infodumpster** is a tool to analyze [MetaFilter](http://metafilter.com) [infodump](http://stuff.metafilter.com/infodump/) data.  It lives at [infodumpster.org](http://infodumpster.org).

Prerequisites
=============

Node.js v0.8x and MySQL 5.x.

Installation
============

**npm install** dependencies.

Create the database **mefi**.

Set the environment variables **MYSQL\_USER** and **MYSQL\_PASSWORD** (or edit references in db.coffee and bin/import).

Run **bin/download** to grab a fresh copy of the MetaFilter infodump.

Run **bin/import** to import it into the database.

Run **node server.js** to start the server.
