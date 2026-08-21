#!/bin/sh

REPO="SuperCuber/dotter"
ASSET="dotter-linux-x64-musl"

# Alternative to download latest instead...
#LATEST_TAG=$(curl --silent "https://api.github.com/repos/$REPO/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
#wget "https://github.com/$REPO/releases/download/$LATEST_TAG/$ASSET"

# Instead let's just pin the version to v0.13.4 and manually update in the future.
TAG="v0.13.5"
wget "https://github.com/$REPO/releases/download/$TAG/$ASSET" -O dotter
chmod +x dotter

