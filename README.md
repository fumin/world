# iServe - web server part
## Common commands
1. To start the server
        zbatery -p 9292 -c config/rainbows.rb
2. To enter console
        irb -r ./web.rb

## How to build zeromq C binaries in heroku
1. Enter our heroku dyno by running `heroku run bash --remote heroku`
2. Inside heroku, `cd /tmp`
3. In heroku, `curl -O http://download.zeromq.org/zeromq-3.2.0-rc1.tar.gz`
4. `tar zxf zeromq-3.2.0.tar.gz; cd zeromq-3.2.0`
5. `mkdir build`
6. `./configure --prefix=/tmp/zeromq-3.2.0/build; make; make install`
7. At this moment, you should see the binaries residing in build/lib,
   fetch them back by running `scp build/lib/libzmq.* fumin@nandalu.idv.tw:/home/fumin`
8. In our project, place these binaries under `lib/ffi-rzmq/ext/`

## Other parts of iServe
* iOS app https://github.com/fumin/rubymotion-zeromq
* zeromq majordomo broker https://github.com/fumin/mdbroker
