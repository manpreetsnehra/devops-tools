FROM public.ecr.aws/docker/library/debian:latest

RUN apt-get -q update -y \
    && apt-get -q install -y nginx-full git \
    && rm -rf /var/lib/apt/lists/*

COPY default.conf /etc/nginx/sites-available/default
EXPOSE 80
CMD ["nginx","-g", "daemon off;"] 