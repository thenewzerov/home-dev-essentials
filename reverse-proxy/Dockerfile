FROM nginx:alpine

# Copy custom nginx configuration template
COPY nginx.conf /etc/nginx/nginx.conf.template

# Expose port 80
EXPOSE 80

# Use envsubst to substitute environment variables and start nginx
CMD ["/bin/sh", "-c", "envsubst '${K8S_ADMIN_TOKEN} ${BACKEND_SERVER}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"]