# fluent-plugin-multiline-greenplum-log

[Fluentd](https://fluentd.org/) parser plugin for greenplum and Apache HAWQ log.

## Installation

### RubyGems

```
$ gem install fluent-plugin-multiline-greenplum-log
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-multiline-greenplum-log"
```

And then execute:

```
$ bundle
```

## Configuration

This parser need to work with in_tail plugin.

Config your fluentd to parse greenplum/HAWQ logs with this plugin:

    <source>
      @id gp_log
      @type tail
      path /home/gpadmin/data_directory/pg_log/*.csv  #this is your log path
      pos_file /var/log/gplogs.csv.pos
      <parse>
        @type multiline_greenplum_log   
      </parse>
      read_from_head true
      tag gp.*
    </source>

The parser plugin has following config options:

keys: your csv logs keys, we have provided default value, delete this line if you want use default value

format_firstline: you can use the default value if your log time format is not changed

## Copyright

* Copyright(c) 2018- Violet Cheng @Pivotal
* License
  * Apache License, Version 2.0
