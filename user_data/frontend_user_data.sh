#!/bin/bash
sudo apt update -y
sudo apt install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create a simple index.html page
echo "<h1>Hello from Frontend EC2 (Nginx)!</h1>" | sudo tee /var/www/html/index.html

# Optional: Configure Nginx to serve this basic index.html
# Nginx typically serves from /var/www/html by default,
# but it's good practice to ensure the default server block is correct.
# This ensures it's pointing to the correct root.
# This part is often not strictly needed for a basic index.html,
# but included for completeness if you had custom Nginx configurations.

#Back up default Nginx config
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

 Create a new default Nginx config (optional, depends on your needs)
 sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOF
 server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

     server_name _;

    location / {
        try_files \$uri \$uri/ =404;
     }
}
EOF'

Test Nginx configuration (if you made changes)
sudo nginx -t

Reload Nginx (if you made changes to config)
sudo systemctl reload nginx