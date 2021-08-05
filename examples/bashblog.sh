#!/usr/bin/env bash

# https://github.com/cfenollosa/bashblog

source bash-args parse <<"EOF"
@arg post - insert a new blog post, or the filename of a draft to continue editing it. it tries to use markdown by default, and falls back to HTML if it's not available. use '-html' to override it and edit the post as HTML even when markdown is available
@arg edit - edit an already published .html or .md file. **NEVER** edit manually a published .html file, always use this function as it keeps internal data and rebuilds the blog. use '-n' to give the file a new name, if title was changed. use '-f' to edit full html file, instead of just text part (also preserves name)
@arg delete - deletes the post and rebuilds the blog
@arg rebuild - deletes the post and rebuilds the blog
@arg reset - deletes everything except this script. Use with a lot of caution and back up first!
@arg list - list all posts
@arg tags - list all tags in alphabetical order. use '-n' to sort list by number of posts

EOF

printf "%s" "$argsHelpText"
