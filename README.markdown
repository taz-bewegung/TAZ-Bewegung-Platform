# Welcome to bewegung.taz.de

## Installation

* gem install bundler
* bundle install
* rake db:create
* rake db:migrate
* rails server


## RVM problems

###  Iconv error:

* rvm package install iconv
* rvm remove 1.9.2
* rvm install 1.9.2 --with-iconv-dir=$rvm_path/usr