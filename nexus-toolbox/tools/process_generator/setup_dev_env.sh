#!/bin/bash
# setup_dev_env.sh
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
echo "Environment setup complete. Activate with: source venv/bin/activate"
