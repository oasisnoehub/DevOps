```shell
docker run -d -u root -p 8080:8080 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /mydata/jenkins/home:/var/jenkins_home \
-v /mydata/jenkins/maven/apache-maven-3.5.4:/usr/local/maven \
-v /mydata/jenkins/certs:/certs/client \
--name myjenkins jenkinsci/blueocean:latest
```