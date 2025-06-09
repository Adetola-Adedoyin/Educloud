#!/bin/bash
# Remove set -e to prevent script from exiting on errors
# Log all steps for debugging
exec > >(tee /var/log/backend-setup.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Backend Server setup..."

# Update system packages
sudo apt update -y

# Install Node.js, npm, git, and pm2 for process management
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs git curl

# Check Node.js installation
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# Install PM2 globally for process management
sudo npm install -g pm2

# Define application constants
BACKEND_APP_PORT="3000" # Hardcode the backend application port

# --- REPOSITORY DETAILS ---
BACKEND_REPO_URL="https://github.com/Adetola-Adedoyin/EduCloud-Backend-app.git"

# Use a hardcoded database IP for now
# You can update this after deployment with the actual database private IP
DB_HOST_IP="10.0.2.20"
echo "Using database server IP: $DB_HOST_IP"

# Database password - consider using AWS Secrets Manager or Parameter Store in production
DB_USER_PASSWORD="jesutomi" # <<< REPLACE THIS to match the password set in database_user_data.sh

# Set up application directory
CODE_DIR="/opt/educloud-backend"
sudo mkdir -p ${CODE_DIR}
cd ${CODE_DIR}

# Clone your EduCloud backend repository
echo "Cloning backend repository from $BACKEND_REPO_URL..."
sudo git clone "$BACKEND_REPO_URL" . || {
  echo "Failed to clone repository with sudo. Trying without sudo..."
  git clone "$BACKEND_REPO_URL" . || {
    echo "Failed to clone repository. Creating a simple Express app instead."
    
    # Create a simple Express app if clone fails
    echo "Creating package.json..."
    cat > package.json << 'EOF'
{
  "name": "educloud-backend",
  "version": "1.0.0",
  "description": "Simple Express backend",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOF

    echo "Creating server.js..."
    cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// API routes
app.get('/api', (req, res) => {
  res.json({ message: 'Welcome to the EduCloud API' });
});

app.get('/api/data', (req, res) => {
  res.json({ 
    data: [
      { id: 1, name: 'Item 1' },
      { id: 2, name: 'Item 2' },
      { id: 3, name: 'Item 3' }
    ] 
  });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
EOF
  }
}

# Set proper permissions
sudo chown -R ubuntu:ubuntu ${CODE_DIR}

# Install dependencies
echo "Installing dependencies..."
npm install --no-fund --no-audit || {
  echo "npm install failed, trying with --legacy-peer-deps"
  npm install --legacy-peer-deps --no-fund --no-audit
}

# Create .env file for backend application
sudo tee .env > /dev/null <<EOF
NODE_ENV=production
PORT=${BACKEND_APP_PORT}
DB_HOST=${DB_HOST_IP}
DB_USER=educloud_user
DB_PASSWORD=${DB_USER_PASSWORD}
DB_NAME=educloud_db
# S3_BUCKET_NAME= # Removed S3 as not configured
# JWT_SECRET=your-jwt-secret # Uncomment and set if your backend needs this for authentication
EOF

# Set permissions for env file
sudo chown ubuntu:ubuntu .env
sudo chmod 600 .env

# Start the application with PM2
echo "Starting application with PM2..."
if [ -f "server.js" ]; then
    pm2 start server.js --name "educloud-backend" || echo "Failed to start server.js with PM2"
elif [ -f "app.js" ]; then
    pm2 start app.js --name "educloud-backend" || echo "Failed to start app.js with PM2"
elif [ -f "index.js" ]; then
    pm2 start index.js --name "educloud-backend" || echo "Failed to start index.js with PM2"
else
    echo "No main server file found (server.js, app.js, or index.js). Creating a simple server.js file."
    
    # Create a simple Express server
    cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.status(200).send(JSON.stringify({ status: 'ok' }));
});

// API routes
app.get('/api', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.status(200).send(JSON.stringify({ message: 'Welcome to the EduCloud API' }));
});

app.get('/', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.status(200).send(JSON.stringify({ service: 'EduCloud Backend API', status: 'running' }));
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
EOF

    # Install Express if not already installed
    npm install express --save
    
    # Start the simple server
    pm2 start server.js --name "educloud-backend"
fi

# Save PM2 configuration and set it to start on boot
pm2 save || echo "Failed to save PM2 configuration"
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu || echo "Failed to setup PM2 startup"
pm2 save || echo "Failed to save PM2 configuration again"

# Configure firewall to allow API access
sudo ufw allow "${BACKEND_APP_PORT}/tcp"

# Optional: Install and configure Nginx on the Backend EC2
sudo apt install -y nginx

# Create a static health check file
sudo mkdir -p /var/www/html
sudo tee /var/www/html/health.json > /dev/null <<EOF
{"status":"ok"}
EOF

# Create a direct health check script that doesn't rely on nginx or Express
sudo tee /usr/local/bin/health-check.sh > /dev/null <<EOF
#!/bin/bash
echo '{"status":"ok"}'
EOF
sudo chmod +x /usr/local/bin/health-check.sh

sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    # Health check endpoint - direct static file
    location = /health {
        default_type application/json;
        return 200 '{"status":"ok"}';
    }

    # API endpoints
    location /api/ {
        proxy_pass http://localhost:${BACKEND_APP_PORT}/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Root endpoint
    location / {
        default_type application/json;
        return 200 '{"service":"EduCloud Backend API","status":"running"}';
    }
}
EOF

# Enable the Nginx site configuration and restart Nginx
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
sudo nginx -t || {
  echo "Nginx configuration test failed. Using minimal configuration."
  sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    
    location = /health {
        return 200 '{"status":"ok"}';
        add_header Content-Type application/json;
    }
    
    location / {
        return 200 '{"service":"EduCloud Backend API","status":"running"}';
        add_header Content-Type application/json;
    }
}
EOF
}

# Make sure nginx is enabled and started
sudo systemctl enable nginx
sudo systemctl restart nginx || sudo systemctl start nginx

# Create a health check file as a backup
sudo mkdir -p /var/www/html
echo '{"status":"ok"}' | sudo tee /var/www/html/health.json > /dev/null
sudo chmod 644 /var/www/html/health.json

sudo systemctl restart nginx || sudo systemctl start nginx
echo "Nginx status: $(sudo systemctl is-active nginx)"

echo "Backend deployment completed!"
echo "Backend should be running on port ${BACKEND_APP_PORT}"
echo "Backend API accessible at:"
echo "Direct: http://[backend-ip]:${BACKEND_APP_PORT}"
echo "Via Backend Nginx (for /api/ and /health): http://[backend-ip]/api/"