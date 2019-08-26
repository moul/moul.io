#!/bin/bash

domain="moul.io"
rootdir="docs"

create_package() {
    project_name="$1"
    project_url="$2"
    sub_package="$3"

    mkdir -p $rootdir/$project_name/$sub_package
    cat > $rootdir/$project_name/$sub_package/index.html <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta name="go-import" content="$domain/$project_name git $project_url">
    <meta name="go-source" content="$domain/$project_name $project_url $project_url/tree/master{/dir} $project_url/tree/master{/dir}/{file}#L{line}">
    <meta http-equiv="refresh" content="0; url=$project_url">
  </head>
  <body>
    <a href="$project_url">$project_url</a>
  </body>
</html>
EOF
}

> $rootdir/go-packages.txt

while read line; do
    if echo $line | grep --silent -E '^#'; then continue; fi

    project_name=$(echo $line | awk '{print $1}')
    project_url=$(echo $line | awk '{print $2}')
    sub_packages=$(echo $line | awk '{s=""; for (i = 3; i <= NF; i++) s = s $i " "; print s}')

    echo "---"
    echo "project_name: $project_name"
    echo "project_url:  $project_url"
    echo "sub_packages: $sub_packages"
    echo ""
    create_package "$project_name" "$project_url" "."
    echo "$project_name" >> $rootdir/go-packages.txt
    for sub_package in $sub_packages; do
        create_package "$project_name" "$project_url" "$sub_package"
    done
done < go-get.csv
