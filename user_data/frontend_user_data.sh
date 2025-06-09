#!/bin/bash
set -e

# Log all steps for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting frontend setup..."

# Update system packages
sudo apt update -y
sudo apt install -y nginx git curl

# Install Node.js for frontend build
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installations
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# Remove default nginx content
sudo rm -rf /var/www/html/*

# Create a simple index.html immediately to ensure something is served
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>EduCloud Frontend</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
    h1 { color: #333; }
  </style>
</head>
<body>
  <h1>EduCloud Frontend</h1>
  <p>Welcome to the EduCloud application.</p>
  <p>If you see this page, the web server is successfully installed and working.</p>
</body>
</html>
EOF

# Clone the EduCloud frontend repository
FRONTEND_REPO_URL="https://github.com/Adetola-Adedoyin/EduCloud-frontend-app.git"
cd /tmp
echo "Cloning repository from $FRONTEND_REPO_URL"
sudo git clone "$FRONTEND_REPO_URL" educloud-frontend || {
  echo "Failed to clone repository with sudo. Trying without sudo..."
  git clone "$FRONTEND_REPO_URL" educloud-frontend || {
    echo "Failed to clone repository. Using default page."
    exit 0
  }
}

cd educloud-frontend

# If it's a React/Vue/Angular app, build it
if [ -f "package.json" ]; then
  echo "Found package.json, installing dependencies..."
  npm install --no-fund --no-audit --loglevel=error || echo "npm install failed, continuing..."
  
  if grep -q "build" "package.json"; then
    echo "Building frontend application..."
    npm run build || echo "npm build failed, continuing..."
  fi
  
  # Copy build files to nginx directory
  if [ -d "build" ]; then
    echo "Copying build directory to /var/www/html"
    sudo cp -r build/* /var/www/html/
  elif [ -d "dist" ]; then
    echo "Copying dist directory to /var/www/html"
    sudo cp -r dist/* /var/www/html/
  else
    echo "No build or dist directory found, copying all files"
    sudo cp -r * /var/www/html/
  fi
else
  # If it's a simple HTML/CSS/JS app
  echo "No package.json found, copying all files to /var/www/html"
  sudo cp -r * /var/www/html/
fi

# Clean up
cd /
sudo rm -rf /tmp/educloud-frontend

# Set proper permissions for nginx
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Use a hardcoded backend IP for now
# You can update this after deployment with the actual backend private IP
BACKEND_SERVER_PRIVATE_IP="10.0.2.10"
echo "Using backend server IP: $BACKEND_SERVER_PRIVATE_IP"

# Create nginx configuration
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://${BACKEND_SERVER_PRIVATE_IP}/api/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /health {
        proxy_pass http://${BACKEND_SERVER_PRIVATE_IP}/health;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }
}
EOF

# Test nginx configuration
sudo nginx -t

# Make sure nginx is enabled and started
sudo systemctl enable nginx
sudo systemctl stop nginx
sudo systemctl start nginx

# Verify nginx is running
if sudo systemctl status nginx | grep -q "active (running)"; then
    echo "Nginx is running successfully"
else
    echo "Nginx failed to start, attempting to fix and restart"
    sudo apt install -y --reinstall nginx
    sudo systemctl start nginx
fi

# Final check
echo "Nginx status: $(sudo systemctl is-active nginx)"
echo "Frontend deployment completed"

echo "Frontend deployment completed successfully!"
echo "Your EduCloud frontend should be accessible via the public IP address"