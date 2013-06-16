# Kaanta

Kaanta is an educational Unix preforking server and is a part of my talk at [RubyConf India 2013](http://rubyconfindia.org/2013/), titled, [Ruby loves Unix: Applying beautiful Unix idioms to build a Ruby prefork server](http://lanyrd.com/2013/rubyconfindia/schdhk/). It's meant to be a demonstration of classic unix idioms like concurrency via fork(2), IPC via signals and some not so common ones like fchmod(2) based worker heartbeat and signal handling via SELF_PIPE.

Most of the code has been gleaned from the [Unicorn Server](http://unicorn.bogomips.org/ "Unicorn Server"). I'm very thankful to Eric Wong and all contributors to Unicorn. I would also like to thank Jesse Storimer for writing the very approachable [Working With Unix Processes](http://www.jstorimer.com/products/working-with-unix-processes). It's an excellent book which got me thinking more deeply about Unix in general.

Kaanta executes arbitrary code sent by clients and is of course not meant to be used for anything important.



Kaanta is Hindi for fork.

## Usage
- `bundle install --path=.bundle`
- `bin/kaanta` starts up the kaanta server on `0.0.0.0:8080`
- `echo "ls" | nc localhost 8080` will execute the `ls` command on any of the 3 spawned workers and return it's output to the client.
- See `bin/kaanta --help` for options.

## License

Contains code from the [Unicorn Server](http://unicorn.bogomips.org/ "Unicorn Server"), [LICENSE](http://unicorn.bogomips.org/LICENSE.html) Copyright (c) Eric Wong et al.

Copyright (c) 2013 Sahil Muthoo

MIT License
