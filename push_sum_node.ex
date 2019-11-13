defmodule PushSumNode do
    use GenServer

    def start_link(s,w,pid) do
        state = %{not_changed_last: 0, adjacents: [], s: s, w: w, handler: pid}
        GenServer.start_link(__MODULE__, state)
    end
    
    def initialise(state), do: {:ok, state}

    def post_msgrcv(pid, msg) do  
        GenServer.cast(pid,{:rcvmsg, msg})    
    end

    def decide_adjacent(pid, adjacency_list) do
        GenServer.call(pid,{:put,adjacency_list})
    end
      
    def handle_call({:put,adjacency_list}, _from, state) do
        state = Map.put(state, :adjacents, adjacency_list)
        {:reply, :ok, state}
    end

    def handle_cast({:rcvmsg, {s_msg,w_msg}}, state) do
        s = state[:s]
        w = state[:w]
    
        s_new = (s + s_msg)/2
        w_new = (w + w_msg)/2

        difference_in_ratio = (s/w - s_new/w_new)
        
        if abs(difference_in_ratio) < @threshold and state[:not_changed_last] > 2 do
        PushSum.register(state[:handler], s_new/w_new, self())
        else
            r = state[:adjacents] |> Enum.filter(fn x-> Process.alive?(x) end)
            if length(r) > 0 do 
                PushSumNode.post_msgrcv(Enum.random(r), {s_new, w_new})
            else
                PushSum.register(state[:handler], s_new/w_new, self())
            end
        end

        state = Map.put(state,:s, s_new)
        state = Map.put(state,:s, w_new)
        not_changed_last =  if abs(difference_in_ratio) < 0.00000001, do: state[:not_changed_last] + 1, else: 0
        state = Map.put(state, :not_changed_last, not_changed_last) 
        {:noreply, state}
    end

    


end