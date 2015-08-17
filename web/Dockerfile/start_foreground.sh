#!/bin/bash

#apachectl -e info -DFOREGROUND
apachectl start
tail -f /var/log/apache2/access.log



