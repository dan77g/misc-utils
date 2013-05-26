#!/bin/bash

mkdir ~/.tmp
cd ~/.tmp
rm -fr ~/.tmp/* 
while (true) 
do

	for url in `cat $HOME/bin/urlList | grep index.html`
	do
		PID=`ps -ef | grep konq.*keepAlive | awk '{print $2}'	`
		kill $PID
#		wget  --load-cookies $HOME/.mozilla/firefox/p2fdh8up.default/cookies.sqlite -t 3 -T 6  $url
#		wget --no-check-certificate  --save-cookies ~/cookie --keep-session-cookies $url 
		#firefox -P just4scripts -no-remote  $url &
		konqueror --profile keepAliveScrip $url &
		sleep 20
	done

done
