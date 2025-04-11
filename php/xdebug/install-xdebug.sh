#!/usr/bin/env sh
set -e

PHP_VERSION=$(php -v | head -n 1 | awk '{print $2}' | cut -d. -f1,2)

# Supported Versions and Compatibility: https://xdebug.org/docs/compat
# Xdebug Version Release: https://xdebug.org/download/historical
case $PHP_VERSION in
    "8.0") XDEBUG_VERSION="3.4.2";;  # May have version 3.5.0 in future
    "7.4"|"7.3"|"7.2") XDEBUG_VERSION="3.1.6";;
    "7.1") XDEBUG_VERSION="2.9.8";;
    "7.0") XDEBUG_VERSION="2.7.2";;
    "5.6"|"5.5") XDEBUG_VERSION="2.5.5";;
    "5.4") XDEBUG_VERSION="2.4.1";;
    "5.3") XDEBUG_VERSION="2.2.7";;
    *) XDEBUG_VERSION="stable";;
esac

# Install the specific Xdebug version
pecl install xdebug-$XDEBUG_VERSION

docker-php-ext-enable xdebug

# Move the appropriate xdebug-config file based on the Xdebug version
if [ "$XDEBUG_VERSION" = "stable" ]; then
  XDEBUG_CONFIG_VERSION="3"
else
  XDEBUG_CONFIG_VERSION=$(echo "$XDEBUG_VERSION" | cut -d. -f1)
fi

mv "/tmp/xdebug/config/version-$XDEBUG_CONFIG_VERSION.ini" /usr/local/etc/php/conf.d/xdebug-config.ini

# Remove installer
rm -r /tmp/xdebug

# Disable xdebug by default to avoid performance issue
sed -i 's/^/;/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini