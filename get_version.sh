#!/bin/bash
DIR="$(svn info $1 | sed -n 's_URL: '$2'/\(.*\)$_\1_p')"
TYPE="$(echo ${DIR} | cut -d/ -f1)"
case ${TYPE} in
    branches|tags)
        echo ${DIR} | cut -d/ -f2
        ;;
    trunk)
        svn info $1 | sed -n -e 's/Revision: \(\|[0-9]*:\)\([0-9]*\)$/r\2/p'
        ;;
    *)
        echo unknown
        ;;
esac
