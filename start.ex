defmodule Start do 

    def start(process,n,topology) do

        n = round_nodes(n,topology)
        IO.puts(n)
        cond do
        process == :gossip ->  
            {:ok, gossip_manager} = Gossip_Protocol.start_link(self())
            IO.puts("Starting Gossip for #{n} nodes with #{:topology}")
            Gossip_Protocol.gossip_proc(gossip_manager,n,topology)
            prev = System.monotonic_time(:second)
            receive do
                {:finished, message}  -> IO.puts(message)
            end
            next = System.monotonic_time(:millisecond)
            IO.puts("Time taken #{(next-prev)}")

        process == :pushsum -> 
            {:ok, pushsum_manager} = PushSum.start_link(self())
            IO.puts("Starting PushSum for #{n} nodes with #{:topology}")
            PushSum.process(pushsum_manager,n,topology)
            prev = System.monotonic_time(:millisecond)
            receive do
                {:finished, message}  -> IO.puts(message)
            after  
                180000-> IO.puts("Look like a timeout. Some nodes may be isoltaed")
            end

            next = System.monotonic_time(:millisecond)
            IO.puts("Time taken #{(next-prev)}")
        end

    end


    def round_nodes(n,topology) do
        cond do
            topology == :torus -> k = trunc(:math.ceil(:math.pow(n,1/3))); k*k*k

            topology == :honeycomb or topology == :randhoneycomb -> k = trunc(:math.ceil(:math.pow(n/6,1/2))); 6*k*k

            true -> n
        end
    end

end
