@echo off
setlocal

mkdir certs 2>nul

openssl req -x509 -newkey rsa:2048 -keyout certs/ca.key -out certs/ca.crt -days 365 -nodes -subj "/CN=CA"
openssl req -x509 -newkey rsa:2048 -keyout certs/master.server.key -out certs/master.server.crt -days 365 -nodes -subj "/CN=localhost"
openssl req -x509 -newkey rsa:2048 -keyout certs/proxy-client.key -out certs/proxy-client.crt -days 365 -nodes -subj "/CN=proxy"
openssl req -new -newkey rsa:2048 -keyout certs/master.etcd-client.key -out certs/master.etcd-client.csr -nodes -subj "/CN=etcd-client"
openssl x509 -req -in certs/master.etcd-client.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/master.etcd-client.crt -days 365
openssl req -x509 -newkey rsa:2048 -keyout certs/serviceaccounts.private.key -out certs/serviceaccounts.public.key -days 365 -nodes -subj "/CN=serviceaccounts"
openssl req -new -newkey rsa:2048 -keyout certs/master.kubelet-client.key -out certs/master.kubelet-client.csr -nodes -subj "/CN=kubelet-client"
openssl x509 -req -in certs/master.kubelet-client.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/master.kubelet-client.crt -days 365

echo apiVersion: v1 > certs/admin.kubeconfig
echo kind: Config >> certs/admin.kubeconfig
echo clusters: >> certs/admin.kubeconfig
echo - cluster: >> certs/admin.kubeconfig
echo     certificate-authority: /etc/origin/master/ca.crt >> certs/admin.kubeconfig
echo     server: https://localhost:8443 >> certs/admin.kubeconfig
echo   name: local >> certs/admin.kubeconfig
echo contexts: >> certs/admin.kubeconfig
echo - context: >> certs/admin.kubeconfig
echo     cluster: local >> certs/admin.kubeconfig
echo     user: admin >> certs/admin.kubeconfig
echo   name: admin >> certs/admin.kubeconfig
echo current-context: admin >> certs/admin.kubeconfig
echo users: >> certs/admin.kubeconfig
echo - name: admin >> certs/admin.kubeconfig
echo   user: >> certs/admin.kubeconfig
echo     client-certificate: /etc/origin/master/master.server.crt >> certs/admin.kubeconfig
echo     client-key: /etc/origin/master/master.server.key >> certs/admin.kubeconfig

docker run -d --privileged --name openshift ^
  -p 8446:8446 ^
  -p 53:53/udp ^
  -v %cd%\master-config.yaml:/etc/origin/master/master-config.yaml ^
  -v %cd%\node-config.yaml:/etc/origin/node/node-config.yaml ^
  -v %cd%\certs:/etc/origin/master ^
  -v %cd%\session-secrets.yaml:/etc/origin/master/session-secrets.yaml ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  openshift/origin:v3.10.0 ^
  start ^
  --master-config=/etc/origin/master/master-config.yaml ^
  --node-config=/etc/origin/node/node-config.yaml ^
  --public-master=https://localhost:8446

endlocal