{ pkgs }:

pkgs.writeTextFile {
  name = "contrail-discovery.conf";
  text = ''
    [DEFAULTS]
    zk_server_ip=localhost
    zk_server_port=2181
    listen_ip_addr=0.0.0.0
    listen_port=5998
    log_local=True
    log_file=/var/log/contrail/discovery.log
    log_level=SYS_DEBUG
    log_local=1
    cassandra_server_list = localhost:9160
    # minimim time to allow client to cache service information (seconds)
    ttl_min=300
    # maximum time to allow client to cache service information (seconds)
    ttl_max=1800

    # health check ping interval <=0 for disabling
    hc_interval=5

    # maximum hearbeats to miss before server will declare publisher out of
    # service.
    hc_max_miss=3

    # use short TTL for agressive rescheduling if all services are not up
    ttl_short=1

    [DNS-SERVER]
    policy=fixed
  '';
}
