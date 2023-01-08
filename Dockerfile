FROM redis:7-alpine

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		openssl

COPY generate-keys.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-keys.sh && \
    /usr/local/bin/generate-keys.sh

RUN apk del --no-network .build-deps
