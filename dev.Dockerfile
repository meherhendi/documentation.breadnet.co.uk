FROM squidfunk/mkdocs-material:latest as BUILDER
WORKDIR /app

ENV color=red
ENV env="Development Server"
ENV nav="navigation.expand"
ENV domain="https://dev-documentation.breadnet.co.uk"
ENV dir="overrides-dev"

COPY mkdocs.yml /app/mkdocs.yml
COPY overrides /app/overrides
COPY dev-robots.txt /app/docs/robots.txt
COPY docs /app/docs

RUN ["mkdocs", "build"]

FROM nginx:stable-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY cloudflare.conf /etc/nginx/cloudflare.conf
COPY deny.conf /etc/nginx/deny.conf
COPY .htpasswd /etc/nginx/.htpasswd

COPY --from=BUILDER /app/site/assets /var/www/documentation/assets
COPY --from=BUILDER /app/site /var/www/documentation

HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1"

EXPOSE 80
