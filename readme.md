### PHP Development Environment Image

[php](https://img.shields.io/badge/php-7.2.12-green.svg)[develop](https://img.shields.io/badge/develop-ok-blue.svg)

This images include following components:

1. [php:7.2.12](http://www.php.net/downloads.php) 
2. [composer 1.7.3](https://getcomposer.org/)
3. [nginx](http://nginx.org/)
4. [supervisor](http://www.supervisord.org/)


This images include following extensions of php:

1. [imagick](http://pecl.php.net/package/imagick)
2. [xdebug](https://xdebug.org/)
3. [gd](http://www.php.net/manual/zh/book.image.php)
4. pdo
5. pdo_mysql
6. mysqli
7. zip
8. imap

### Common Usage

```dockerfile
FROM gamelife1314/php-development

ADD ./ /var/www
```

### For laravel

You should update nginx site config，change site root dir to `/var/www/public`。

```
server {

    listen 80;
    listen 443 ssl;
    listen [::]:80;

    server_name _;

    root /var/www/public;
    index index.html index.php;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri /index.php =404;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_split_path_info       ^(.+\.php)(/.+)$;
        fastcgi_param PATH_INFO       $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```
