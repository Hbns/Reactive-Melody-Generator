defmodule Deployment_Dsl do
  # Define a macro to handle the 'deploy' DSL
  defmacro deploy(do: block) do
    quote do
      Deployment_Dsl.__handle_block__(unquote(block))
    end
  end

  # Internal function to handle the block of DSL instructions
  def __handle_block__({:__block__, _, expressions}) do
    Enum.map(expressions, &Deployment_Dsl.__handle_expression__/1)
  end

  def __handle_block__(expression) do
    Deployment_Dsl.__handle_expression__(expression)
  end

  # Internal function to handle each DSL expression
  def __handle_expression__({:start_vm, _, [option]}) do
    quote do
      Deployment_Dsl.start_vm(unquote(option))
    end
  end

  def __handle_expression__({:nodes?, _, _}) do
    quote do
      Deployment_Dsl.nodes()
    end
  end


  def __handle_expression__(:ok) do
    quote do
      IO.puts("Received :ok in handle_expression")
    end
  end

  # Define the function that will be called by the macro
  def start_vm(option) do
    IO.puts("Starting VM with option: #{inspect(option)}")
    # Add the logic to start the VM here
  end

  def nodes? do
    nodes = Node.list()
    if Enum.empty?(nodes) do
      IO.puts("No nodes available")
    else
      IO.inspect(nodes, label: "List of nodes: ")
    end

  end
end
