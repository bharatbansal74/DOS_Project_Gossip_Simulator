defmodule MyProgram do
    [num_nodes,topology,algorithm]  = System.argv()
    
    num_nodes = elem(Integer.parse(num_nodes),0)

    algorithm = if algorithm == "push-sum", do: :push_sum, else: :gossip
    topology =  if topology == "3Dtorus", do: :torus, else: String.to_atom(topology)
    
    ## Doing this because appraently atom name cant start with integer
    Start.start(algorithm,num_nodes,topology)
end