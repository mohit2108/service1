This API is based on below design -

1) Use random function to generate value between 1 and 500.
2) If value is between 1 and 200, the response is sent back as 200 else the response is sned back as 500.
3) Also, below monitoring can be used 
a) Splunk - Included in Dockerfile
b) Grafana 
c) Dynatrace - Included in Dockerfile
4) Deployment directory has yaml files responsible for below pushing the code to k8s cluster-
  a) Deployment - Responsible for creation of container with required port.
  b) Service Yaml - Exposing the service 
  c) Network or Kustomization - Contain network properties.
  d) If API need to be exposed to external users - externalip.yaml file need to be present which will filter the traffic.

