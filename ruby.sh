#!/bin/bash

# Lets get Ruby and RVM
\curl -sSL https://get.rvm.io | bash -s stable --ruby

# To load it into our current session
rvm reload

# Now we can get our gem
gem install cupertino

git clone https://github.com/nomad/cupertino.git
