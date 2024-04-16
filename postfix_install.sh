#!/bin/bash

# Install postfix

# Silence the install dialog
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< postfix postfix/mailname string your.hostname.com
debconf-set-selections <<< postfix postfix/main_mailer_type string "Internet Site"

apt-get install postfix --assume-yes -y

apt-get install libsasl2-modules mailutils postfix-pcre -y
