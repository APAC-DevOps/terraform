#!/bin/bash
yum -y install puppet
mkdir -p /etc/puppet/moduels
puppet module install jfryman-nginx
