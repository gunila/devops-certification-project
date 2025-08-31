# Use the base PHP + Apache image
FROM devopsedu/webapp

# Remove default index.html so it won't override PHP
RUN rm -f /var/www/html/index.html

# Copy your project into the container's web root
COPY website/ /var/www/html/

# Expose Apache default port
EXPOSE 80

# Start Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
