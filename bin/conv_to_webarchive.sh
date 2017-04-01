#!/bin/bash
 
#===============================================================================
#          FILE:  conv_to_webarchive.sh
#         USAGE:  Automatic with Hazel
#   DESCRIPTION:  Uses diffbot to download essential info about an article
#                 & webarchiver to convert it to a .webarchive file
#        AUTHOR:  Scott Granneman (RSG), scott@chainsawonatireswing.com
#       COMPANY:  Chainsaw On A Tire Swing
#       VERSION:  0.4
#       CREATED:  06/22/2013 13:50:23 CDT
#      REVISION:  11/17/2013 15:20:43 CDT 
#===============================================================================

#####
####
### Variables
##
# 

incoming_dir="/Users/mattias/Dropbox/Incoming/Devonthink"

devonthink_dir="/Users/mattias/Library/Application Support/DEVONthink Pro 2/Inbox"

fail_safe_dir="/Users/mattias/Desktop"

diffbot_token="ff0a4382846d8b02e43696e9e7ebc9d4"

#####
####
### Grab webpages
##
# 

# Test to see if the necessary directories exist
if [ -e "$incoming_dir" ] && [ -e "$devonthink_dir" ] ; then
  # Set IFS to split on newlines, not spaces, but first save old IFS
  # See http://unix.stackexchange.com/questions/9496/looping-through-files-with-spaces-in-the-names
  SAVEIFS=$IFS
  IFS=$'\n'
  # If you can cd to the Incoming/DEVONthink directory, run everything else
  if cd $incoming_dir ; then 
    # For every file containing a URL in the Incoming/DEVONthink directory
    for i in $(ls *)
    do
      # If it’s not empty, process it;
      # if it IS empty, move it so Diffbot doesn’t keep trying forever
      if [[ -s $i ]] ; then
        # Check if it’s a Windows-formatted file; if it is, convert it to UNIX
        if [ $(grep -c $'\r$' "$i") \> 0 ] ; then
          terminal-notifier -message "$1 is a Windows file, so convert it" -title "Windows File Found"
          /usr/local/bin/dos2unix "$1"
        fi
        # Delete any blank lines
        # Note: will only work with UNIX line endings, hence the previous conversion by Hazel
        /usr/local/bin/gsed '/^$/d' "$i" > "$i".out
        mv "$i".out "$i"
        # Read the file to get the URL
        # I use head instead of cat because the file usually comes in via email,
        # & I’m too lazy when composing to leave off my email sig
        url=$(head -n 1 $i)
        /usr/local/bin/gecho -e "\nURL in the file is $url"
        # URL encode the, uh, URL
        encoded_url=$(python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" $url)
        /usr/local/bin/gecho -e "\nEncoded URL is $encoded_url"
        # Grab JSON-formatted article & data from Diffbot, 
        # clean up JSON, & write results to file
        if curl "http://www.diffbot.com/api/article?token=$diffbot_token&url=$encoded_url&html&timeout=20000" | /usr/local/bin/jsonpp > /tmp/results.json ; then
          # Pull out article’s name
          article_title=$(grep -m 1 '"title":' /tmp/results.json | /usr/local/bin/gsed 's/  "title": "//' | /usr/local/bin/gsed 's/",$//' | /usr/local/bin/gsed 's:\\\/:-:g' | /usr/local/bin/gsed 's://:-:g' | /usr/local/bin/gsed 's/\\"/"/g' | /usr/local/bin/gsed -f /Users/mattias/bin/conv_to_webarchive.sed)
          /usr/local/bin/gecho -e "\nArticle Title is $article_title"
          # If $article_title is empty, move it so Diffbot doesn’t keep trying forever;
          # if it’s not empty, continue processing it
          if [[ -z $article_title ]] ; then
            # If $article_title is empty, move it!
            mv $i $fail_safe_dir
            terminal-notifier -message "Diffbot could not parse title in $i" -title "Problem with Diffbot"
          else
            # If results.json can be renamed, continue processing;
            # if it can’t be renamed, move it!
            if mv /tmp/results.json /tmp/"$article_title".json ; then
              # Pull out article’s other metadata
              article_author=$(grep -m 1 '"author":' /tmp/"$article_title".json | /usr/local/bin/gsed 's/  "author": "//' | /usr/local/bin/gsed 's/",$//' | /usr/local/bin/gsed -f /Users/mattias/bin/conv_to_webarchive.sed)
              /usr/local/bin/gecho -e "\nArticle Author is $article_author"
              article_date=$(grep '"date":' /tmp/"$article_title".json | /usr/local/bin/gsed 's/  "date": "//' | /usr/local/bin/gsed 's/",$//' | /usr/local/bin/gsed -f /Users/mattias/bin/conv_to_webarchive.sed)
              /usr/local/bin/gecho -e "\nArticle Date is $article_date"
              article_url=$(grep '"url":' /tmp/"$article_title".json | /usr/local/bin/gsed 's/  "url": "//' | /usr/local/bin/gsed 's/",$//' | /usr/local/bin/gsed 's/\\//g' | /usr/local/bin/gsed 's/"$//')
              /usr/local/bin/gecho -e "\nArticle URL is $article_url"
              # Write HTML to file
              # Remove JSON stuff, fix Unicode, then remove \n, \t, & \
              grep '"html":' /tmp/"$article_title".json | /usr/local/bin/gsed 's/  "html": "//' | /usr/local/bin/gsed 's/",$//' | /usr/local/bin/gsed -f /Users/mattias/bin/conv_to_webarchive.sed | /usr/local/bin/gsed 's/\\n//g' | /usr/local/bin/gsed 's/\\t//g' | /usr/local/bin/gsed 's/\\//g' > /tmp/"$article_title".html
              # Prepend metadata to file
              /usr/local/bin/gsed "1i <h1>$article_title</h1>\n<b>$article_author</b><br>\n<b>$article_date</b><br>\n<b>$article_url</b><br>\n" /tmp/"$article_title".html > /tmp/"$article_title"_1.html && mv /tmp/"$article_title"_1.html /tmp/"$article_title".html
              # Prepend HTML metadata to file
              /usr/local/bin/gsed "1i <!DOCTYPE html>\n<html>\n<head>\n<meta charset="UTF-8">\n<title>$article_title</title>\n</head>\n<body>\n" /tmp/"$article_title".html > /tmp/"$article_title"_1.html && mv /tmp/"$article_title"_1.html /tmp/"$article_title".html
              # Append HTML metadata to file
              echo "</body></html" >> /tmp/"$article_title".html
              # Using the webarchiver tool I downloaded & compiled, create a webarchive
              if /usr/local/bin/webarchiver -url /tmp/"$article_title".html -output $devonthink_dir/"$article_title".webarchive ; then
                # If it works, then delete the file
                rm $i
              else
                # Couldn’t create a webarchive
                /usr/local/bin/terminal-notifier -message "No webarchive for $i" -title "Problem creating webarchive"
              fi
            else
              # If results.json can’t be renamed, move it!
              mv $i $fail_safe_dir
            fi
          fi
        else
          # If Diffbot fails, move it!
          mv $i $fail_safe_dir
          terminal-notifier -message "Could not Diffbot $i" -title "Problem with Diffbot"
        fi
      else
        # If it’s empty, move it!
        terminal-notifier -message "$i is empty!" -title "Problem with parsing file"
        mv $i $fail_safe_dir
      fi
    done
  else
    # Needed directory isn’t there, which is weird
    /usr/local/bin/gecho -e "\nIncoming DevonThink directory is missing for $i!" >> "$fail_safe_dir/DEVONthink Problem.txt"
  fi
  # Restore IFS so it’s back to splitting on <space><tab><newline>
  IFS=$SAVEIFS
else
  # Needed directories aren’t there, which is very bad
  /usr/local/bin/gecho -e "\nIncoming or DevonThink directories are missing for $i!" >> "$fail_safe_dir/DEVONthink Problem.txt"
fi

exit 0