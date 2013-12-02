From kimh/baleen-server
Expose 5533:5533
Entrypoint ["/bin/bash", "-c", "source /etc/profile && baleen-server start --docker_host 172.17.42.1"]
