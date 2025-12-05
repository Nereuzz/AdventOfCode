const std = @import("std");
const HashMap = std.HashMap;
const ArrayList = std.ArrayList;

const Node = usize;
const Edge = struct {
    to: Node,
    weight: u32,
};

const Graph = []const []Edge;

pub fn dijkstra(graph: Graph, start: Node) ![][]Node {
    const n = graph.len();
    var dist = try std.ArrayList(u32).init(std.heap.page_allocator);
    var prev = try std.ArrayList([]Node).init(std.heap.page_allocator);
    
    const inf = u32(0xFFFFFFFF);
    
    // Initialize distances
    try dist.ensureCapacity(n);
    for (i in 0..n) {
        try dist.append(inf);
    }
    
    // Initialize previous paths
    try prev.ensureCapacity(n);
    for (i in 0..n) {
        try prev.append(null);
    }
    
    dist[start] = 0;

    // Min-heap for priority queue
    var pq = try std.ArrayList(Node).init(std.heap.page_allocator);
    try pq.append(start);
    
    while (pq.len() > 0) {
        var u = pq.pop() orelse break;
        const currentDist = dist[u];
        
        for (edge in graph[u]) {
            const v = edge.to;
            const alt = currentDist + edge.weight;

            if (alt < dist[v]) {
                dist[v] = alt;
                prev[v] = try prev.append(u);
                try pq.append(v);
            } else if (alt == dist[v]) {
                // If the new path has the same distance, add this node to the possible paths
                try prev[v].append(u);
            }
        }
    }
    
    // Function to reconstruct all shortest paths from the start to a given target node
    fn reconstructPaths(target: Node) [][]Node {
        var allPaths = try std.ArrayList([]Node).init(std.heap.page_allocator);
        
        // Base case: if there is no path
        if (prev[target] == null) {
            return allPaths.toSlice();
        }
        
        // Recursive case: traverse all possible predecessors
        fn findPaths(node: Node, currentPath: []Node) void {
            if (node == start) {
                try allPaths.append(currentPath);
                return;
            }
            
            for (pred in prev[node]) {
                var newPath = currentPath;
                try newPath.append(pred);
                findPaths(pred, newPath);
            }
        }

        var startPath = []Node{target};
        findPaths(target, startPath);
        
        return allPaths.toSlice();
    }
    
    return reconstructPaths(n - 1); // Return all paths to the last node as an example
}
