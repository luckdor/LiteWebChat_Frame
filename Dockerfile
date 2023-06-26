FROM node:16 as builder
 
WORKDIR /portal
COPY . .
 
ARG proxy=""
 
RUN if [ "$proxy" != "" ]; \
    then npm config set proxy "$proxy" && npm config set https-proxy "$proxy"; \
    else echo Do not set proxy; \
    fi
# RUN npm install
 
 
RUN chmod +x node_modules/.bin/tsc
RUN chmod +x node_modules/.bin/vite
 
# RUN npm run build
 
FROM nginx:alpine
WORKDIR /portal
COPY --from=builder /portal/dist/ /usr/share/nginx/html/
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
COPY default.conf.template /etc/nginx/conf.d

RUN network create --subnet=192.168.120.0/24 DockerNetBridge
RUN docker run  -it -p 80:80 -p 443:443 -itd --network=DockerNetBridge --ip 192.168.120.10 --name chatframe yynid/qq
RUN apt install curl
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
RUN export NVM_DIR="$HOME/.nvm"
RUN [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
RUN [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
RUN nvm install 17.7.2
RUN nvm use 17.7.2
CMD /bin/sh -c "envsubst '80' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
