#!/bin/sh

set -e


yum install -y java-1.8.0-openjdk
yum install -y python-matplotlib
yum install -y libgomp
yum install -y tmux vim
pip install --upgrade setuptools
pip install 'numpy==1.14'
pip install 'scipy==0.19.0'
pip install lxml
sed -i "/^backend/c\\backend:Agg" $(python -c "import matplotlib;print(matplotlib.matplotlib_fname())")


pip install colorama decorator jinja2 jpype1
pip install --upgrade lxml

# Debug packages