defmodule Topologies_Implemented do

def grid_form(topo_node,:line) do
    n = length(topo_node)
    Enum.zip(1..n, topo_node) |> Enum.into(%{})
end

def grid_form(topo_node, :rand2D) do
    topo_node |> Enum.map(fn f -> {f, [:rand.uniform(), :rand.uniform()]} end) |> Enum.into(%{})
end

def grid_form(topo_node, :torus) do
    n = length(topo_node)
    l =  trunc(:math.ceil(:math.pow(n,1/3)))
    cuboid = for i <- 0..l-1, j <- 0..l-1, k <- 0..l-1, do: [i,j,k] 
    Enum.zip(cuboid,topo_node) |> Enum.into(%{})
end

def grid_form(topo_node, :honeycomb) do
    n = length(topo_node)
    t =  trunc(:math.pow(n/6,1/2)) 
    honeycomb = for i <- -t+1..t, j <- -t+1..t, k <- -t+1..t, check_validity(i,j,k), do: [i,j,k]
    Enum.zip(honeycomb, topo_node) |> Enum.into(%{})
end

def check_validity(i,j,k) when i+j+k <= 2 and i+j+k >=1, do: true

def check_validity(_,_,_), do: false



def get_adjacency_list(f,topo_node,nodes_in_grid,:rand2D) do
    topo_node |> Enum.filter(fn k-> k != f end) |> Enum.filter(fn k -> distance_square(nodes_in_grid[k],nodes_in_grid[f]) <= 0.01 end)
end

def get_adjacency_list([x,y,z],l,nodes_in_grid,:torus) do
    a1 = rem((x+1),l)
    b1 = rem((y+1),l)
    c1 = rem((z+1),l)
    a2 =  if (x == 0), do: l-1, else: x-1
    b2 =  if (y ==0), do: l-1, else: y-1
    c2 =  if (z ==0), do: l-1, else: z-1
    nc = [[a1,y,z],[a2,y,z],[x,b1,z],[x,b2,z],[x,y,c1],[x,y,c2]]
    nc |> Enum.map(fn f -> nodes_in_grid[f] end)
end 

def get_adjacency_list(f,n,nodes_in_grid,:line) do
    cond do
        f == 1 -> [nodes_in_grid[2]]
        f == n -> [nodes_in_grid[n-1]]
        true -> [nodes_in_grid[f-1], nodes_in_grid[f+1]]
    end
end

def get_adjacency_list(f, topo_node, :full), do: topo_node--[f]

def get_adjacency_list([x,y,z], nodes_in_grid, :randhoneycomb) do
    l = [[x+1,y,z],[x-1,y,z],[x,y+1,z],[x,y-1,z],[x,y,z-1],[x,y,z+1]]
    r = l |> Enum.map(fn f ->nodes_in_grid[f] end) |> Enum.filter(fn f -> f != nil end)
    {_,rand} = Enum.random(nodes_in_grid)
    r ++ [rand]
end

def get_adjacency_list([x,y,z], nodes_in_grid, :honeycomb) do
    l = [[x+1,y,z],[x-1,y,z],[x,y+1,z],[x,y-1,z],[x,y,z-1],[x,y,z+1]]
    l |> Enum.map(fn f ->nodes_in_grid[f] end) |> Enum.filter(fn f -> f != nil end)
end



def distance_square([a,b],[c,d]), do: :math.pow((c-a),2) + :math.pow((d-b),2)




def structure(topo_node, :full) do
    topo_node |> Enum.map(fn f -> {f , get_adjacency_list(f,topo_node, :full)} end) |> Enum.into(%{})
end

def structure(topo_node, :rand2D) do
    nodes_in_grid = grid_form(topo_node, :rand2D)
    topo_node |> Enum.map(fn f -> {f, get_adjacency_list(f,topo_node,nodes_in_grid,:rand2D)} end) |> Enum.into(%{})
end

def structure(topo_node, :torus) do
    n =  length(topo_node)
    l =  trunc(:math.ceil(:math.pow(n,1/3)))
    nodes_in_grid = grid_form(topo_node, :torus)
    Map.keys(nodes_in_grid) |> Enum.map(fn f-> {nodes_in_grid[f], get_adjacency_list(f,l,nodes_in_grid,:torus)} end) |> Enum.into(%{})
end

def structure(topo_node, :line) do
    n = length(topo_node)
    nodes_in_grid = grid_form(topo_node,:line)
    1..n |> Enum.map(fn f -> {nodes_in_grid[f], get_adjacency_list(f,n,nodes_in_grid,:line)} end) |> Enum.into(%{})
end

def structure(topo_node, :honeycomb) do
    nodes_in_grid = grid_form(topo_node, :honeycomb)
    Map.keys(nodes_in_grid) |> Enum.map(fn f-> {nodes_in_grid[f], get_adjacency_list(f,nodes_in_grid,:honeycomb)} end) |> Enum.into(%{})
end

def structure(topo_node, :randhoneycomb) do
    nodes_in_grid = grid_form(topo_node, :honeycomb)
    Map.keys(nodes_in_grid) |> Enum.map(fn f-> {nodes_in_grid[f], get_adjacency_list(f,nodes_in_grid,:randhoneycomb)} end) |> Enum.into(%{})
end

end