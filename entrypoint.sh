#!/bin/bash

# Start Postfix
postfix start || true

# Start Flask app
python3 app.py
