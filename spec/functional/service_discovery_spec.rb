require "test_consul"

describe "Service discovery" do
  before do
    TestConsul.start
  end

  after do
    TestConsul.stop
  end

  example "discovering the nodes for a service" do
    consul = Consul.new

    consul.register_service(
      service: "echo",
      node: "echo1",
      address: "localhost",
    )

    expect(consul.services).to include("echo")
  end
end
