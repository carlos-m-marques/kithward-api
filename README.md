# DEVELOPER SETUP

* Ruby 2.5
* Node 9
* [Postgres 10](https://postgresapp.com/)
* Elasticsearch
* [Heroku toolbelt](https://devcenter.heroku.com/articles/heroku-cli)


```
# As of September 2018
export KW_ROOT=~/Work/kw
export KW_RUBY_VERSION=2.5.1
export KW_NODE_VERSION=9

#== Mac specific setup ==
# Homebrew
xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# Ruby
brew install rbenv && rbenv install $KW_RUBY_VERSION
rbenv shell $KW_RUBY_VERSION && gem install bundler
# Node
brew install nvm
nvm install $KW_NODE_VERSION
# Postgres
brew install postgresql
# Elasticsearch
brew cask install homebrew/cask-versions/java8
brew install elasticsearch
# Heroku
brew install heroku/brew/heroku

#== Backend ==============
mkdir $KW_ROOT
cd $KW_ROOT
git clone git@github.com:kithward/api.git
cd api
bundle install --path .gems
rails db:create
# You'll need to procure a master.key file from someone else in the team.

#== Frontend ==============
cd $KW_ROOT
git clone git@github.com:kithward/web.git
cd web
npm install
```

### Regular workflow
```
# API tests
brew services start postgresql
brew services start elasticsearch
cd $KW_ROOT/api
rails test
rails console
rails server

# Frontend
cd $KW_ROOT/web
npm run startdev

# Running postgres directly
pg_ctl -D /usr/local/var/postgres start

# Running elasticsearch directly
elasticsearch
```



## Heroku Notes

Seed your local database from production

```
dropdb kw_development # or rails db:drop
heroku pg:pull DATABASE_URL kw_development -a kwapi
rails runner 'Community.reindex; GeoPlace.reindex; Poi.reindex'
```

Copy production data to staging

```
heroku pg:copy kwapi::DATABASE_URL DATABASE_URL --app kwapi-staging
heroku run rails runner 'Community.reindex; GeoPlace.reindex; Poi.reindex' -a  kwapi-staging
```

Create an admin account for Upwork people

```
heroku run rails c
Account.create(name: "Upwork First Last", password: "{some random password}", email: "upwork+fl@kithward.com", verified_email: "upwork+fl@kithward.com", is_admin: true)
```

## ElasticSearch notes

Local development server, os x with brew:

Data:    `/usr/local/var/lib/elasticsearch/elasticsearch_{username}/`
Logs:    `/usr/local/var/log/elasticsearch/elasticsearch_{username}.log`
Plugins: `/usr/local/var/elasticsearch/plugins/`
Config:  `/usr/local/etc/elasticsearch/`

To have launchd start elasticsearch now and restart at login:
  `brew services start elasticsearch`
Or, if you don't want/need a background service you can just run:
  `elasticsearch`


cluster.routing.allocation.disk.threshold_enabled: false


## Postgres notes

#### JSON Queries

```sql
-- Look for specific key/value pairs
SELECT * FROM communities WHERE data @> '{"star_rating": 5}';

-- Rows that have one key
SELECT * FROM communities WHERE data ? 'activity_trivia';

-- Rows that have at least one of a list of keys
SELECT * FROM communities WHERE data ?| array['activity_bridge', 'activity_trivia'];

-- Rows that have all keys in a list of keys
SELECT * FROM communities WHERE data ?& array['activity_bridge', 'activity_trivia'];
```

More info at https://schinckel.net/2014/05/25/querying-json-in-postgres/


## TROUBLESHOOTING

#### Getting "high disk watermark exceeded on one or more nodes" in elasticsearch logs?

ElasticSearch likes to have at least 10% free space on disk. *If you see this
in production, it might be time to get more servers*.
But on development machines it is ok to disable this option.

Edit `/usr/local/etc/elasticsearch/elasticsearch.yml` and add
`cluster.routing.allocation.disk.threshold_enabled: false` in the `Cluster` section

## Clone Prod DB notes

#### Error when doing the db-cloning

If there is any error when cloning, it may be that the HEROKU_API_KEY has expired
Maybe it will need to run the following command locally again
```
heroku config:set HEROKU_API_KEY=`heroku auth:token` -a _HEROKU_APP_NAME_
```
