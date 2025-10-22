require 'webmock/rspec'

# Desabilita chamadas de rede reais, exceto para localhost
WebMock.disable_net_connect!(allow_localhost: true)