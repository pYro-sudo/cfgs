docker run -d --privileged --name openshift ^
  -p 8446:8443 ^
  -p 53:53/udp ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  openshift/origin:v3.10.0 ^
  start