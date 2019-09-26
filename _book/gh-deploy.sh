#!/bin/sh
if [ -z "$1" ]
then
	echo "Which folder do you want to deploy to GitHub Pages?"
	exit 1
fi

if [ $# -gt 1 ];then
	git push
	echo "git push"
fi
git subtree push --prefix $1 origin gh-pages
