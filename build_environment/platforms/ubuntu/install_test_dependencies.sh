#!/bin/sh

set -e
apt-get update
apt-get install -y libgomp1
# Set DEBIAN_FRONTEND to avoid issues with question about time zone
DEBIAN_FRONTEND=noninteractive apt-get install -y python-matplotlib
pip install --upgrade setuptools
pip install scipy nose lxml
sed -i "/^backend/c\\backend:Agg" $(python -c "import matplotlib;print(matplotlib.matplotlib_fname())")
