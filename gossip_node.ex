defmodule GossipNode do
    use GenServer

    def start_link(pid) do
        state = %{msg: 0, adjacent_neighbours: [], handler: pid}
        GenServer.start_link(__MODULE__, state)
    end
    
    def initialise(state), do: {:ok, state}

    def post_msgrcv(pid, msg) do  
        GenServer.cast(pid,{:msgrcv, msg})    
    end

    def decide_adjacents(pid, neighbours_adjacency_matrix) do
        GenServer.call(pid,{:set,neighbours_adjacency_matrix})
    end

    def destroy(pid) do
        GenServer.call(pid, {:kill})
    end

    def handle_cast({:msgrcv, msg}, state) do
        msg = state[:msg] + 1
        state = Map.put(state, :msg, msg)

        cond do
        msg == 1 ->
            Gossip_Protocol.enroll(state[:handler], self())
            pid = Task.async(GossipNode, :send_msg, [state[:adjacent_neighbours],msg])
            state = Map.put(state, :sender, pid)
            {:noreply, state}

        msg > 10 ->
            Task.shutdown(state[:sender], :brutal_kill)
            {:noreply, state}

        true -> {:noreply, state}
        end
    end

    def handle_call({:kill}, _from, state) do
        Task.shutdown(state[:sender], :brutal_kill)
        {:reply, :ok, state}
    end

    def handle_call({:set,neighbours_adjacency_matrix}, _from, state) do
        state = Map.put(state, :adjacent_neighbours, neighbours_adjacency_matrix)
        {:reply, :ok, state}
    end


    def send_msg(adjacent_neighbours, msg) do
        r = adjacent_neighbours |> Enum.random()
        GossipNode.post_msgrcv(r, msg)
        Process.sleep(200)
        send_msg(adjacent_neighbours,msg)
    end

end