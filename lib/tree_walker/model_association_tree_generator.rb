require 'json'

module TreeWalker
  class ModelAssociationTreeGenerator

    def initialize
      @options = { :specify => [],
                   :inheritance => true,
                   :show_belongs_to => true,
                   :hide_through => true,
                   :transitive => false,
                   :verbose => false,
                   :root => ''
                 }
    end

    def run(start_node, excluded_models=[], excluded_associations=[])
      old_dir = Dir.pwd
      Dir.chdir(@options[:root]) if @options[:root] != ''

      graph = ModelAssociationGraph.new @options

      puts "[START] Generating model association graph"
      result = graph.generate
      puts "[END] Generating model association graph"

      puts "[START] Traversing association graph"
      tree = AssociationTree.new(result, excluded_models, excluded_associations).generate(start_node)
      puts "[END] Traversing association graph"

      Dir.chdir(old_dir)

      tree
    end

  end
end