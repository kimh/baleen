# Baleen
Baleen is a test runner powered by Docker and Celluloid::IO.
Baleen allows you to run ruby standard tests such as Cucumber or Rspec in totally isolated environment and parallel.

By using Baleen, you can tests in a dedicated linux container, so each test will not affect the state of other tests.
Also, Baleen will speed up your tests since multiple containers run their tests in parallel.

## Requirement
* Linux machine with Docker installed
* ruby-2.0.0 or later

## Installation

    gem install baleen

## Usage
Baleen is server-client model. You need to run baleen-server which talks Docker API and baleen (client) to put your request to the server.

#### Running Baleen server
You can run baleen server with baleen-server command.

    $ baleen-server start

baleen-server will take below options

* --docker_host: specify url or ip of server where Docker server is running. Default: 127.0.0.1
* --docker_port: specify port that Docker server is listening to. Default: 4243
* --port: specify port that Baleen server is listening to. Default: 5533
* --debug: you can specify this option to enable debug mode to print out debug message to console. No argument is required. Default: disabled

#### Running Baleen client
You can run baleen client with simply baleen command. baleen command will take one subcommand to specify which kind of test you want to run on baleen server. With v0.0,1. only cucucmber subcommand is available.

    $ baleen cucumber --image kimh/baleen-poc --files features --work_dir /git/baleen/poc --before_command "source /etc/profile" --concurrency 6

baleen command wil take below options

* --port: specify port number of baleen server. Default: 5533
* --image: specify the name of image that you want to use to run your tests. Mandatory option
* --files: specify directory or file of tests that you want to run. Default is /features with v0.0.1
* --work_dir: specify working directory. Default: ./
* --before_command: specify commands that you want to execute before running your tests. Default: nil
* --concurrency: specify number of containers that you want to run at the same time. Default: 2

## Try Baleen with POC app
If you pull kimh/baleen-poc image to your Docker, you can see how baleen works. In this example, you are running Docker at 192.168.0.1, baleen-server @192.168.0.2 that points to the Docker server, and baleen client to point to the baleen server.

First, pull the image at Docker server

    $ docker pull kimh/baleen-poc

By pulling kimh/baleen-poc, you will have a container that has the latest baleen project, installed under /git.
You need to run Docker with API enabled (Docker server listens 127.0.0.1 by default) by modifying /etc/init/docker.conf.

    $ vi /etc/init/docker.conf

    description     "Docker daemon"

    start on filesystem or runlevel [2345]
    stop on runlevel [!2345]

    respawn

    script
       /usr/bin/docker -d -H=tcp://0.0.0.0:4243/ # Add this line
       #/usr/bin/docker -d                       # and comment out this line
    end script

And restart your machine to apply the new configuration.

Next, run baleen-server. Make sure you specify correct ip of the machine that is running Docker.

    $ baleen-server --docker-host 192.168.0.1

Finally, run baleen. Make sure to specify correct ip of the machine that is running baleen-server. Below command will run all features under /git/baleen/poc with three containers.

    $ baleen cucumber --host 192.168.0.2 --image kimh/baleen-poc --work_dir /git/baleen/poc --before_command "export RAILS_ENV=test; source /etc/profile" --concurrency 3
    [Summary]
    Result: Pass
    Time: 0min 38sec
    12 containers

    [Details]
    Id: 5a836a088480f557bf79a00b0c6e34b36e8432f53ee8b5231b8983d902ae21d9
    status code: 0
    feature file: features/io_bound.feature
    logs:
    ------------------------------------
    Rack::File headers parameter replaces cache_control after Rack 1.5.
    Using the default profile...
    Feature: Benchmark IO intensive feature

      Scenario: Benchmark for IO bound operation # features/io_bound.feature:2
        Then io intensive operation              # features/step_definitions/fake_test_steps.rb:20

    1 scenario (1 passed)
    1 step (1 passed)
    0m1.556s

    Id: 1e25993136553319379a07efd61fbc2b86094151fa25df4da0fc613f8c4fe87c
    status code: 0
    feature file: features/io_bound.feature
    logs:
    ------------------------------------
    Rack::File headers parameter replaces cache_control after Rack 1.5.
    Using the default profile...
    Feature: Benchmark IO intensive feature

      Scenario: Benchmark for IO bound operation # features/io_bound.feature:2
        Then io intensive operation              # features/step_definitions/fake_test_steps.rb:20

    1 scenario (1 passed)
    1 step (1 passed)
    0m1.518s

    ....snip.....

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



