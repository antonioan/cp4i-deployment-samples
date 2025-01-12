FROM public.ecr.aws/docker/library/node:latest
ARG SRC_DIR=missing
RUN mkdir /src
RUN mkdir /libs
COPY src/${SRC_DIR} /src
COPY src/libs /libs
COPY entrypoint.sh /src
WORKDIR /src
#RUN for d in $(find /src /libs -name node_modules -prune -o -name package.json -print); do cd $(dirname $d); npm install; cd -; done
EXPOSE 5000
#RUN npm list
#CMD ["node", "-r", "./tracing.js", "app.js"]
ENTRYPOINT ["bash", "entrypoint.sh"]

