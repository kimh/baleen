# Baleen
Baleen is a test runner powered by Docker.
Baleen allows you to run ruby standard tests such as Cucumber or Rspec in totally isolated environment and parallel.

By using Baleen, you can run a each test in a dedicated linux container, so each test will not affect the state of other tests.
Also, Baleen will speed up your tests since multiple containers run their tests in parallel.

## Supproted Framework
As of v0.2, only cucumber tests are supported.

## Requirement
* Docker v0.7 or later
* ruby-2.0.0 or later

## Installation

    gem install baleen

This will install both client and server.

## Usage
Baleen is server-client model. By installing baleen gem, you will get two executables: baleen-server (server) and baleen (client).

You use baleen-server which receives request from client and interacts Docker via remote API.

#### baleen-server

    $ baleen-server start

baleen-server will take below options

* --docker_host: specify url or ip of server where Docker server is running. Default: 127.0.0.1
* --docker_port: specify port that Docker server is listening to. Default: 4243
* --port: specify port that Baleen server is listening to. Default: 5533
* --dir: working directory for docker-server. Default: ./baleen 
* --project_file: specify file path for project. Default: ~/baleen.yml
* --ci: specify whether running CI server to receive github post receive hook. Default: false
* --ci-port: specify port to listen github post-receive hook. Default: 4567
* --log-level: specify log level. It is should be either "debug", "warn", or "error"
* --daemon: running baleen-server on background. Default: false

#### baleen

    $ baleen subcommand --option1 --option2

baleen command wil take two subcommands

* project: specify project to run

**project** subcommand will take one more subcommand to specify project name

* cucumber: run cucumber tests

**cucumber** subcommand wil take following options

* --image: specify the name of image that you want to use to run your tests. Mandatory option
* --files: specify directory or file of tests that you want to run. Default is /features with v0.0.1
* --work_dir: specify working directory. Default: ./
* --before_command: specify commands that you want to execute before running your tests. Default: nil
* --concurrency: specify number of containers that you want to run at the same time. Default: 2

Both subcommands can take following options

* --baleen_server: specify host where baleen-server is running. Default: 127.0.0.1
* --port: specify port number of baleen server. Default: 5533
* --debug: running client on debug mode. As of v0.2, debugging only printing celluloid debug messages to console.

### Using Baleen
There are mainly two ways to use baleen

* on-the-fly: You pass options to baleen-server from baleen cli.
* project: You write baleen.yml file for projects that will be loaded baleen-server at boot time.

#### On-the-fly
With on-the-fly way, you will use baleen cli from shell. Benefit of using this way is you can change options flexibly. This is suitable when you need to figure out what options you need to pass to run your tests successfully.

Here is an example to use baleen cli to let baleen-server to run test on the fly. With this, you are running cucumber tests by using kimh/baleen-poc Docker image and running 6 containers, each container running one feature, at the same time.

    $ baleen cucumber --image kimh/baleen-poc --files features --work_dir /git/baleen/poc --before_command "source /etc/profile" --concurrency 6

#### Project
By using project, you can save test configurations in a yaml file which is loaded by baleen-server at boot time. After that, you can kick the project from baleen cli simply by specifying project name like this.

    $ baleen project my-project

Project file consists of project name section that has 3 sub sections (runner, framework, and ci) and each sub section has more sections. You can specify multiple projects in a single file. Here is an example of project file.

    # Project name section
    baleen-poc:
      # Runner section
      runner:
        image: "kimh/baleen-poc"
        work_dir: /baleen-poc
        concurrency: 3
        before_command: |
          source /etc/profile
          export RAILS_ENV=test
          bundle exec rake db:migrate

      # Framework section
      framework:
        type: cucumber
        features: ./features/t1.feature

      # CI section
      ci:
        build: true
        url: https://github.com/kimh/baleen-poc
        repo: baleen-poc
        branch: master

##### Project name section
You must have one project name section to specify the name of project.

Under project section, you should have 3 sub sections. Each section has mandatory and optional sections. If you don't specify optional sections, it follows the same default value as the equivalent baleen cli option if exists.
##### Runner section
You must have one runner section. Runner section has following sub sections.

_Mandatory_

 * image: Name of Docker image. This is equivalent to --image option of baleen cli.

_Optional_

 * work_dir: Working directory. This is equivalent to --work_dir option of baleen cli.
 * concurrency: Number of concurrency. This is equivalent to --concurrency option of baleen cli.
 * before_command: Specify commands that you want to be executed before running tests. Note that you can use block syntax of yaml to specify multiple commands. This is equivalent to --before_command option of baleen cli.

##### Framework section
You must have one framework section to specify settings for test frameworks to run.

_Mandatory_

 * type: Specify the name of test framework. As of v0.2, only cucumber is allowed to specify. This is equivalent to cucumber subcommand of baleen cli.


_Optional_

Below sections are optional. If you don't specify, it follows the same default value as the equivalent baleen cli option.

 * featutes: Specify feature files to be run. This section is only valid only when you specify cucumber at type. This is equivalent to --files option of baleen cli.

