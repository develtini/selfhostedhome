FROM pihole/pihole:latest

RUN apk add --no-cache dnsdist jq supervisor knot-utils

COPY supervisor/supervisord.conf /etc/supervisord.conf
# COPY dnsdist/dnsdist.conf /etc/dnsdist.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]