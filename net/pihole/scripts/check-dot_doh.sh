#!/bin/bash

# Check DoH
kdig @localhost#5443 example.org +tls-host=${DOMAIN} +https=/dns-query

