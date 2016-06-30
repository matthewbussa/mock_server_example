require 'mockserver-client'

class ExpectationGenerator
  include MockServer
  include MockServer::Model::DSL

  def initialize(server_port)
    @client = MockServerClient.new('localhost', server_port)
    @client.reset()
  end

  def simple_get_expectation
    expectation = expectation do |expectation|
      expectation.request do |request|
        request.method = 'GET'
        request.path = '/simple-get'
      end

      expectation.response do |response|
        response.status_code = 200
        response.body = "Success"
      end
    end

    expectation.times = unlimited() #once()
    @client.register(expectation)
  end

  def match_request_expectation
    expectation = expectation do |expectation|
      expectation.request do |request|
        request.method = 'POST'
        request.path = '/json-match-example'
        request.body = exact({key: 'foo', value: 'bar'}.to_json)
      end

      expectation.response do |response|
        response.status_code = 200
        response.headers << header('Content-Type', 'application/json')
        response.body = '{"Success": "tada"}'
      end
    end

    expectation.times = unlimited()
    @client.register(expectation)
  end

  def post_expectation
    expectation = expectation do |expectation|
      expectation.request do |request|
        request.method = 'POST'
        request.path = '/post'
      end

      expectation.response do |response|
        response.status_code = 200
        response.headers << header('Content-Type', 'application/json')
        response.body = '{"Success": "post was successful"}'
      end
    end

    expectation.times = unlimited()
    @client.register(expectation)

  end

  def forward
    expectation = expectation do |expectation|
     expectation.request do |request|
        request.method = 'GET'
        request.path = '/'
     end

    expectation.forward do |forward|
        forward.host = 'www.google.com'
        forward.port = 80
        forward.scheme = :HTTP
    end
  end

    expectation.times = unlimited()
    @client.register(expectation)
  end
end

mock_server = ExpectationGenerator.new(8080)
mock_server.simple_get_expectation
mock_server.match_request_expectation  #request body = {"key":"foo","value":"bar"}
mock_server.post_expectation
mock_server.cookie_expectation
mock_server.forward


