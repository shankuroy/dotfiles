#!/usr/bin/env bash

PUBLIC_IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
LOCAL_IP="$(ipconfig getifaddr en0)"

echo "public $PUBLIC_IP"
echo " local $LOCAL_IP"
