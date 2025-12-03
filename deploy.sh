#!/bin/bash

# BukAlert Vercel Deployment Script
# This script builds the Flutter web app and prepares it for Vercel deployment

set -e  # Exit on any error

echo "🚀 Starting BukAlert Vercel Deployment"
echo "====================================="

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"

# Check if Vercel CLI is available
if ! command -v vercel &> /dev/null; then
    echo "⚠️  Vercel CLI not found. Installing..."
    npm install -g vercel
fi

echo "✅ Vercel CLI ready"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Build failed - build/web directory not found"
    exit 1
fi

echo "✅ Build completed successfully"

# Check if user is logged into Vercel
if ! vercel whoami &> /dev/null; then
    echo "🔐 Please login to Vercel:"
    vercel login
fi

echo "📤 Deploying to Vercel..."

# Deploy to Vercel
if [ "$1" = "--prod" ]; then
    echo "🌐 Deploying to production..."
    vercel --prod
else
    echo "🧪 Deploying to preview..."
    vercel
fi

echo "🎉 Deployment completed!"
echo ""
echo "📱 Test your app at the provided Vercel URL"
echo "📊 Check deployment status at https://vercel.com/dashboard"
echo ""
echo "📚 For detailed deployment guide, see VERCEL_DEPLOYMENT.md"
