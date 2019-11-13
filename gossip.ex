defmodule Gossip_Protocol do

    use GenServer

    def start_link(pid) do
      state = %{nodes: [], total: 0, manager: pid, rcvd: 0}
      GenServer.start_link(__MODULE__, state)
    end
  
    def initialise(state), do: {:ok, state}

    def enroll(pid, n_pid) do
        GenServer.cast(pid,{:enroll,n_pid})
    end
    
    def gossip_proc(pid, n,topo_struc) do
      GenServer.cast(pid, {:proc,n,topo_struc})
    end

    def handle_cast({:enroll, _}, state) do
        received = state[:rcvd] + 1
        IO.puts("Recieved #{received} messages")
        if state[:total] == received do
          send(state[:manager], {:finished, "All Nodes Have Message"})
          state[:nodes] |> Enum.map(fn f -> GossipNode.kill_sender(f) end)
          state[:nodes] |> Enum.map(fn f -> GenServer.stop(f) end)
        end
        state = Map.put(state, :rcvd, received)
        {:noreply,state}
    end 

    def handle_cast({:proc,n,topo_struc},state) do
      nodes = 1..n |> Enum.map(fn _-> {:ok,pid} = GossipNode.start_link(self()); pid end)
      grid = Topologies_Implemented.structure(nodes, topo_struc)
      nodes |> Enum.map(fn f-> GossipNode.decide_adjacents(f,grid[f]) end)

       node = Enum.random(nodes)
      GossipNode.post_msgrcv(node, "RUMOR")

      state =Map.put(state, :nodes, nodes)
      state = Map.put(state, :total, n)
      {:noreply,state}
    end 

    
  end
