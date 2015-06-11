#!/usr/bin/env bash
#this file is sourced from bin/detect, bin/compile and bin/release
# it is assumed that <BUILD_DIR> is set before this file is sourced.

ANT_VER="1.9.3"
ANT_URL="http://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VER-bin.tar.gz"

VENDORING_DIR="$BUILD_DIR/.buildpack"
ANT_HOME=$VENDORING_DIR/apache-ant-$ANT_VER

SCALA_VER="2.11.6"
SCALA_URL="http://downloads.typesafe.com/scala/$SCALA_VER/scala-$SCALA_VER.tgz"
SCALA_HOME=$VENDORING_DIR/scala-$SCALA_VER

export_env_dir() {
  env_dir=$1
  whitelist_regex=${2:-''}
  blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH|JAVA_OPTS|ANT_HOME)$'}
  if [ -d "$env_dir" ]; then
    for e in $(ls $env_dir); do
      echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
      export "$e=$(cat $env_dir/$e)"
      :
    done
  fi
}

get_app_system_value() {
  local file=${1?"No file specified"}
  local key=${2?"No key specified"}

  # escape for regex
  local escaped_key=$(echo $key | sed "s/\./\\\./g")

  [ -f $file ] && \
  grep -E ^$escaped_key[[:space:]=]+ $file | \
  sed -E -e "s/$escaped_key([\ \t]*=[\ \t]*|[\ \t]+)([A-Za-z0-9\.-]*).*/\2/g"
}
