require "excon"
require "json"

module Consul
  class Client
    DEFAULT_URL = ENV.fetch("CONSUL_URL", "http://localhost:8500")

    def initialize(url: DEFAULT_URL)
      @connection = Excon.new(url)
    end

    def services
      response = @connection.get(
        path: "/v1/catalog/services",
        expects: 200,
      )

      data = JSON.parse(response.body)
      data.keys
    end

    def register_service(service:, node:, address:)
      data = {
        "Node" => node,
        "Address" => address,
        "Service" => {
          "Service" => service,
        },
      }

      response = @connection.post(
        path: "/v1/catalog/register",
        body: JSON.dump(data),
        expects: 200,
      )
    end
  end
end
