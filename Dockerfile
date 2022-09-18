# specify the node base image with your desired version node:<version>
FROM node:10-alpine
WORKDIR /application
COPY . .
RUN chmod 755 entry-point.sh
RUN npm install
# ENV PORT='1234'
# replace this with your application's default port
EXPOSE 8081
ARG PORT="8081"
ENV PORT=${PORT}
#RUN env | grep PORT
ENTRYPOINT [ "/bin/sh","-c","/application/entry-point.sh" ]
#ENTRYPOINT ["/bin/sh","-c","/application/entry-point.sh"]
