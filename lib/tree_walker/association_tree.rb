module TreeWalker
  class AssociationTree

    attr_accessor :graph, :models_blacklist, :associations_blacklist

    def initialize(graph, models_blacklist={}, associations_blacklist={})
      self.graph = graph
      self.models_blacklist = models_blacklist
      self.associations_blacklist = associations_blacklist
    end

    def generate(start_model)
      root = {}
      visited = Set.new([start_model])
      queue = [[start_model, root]]

      until queue.empty?
        model, tree = queue.shift

        graph[model].sort_by{|child| child[:to]}.each do |child|
          child_model = child[:to]
          if !associations_blacklist.include?([model, child_model]) && !models_blacklist.include?(child_model) && visited.add?(child_model)
            subtree = {}
            tree[child[:label].to_sym] = subtree
            queue << [child_model, subtree]
          end
        end
      end

      root
    end
  end
end