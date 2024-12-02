# frozen_string_literal: true

RSpec.describe Washcloth do
  after { Washcloth.reset }

  it "has a version number" do
    expect(Washcloth::VERSION).not_to be nil
  end

  it "cleans data that includes XML" do
    Washcloth.filter(:password)
    result = Washcloth.clean(curl_error)

    expect(result).to include("<Password>")
    expect(result).to include("</Password>")
    expect(result).not_to include("MY_AWESOME_PASSWORD")
  end

  it "cleans data that includes serialized ActiveRecord" do
    Washcloth.filter(:encrypted_password)
    result = Washcloth.clean(active_record_error)

    expect(result).to include("encrypted_password:")
    expect(result).not_to include("THIS IS MY PASSWORD")
  end

  it "defaults to replacing each character with asterisks" do
    Washcloth.filter(:encrypted_password)
    result = Washcloth.clean(%(<User encrypted_password: "THIS IS MY PASSWORD">))

    expect(result).to eq %(<User encrypted_password: "*******************">)
  end

  it "allows for replacing the raw value" do
    Washcloth.filter(:encrypted_password, filter: Washcloth.filters.static("[FILTERED]"))
    result = Washcloth.clean(%(<User encrypted_password: "THIS IS MY PASSWORD">))

    expect(result).to eq %(<User encrypted_password: "[FILTERED]">)
  end

  it "allows for calling with a block" do
    Washcloth.filter(:encrypted_password, filter: Washcloth.filters.block(->(value) { value.reverse }))
    result = Washcloth.clean(%(Hello from user #<User encrypted_password: "12345">))

    expect(result).to eq %(Hello from user #<User encrypted_password: "54321">)
  end

  def curl_error
    <<~ERROR
      Error in request: * ------------------------------------------------------------------------------ (RuntimeError)
      * Executing entry 1
      *
      * Cookie store:
      *
      * Request:
      * POST https://www.example.com
      * Content-Type: text/xml; charset=utf-8
      * SOAPAction: http://tempuri.org/Service/Action
      *
      * Request can be run with the following curl command:
      * curl --header 'Content-Type: text/xml; charset=utf-8' --header 'SOAPAction: http://tempuri.org/Service/Action' --data $'<?xml version="1.0" encoding="utf-8"?>\n<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">\n  <soap:Body>\n    <Action xmlns="http://tempuri.org/Service">\n      <UserName>username</UserName>\n      <Password>MY_AWESOME_PASSWORD</Password>\n      </Action>\n  </soap:Body>\n</soap:Envelope>\n' 'https://www.example.com/service.asmx'
      *
      > POST /service.asmx HTTP/2
      > Host: www.example.com
      > Accept: */*
      > Content-Type: text/xml; charset=utf-8
      > SOAPAction: http://tempuri.org/Service/Action
      > User-Agent: hurl/4.3.0
      >
      error: HTTP connection
        --> -:1:6
         |
       1 | POST https://www.example.com/service.asmx
         |      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (28) Operation timed out after 300002 milliseconds with 0 bytes received
         |
    ERROR
  end

  def active_record_error
    <<~ERROR
      Error fetching Entity for business 1, user #<User id: 1, email: "person@example.com", encrypted_password: "THIS IS MY PASSWORD", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil>: undefined method `find' for nil:NilClass
    ERROR
  end
end
