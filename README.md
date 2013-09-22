# Baleen
Baleen is a test runner powered by Docker and Celluloid::IO.
Baleen allows you to run ruby standard tests such as Cucumber or Rspec in totally isolated environment and parallel.

By using Baleen, you can run feature or spec in a dedicated linux container, so test will not affect the state of other tests.
Also, Baleen will speed up your tests since multiple containers run their tests in parallel.

## Requirement
Linux machine with Docker installed

## Installation

TODO

## Usage


Baleen is server-client model. You need to run baleen-server which talks Docker API to Docker and you can use baleen-client to put your request to the server like below.

    $ bundle exec baleen cucumber  --image kimh/baleen-poc --files features/ --work_dir /git/baleen/poc --before_command "source /etc/profile"
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

