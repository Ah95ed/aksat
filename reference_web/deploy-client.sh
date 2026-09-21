#!/bin/bash
set -e

echo "Building Vue application..."
npm run build
echo "Build complete. Upload dist/ contents plus api/ and config.local.php to Hostinger."
echo "IMPORTANT: set DB_PASS in api/config.local.php before uploading, and keep the file out of GitHub."
