name             "bitlbee"
maintainer       "Nils Landt"
maintainer_email "cookbooks@promisedlandt.de"
license          "MIT"
description      "Installs / configures bitlbee, the IRC to other chat networks gateway"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version          "1.0.0"

%w(apt runit gem_installation stunnel build-essential).each { |dep| depends dep }

%w(ubuntu debian).each { |os| supports os }
