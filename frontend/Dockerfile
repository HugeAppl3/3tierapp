FROM nginx:alpine

# Copy your HTML dashboard
COPY index.html /usr/share/nginx/html/index.html

# 1. Update Nginx to listen on 8080
# 2. Update the default config to use 8080 instead of 80
RUN sed -i 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf

# 3. Best Practice: Cloud Run injects $PORT, but 8080 is the standard
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]


#verify with live logs: gcloud beta run services logs tail frontend-web --region=us-central1