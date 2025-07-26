#!/bin/bash

# Simple deployment script for Pomodoro Dashboard
# Place this in your dashboard directory

DASHBOARD_DIR="/mnt/c/Users/Senior Software Eng/Downloads/my-pomo-dashboard"
SERVER_USER="your-username"
SERVER_HOST="your-server.com"
SERVER_PATH="/var/www/html/pomo-dashboard"

echo "🚀 Deploying Pomodoro Dashboard..."

# Option 1: Git deployment (if using GitHub Pages, Netlify, etc.)
deploy_git() {
    echo "📦 Git deployment..."
    cd "$DASHBOARD_DIR"
    git add .
    git commit -m "Auto-update: $(date)"
    git push origin main
    echo "✅ Pushed to git repository"
}

# Option 2: Direct server upload via rsync
deploy_server() {
    echo "📤 Server deployment..."
    rsync -avz --delete \
        --exclude '.git' \
        --exclude 'node_modules' \
        --exclude '*.sh' \
        "$DASHBOARD_DIR/" \
        "$SERVER_USER@$SERVER_HOST:$SERVER_PATH/"
    echo "✅ Uploaded to server"
}

# Option 3: Cloud storage (AWS S3, Azure Blob, etc.)
deploy_cloud() {
    echo "☁️ Cloud deployment..."
    # Uncomment and configure based on your cloud provider
    
    # AWS S3
    # aws s3 sync "$DASHBOARD_DIR/" s3://your-bucket-name/ --delete
    
    # Azure Blob Storage
    # az storage blob upload-batch --destination '$web' --source "$DASHBOARD_DIR/"
    
    # Google Cloud Storage
    # gsutil -m rsync -r -d "$DASHBOARD_DIR/" gs://your-bucket-name/
    
    echo "✅ Deployed to cloud storage"
}

# Option 4: Local file copy (for testing)
deploy_local() {
    echo "📁 Local deployment..."
    LOCAL_SERVE_DIR="/tmp/pomo-dashboard"
    mkdir -p "$LOCAL_SERVE_DIR"
    cp -r "$DASHBOARD_DIR"/* "$LOCAL_SERVE_DIR/"
    echo "✅ Copied to $LOCAL_SERVE_DIR"
    echo "💡 You can serve with: cd $LOCAL_SERVE_DIR && python3 -m http.server 8000"
}

# Choose deployment method
DEPLOY_METHOD=${1:-"local"}

case $DEPLOY_METHOD in
    "git")
        deploy_git
        ;;
    "server")
        deploy_server
        ;;
    "cloud")
        deploy_cloud
        ;;
    "local")
        deploy_local
        ;;
    *)
        echo "❌ Unknown deployment method: $DEPLOY_METHOD"
        echo "Usage: $0 [git|server|cloud|local]"
        exit 1
        ;;
esac

echo "🎉 Deployment completed!"
