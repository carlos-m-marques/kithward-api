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


cluster.routing.allocation.disk.threshold_enabled: false



## TROUBLESHOOTING

#### Getting "high disk watermark exceeded on one or more nodes" in elasticsearch logs?

ElasticSearch likes to have at least 10% free space on disk. *If you see this
in production, it might be time to get more servers*. 
But on development machines it is ok to disable this option.

Edit `/usr/local/etc/elasticsearch/elasticsearch.yml` and add
`cluster.routing.allocation.disk.threshold_enabled: false` in the `Cluster` section
