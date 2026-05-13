#!/usr/bin/env bash

echo " local: $(ipconfig getifaddr en0)"
echo "public: $(dig +short myip.opendns.com @resolver1.opendns.com)"
