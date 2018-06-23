# DEVELOPER SETUP

* Ruby 2.3
* Postgres 10
* Elasticsearch



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
