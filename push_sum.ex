defmodule PushSum_Protocol do

    use GenServer

    def start_link(pid) do
      state = %{nodes: [], total: 0, handler: pid, received: 0}
      GenServer.start_link(__MODULE__, state)
    end
  
    def initialise(state), do: {:ok, state}

    def enroll(pid, sum,pid) do
        GenServer.cast(pid,{:enroll,sum,pid})
    end
    
    def push_sum_proc(pid, n,structure) do
      GenServer.cast(pid, {:process,n,structure})
    end
       
    def handle_cast({:process,n,structure},state) do
      nodes = 1..n |> Enum.map(fn x-> {:ok,pid} = PushSumNode.start_link(x,1,self()); pid end)
      grid = Topologies_Implemented.structure(nodes, structure)
      nodes |> Enum.map(fn x-> PushSumNode.decide_adjacent(x,grid[x]) end)

     
      PushSumNode.post_msgrcv(Enum.random(nodes), {0,0})

      state =Map.put(state, :nodes, nodes)
      state = Map.put(state, :total, n)
      {:noreply,state}
    end 

    def handle_cast({:enroll, sum,pid}, state) do
        received = state[:received] + 1
        
        GenServer.stop(pid)

        cond do
            0.9*state[:total] < received  ->
                send(state[:handler], {:finished, "Push Sum Protocol converges"})
                {:noreply,state}

            true ->
                n = state[:nodes] -- [pid]
                PushSumNode.post_msgrcv(Enum.random(n), {0,0})
                state = Map.put(state, :nodes, n)
                state = Map.put(state, :received, received) 
                {:noreply,state}
        end

    
    
   end
end