##### CI section
You must have one ci section to specify CI (continuous integration) setting. Note that this section will be ignored if your don't give --ci option to baleen-server.

_Mandatory_

  * repo: Name of repository.
  * url: URL of your github repository to pull.

_Optional_

  * build: Specify whether you want to receive github post receive hook to run your projects automatically. This is equivalent to --ci option of baleen-server command.
  * branch: Branch to pull and use it for tests.

## Try Baleen
Please try Baleen and give me your feedback!!

In this section, you will use baleen to run cucumber tests of [poc](https://github.com/kimh/baleen-poc "baleen-poc app"). baleen-poc is a fake app with some cucumber features to show how baleen runs cucumber tests.

Here, I am assuming two different scenarios: Linux user and Mac user. If "Only for Mac user", Linux user can skip the section. Otherwise, both users have to do the section.

#### Installing Docker
First of all, you need to install Docker. Please follow [official page](https://www.docker.io/gettingstarted/#h_installation "official page").

#### Enable remote API
Docker only allows access through unix socket by default. Since baleen relies on Docker remote API, you need to enable the access through TCP.

Open _/etc/init/docker.conf_ and modify **DOCKER_OPTS**.

    $ vi /etc/init/docker.conf
    description "Docker daemon"

    start on filesystem and started lxc-net
    stop on runlevel [!2345]

    respawn

    script
    	DOCKER=/usr/bin/$UPSTART_JOB
    	DOCKER_OPTS="-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock" # Add this line
    	if [ -f /etc/default/$UPSTART_JOB ]; then
    		. /etc/default/$UPSTART_JOB
    	fi
    	"$DOCKER" -d $DOCKER_OPTS
    end script

Restart docker

    $ restart docker

#### Configure port forwarding for Vagrant (Only for Mac user)
_You can skip this step if you use Linux_

Add following line to Vagrant.configure block to forward 5533 port

    config.vm.network :forwarded_port, guest: 5533, host: 5533

And run Vagrant and Docker.

#### Pull images

    $ docker pull kimh/baleen-server
    $ docker pull kimh/baleen-poc

#### Running baleen-server container

    $ docker run -i -t -p 5533:5533 kimh/baleen-server

#### Use baleen cli and run baleen-poc project

    $ baleen project baleen-poc
    Start container f77b2608137e
    Start container 722f5d4a8662
    Start container 85f8778d797d
    Start container 4aa0aebbf725
    Start container 693055e07f84
    Finish container 722f5d4a8662
    Finish container 85f8778d797d
    Finish container 693055e07f84
    Finish container 4aa0aebbf725
    Finish container f77b2608137e
    Start container a2c45645d42a
    Start container cf34f905be5a
    Start container 636d390ed150
    Start container 1f506e49f156
    Start container 887295220ca6
    Finish container 1f506e49f156
    Finish container 887295220ca6
    Finish container 636d390ed150
    Finish container cf34f905be5a
    Finish container a2c45645d42a
    Start container e6ada0b3405e
    Finish container e6ada0b3405e

    [Summary]
    Result: Pass
    Time: 0min 41sec

    [Details]
    Id: f77b2608137e
    status code: 0
    feature file: ./features/t6.feature

    Id: 722f5d4a8662
    status code: 0
    feature file: ./features/t1.feature

    STDOUT:
    ------------------------------------
    Using the default profile...
    Feature: t1

      Scenario: Benchmark for IO bound operation # ./features/t1.feature:2
        Then io intensive operation              # features/step_definitions/fake_test_steps.rb:24

      Scenario: Benchmark for CPU bound operation # ./features/t1.feature:5
        Then cpu intensive operation              # features/step_definitions/fake_test_steps.rb:9

      Scenario: Benchmark for IO bound operation # ./features/t1.feature:8
        Then io intensive operation              # features/step_definitions/fake_test_steps.rb:24

      Scenario: Benchmark for CPU bound operation # ./features/t1.feature:11
        Then cpu intensive operation              # features/step_definitions/fake_test_steps.rb:9

    4 scenarios (4 passed)
    4 steps (4 passed)
    0m4.723s

    STDERR:
    ------------------------------------
    Rack::File headers parameter replaces cache_control after Rack 1.5.

    ....snip.....

### How Baleen works (briefly explained)
So how baleen-poc tests are run?

####Step 1. Breaking up features/ directoires
First, baleen-server need to know how many test files exist under the directory specified by features section of baleen.yml.
To do this, it runs a container by using the image specified at image section and run __find ./features__ bash script to output each single files.

####Step 2. Run containers
baleen-server will run containers to run actual tests. It depends on your configuration, but the most simple command for containers are like this.

    $ cd work_dir && bundle exec cucumber $feature_file

where $feature_file is each cucumber file passed from step 1. baleen-server will run proper number of containers according to concurrency.

####Step 3. Wait containers
baleen-server then monitor and wait for each container to finish given test. This will be done asynchronously thanks to Celluloid.

####Step 4. Report result
when all containers finish running tests, it collects STDOUT of all containers to see the rest result and display to user.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. Work hard!!



