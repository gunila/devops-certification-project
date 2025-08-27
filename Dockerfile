# Use the base PHP + Apache image
FROM devopsedu/webapp

# Copy your PHP project into the container's web root
COPY website/ /var/www/html/

# Expose port 80 (Apache default)
EXPOSE 80
