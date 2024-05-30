defmodule Dsl_Deployer do
  require Deployment_Dsl

  def run do
    Deployment_Dsl.deploy do
      Deployment_Dsl.start_vm [:n1, :f1, :t1, :s1]
      Deployment_Dsl.start_vm :other_option
      Deployment_Dsl.nodes?()
    end

  end
end
