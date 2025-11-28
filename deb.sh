#!/bin/bash

systemctl reload apache2
cp -r /var/cache/apt/archives/depot/ /var/www/html/depots




