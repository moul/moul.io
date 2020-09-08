#!/bin/bash

domain="moul.io"
rootdir="public"

create_package() {
    project_name="$1"
    project_url="$2"

    echo "$project_name" >> $rootdir/go-packages.txt
    echo "/$project_name/* go-get=1 /$project_name/go-get.html 200!" >> $rootdir/_redirects
    #echo "/$project_name/ $project_url 301!" >> $rootdir/_redirects
    #echo "/$project_name/* $project_url 301!" >> $rootdir/_redirects

    mkdir -p $rootdir/$project_name
    cat > $rootdir/$project_name/go-get.html <<EOF
<html><head>
    <meta name="go-import" content="$domain/$project_name git $project_url">
    <meta name="go-source" content="$domain/$project_name     $project_url $project_url/tree/master{/dir} $project_url/tree/master{/dir}/{file}#L{line}">
</head></html>
EOF
    cat > $rootdir/$project_name/index.html <<EOF
<html>
  <head>
    <title>$domain/$project_name</title>
    <link rel="stylesheet" type="text/css" href="/style.css">
  </head>
  <body>
    <h1>$domain/$project_name</h1>
    <pre><code>go get $domain/$project_name</code></pre>
    <pre><code>import "$domain/$project_name"</code></pre>
    Home: <a href="$project_url">$project_url</a><br />
    Doc: <a href="https://pkg.go.dev/$domain/$project_name">https://pkg.go.dev/$domain/$project_name</a>
  </body>
</html>
EOF

}

while read line; do
    if echo $line | grep --silent -E '^#'; then continue; fi

    project_name=$(echo $line | awk '{print $1}')
    project_url=$(echo $line | awk '{print $2}')
    create_package "$project_name" "$project_url"
done < vanity.csv

cat $rootdir/go-packages.txt | sort -u > $rootdir/go-packages-sorted.txt
mv $rootdir/go-packages-sorted.txt $rootdir/go-packages.txt

# generate root index.html
cat > $rootdir/index.html <<EOF
<html>
  <head>
    <title>$domain Go Modules</title>
    <link rel="stylesheet" type="text/css" href="/style.css">
  </head>
  <body>
    <h1>$domain Go Modules</h1>
    <ul>
EOF
while read line; do
    echo '        <li><a href="'./$line/'">'$domain/$line'</a></li>' >> $rootdir/index.html
done < $rootdir/go-packages.txt
cat >> $rootdir/index.html <<EOF
      </ul>
      <hr />
      Generated by <a href="https://github.com/moul/moul.io">github.com/moul/moul.io</a>.
   </body>
</html>
EOF