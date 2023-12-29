#!/bin/sh
CURLOPT="--silent --remote-name"
FILTERS="scholarly-metadata author-info-blocks"
GITHUBURL="https://raw.githubusercontent.com/pandoc/lua-filters/master"

for FILTER in ${FILTERS}; do
    curl ${CURLOPT} ${GITHUBURL}/${FILTER}/${FILTER}.lua
done

curl ${CURLOPT} https://raw.githubusercontent.com/crsh/rmdfiltr/master/inst/wordcount.lua
curl ${CURLOPT} https://raw.githubusercontent.com/pandoc-ext/abstract-section/main/_extensions/abstract-section/abstract-section.lua
