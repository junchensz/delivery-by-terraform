version: '2'
services:
  wecube-minio:
    image: ccr.ccs.tencentyun.com/webankpartners/minio
    restart: always
    command: [
        'server',
        'data'
    ]
    ports:
      - 9000:9000
    volumes:
      - /data/minio-storage/data:/data    
      - /data/minio-storage/config:/root
      - /etc/localtime:/etc/localtime
    environment:
      - MINIO_ACCESS_KEY={{S3_ACCESS_KEY}}
      - MINIO_SECRET_KEY={{S3_SECRET_KEY}}

  wecube-portal:
    image: {{PORTAL_IMAGE}}:{{PORTAL_IMAGE_VERSION}}
    restart: always
    depends_on:
      - platform-gateway
      - platform-core
    volumes:
      - /data/wecube-portal/log:/var/log/nginx/
      - /etc/localtime:/etc/localtime
      - /data/wecube-portal/data/ui-resources:/root/app/ui-resources
    ports:
      - {{PORTAL_PORT}}:8080
    environment:
      - GATEWAY_HOST={{GATEWAY_HOST}}
      - GATEWAY_PORT={{GATEWAY_PORT}}
      - PUBLIC_DOMAIN={{PUBLIC_DOMAIN}}
      - TZ=Asia/Shanghai
    command: /bin/bash -c "envsubst < /etc/nginx/conf.d/nginx.tpl > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"

  platform-gateway:
    image: {{GATEWAY_IMAGE_NAME}}:{{GATEWAY_IMAGE_VERSION}}
    restart: always
    depends_on:
      - platform-core
    volumes:
      - /data/wecube-gateway/log:/log/ 
      - /etc/localtime:/etc/localtime
    ports:
      - {{GATEWAY_PORT}}:8080
    environment:
      - TZ=Asia/Shanghai
      - GATEWAY_ROUTE_CONFIG_SERVER={{GATEWAY_ROUTE_CONFIG_SERVER}}
      - GATEWAY_ROUTE_CONFIG_URI={{GATEWAY_ROUTE_CONFIG_URI}}
      - GATEWAY_ROUTE_ACCESS_KEY={{GATEWAY_ROUTE_ACCESS_KEY}}
      - GATEWAY_CUSTOM_PARAM={{GATEWAY_CUSTOM_PARAM}}

  platform-core:
    image: {{WECUBE_IMAGE_NAME}}:{{WECUBE_IMAGE_VERSION}}
    restart: always
    volumes:
      - /data/wecube/log:/log/ 
      - /etc/localtime:/etc/localtime
    ports:
      - {{WECUBE_SERVER_PORT}}:8080
    environment:
      - TZ=Asia/Shanghai
      - MYSQL_SERVER_ADDR={{MYSQL_SERVER_ADDR}}
      - MYSQL_SERVER_PORT={{MYSQL_SERVER_PORT}}
      - MYSQL_SERVER_DATABASE_NAME={{MYSQL_SERVER_DATABASE_NAME}}
      - MYSQL_USER_NAME={{MYSQL_USER_NAME}}
      - MYSQL_USER_PASSWORD={{MYSQL_USER_PASSWORD}}
      - WECUBE_PLUGIN_HOSTS={{WECUBE_PLUGIN_HOSTS}}
      - WECUBE_PLUGIN_HOST_PORT={{WECUBE_PLUGIN_HOST_PORT}}
      - WECUBE_PLUGIN_HOST_USER={{WECUBE_PLUGIN_HOST_USER}}
      - WECUBE_PLUGIN_HOST_PWD={{WECUBE_PLUGIN_HOST_PWD}}
      - S3_ENDPOINT={{S3_URL}}
      - S3_ACCESS_KEY={{S3_ACCESS_KEY}}
      - S3_SECRET_KEY={{S3_SECRET_KEY}}
      - STATIC_RESOURCE_SERVER_IP={{STATIC_RESOURCE_SERVER_IP}}
      - STATIC_RESOURCE_SERVER_USER={{STATIC_RESOURCE_SERVER_USER}}
      - STATIC_RESOURCE_SERVER_PASSWORD={{STATIC_RESOURCE_SERVER_PASSWORD}}
      - STATIC_RESOURCE_SERVER_PORT={{STATIC_RESOURCE_SERVER_PORT}}
      - STATIC_RESOURCE_SERVER_PATH={{STATIC_RESOURCE_SERVER_PATH}}
      - GATEWAY_URL={{GATEWAY_URL}}
      - JWT_SSO_AUTH_URI={{JWT_SSO_AUTH_URI}}
      - JWT_SSO_TOKEN_URI={{JWT_SSO_TOKEN_URI}}
      - WECUBE_PLUGIN_DEPLOY_PATH={{WECUBE_PLUGIN_DEPLOY_PATH}}
  

  auth-server:
    image: {{AUTH_SERVER_IMAGE_NAME}}:{{AUTH_SERVER_IMAGE_VERSION}}
    restart: always
    depends_on:
      - mysql-auth-server
    volumes:
      - /data/auth_server/log:/log/ 
      - /etc/localtime:/etc/localtime
    ports:
      - {{AUTH_SERVER_PORT}}:8080
    environment:
      - TZ=Asia/Shanghai
      - MYSQL_SERVER_ADDR={{AUTH_SERVER_MYSQL_ADDR}}
      - MYSQL_SERVER_PORT={{AUTH_SERVER_MYSQL_PORT}}
      - MYSQL_SERVER_DATABASE_NAME={{AUTH_SERVER_DATABASE_NAME}}
      - MYSQL_USER_NAME={{AUTH_SERVER_MYSQL_USER_NAME}}
      - MYSQL_USER_PASSWORD={{AUTH_SERVER_MYSQL_USER_PASSWORD}}
      - AUTH_CUSTOM_PARAM={{AUTH_CUSTOM_PARAM}}

  mysql-auth-server:
    image: mysql:5.6
    restart: always
    command: [
            '--character-set-server=utf8mb4',
            '--collation-server=utf8mb4_unicode_ci',
            '--default-time-zone=+8:00',
            '--max_allowed_packet=4M',
            '--lower_case_table_names=1'
    ]
    volumes:
      - /etc/localtime:/etc/localtime
      - "/root/application/wecube/database/auth-server/:/docker-entrypoint-initdb.d/"
    environment:
      - MYSQL_ROOT_PASSWORD={{MYSQL_USER_PASSWORD}}
      - MYSQL_DATABASE=auth_server
    ports:
      - 3308:3306
