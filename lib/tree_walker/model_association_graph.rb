# taken from RailRoady - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)

module TreeWalker
  class ModelAssociationGraph

    def initialize(options)
      @options = options
      @graph = {}
      @habtm = []
    end

    def generate
      get_files.each do |f|
        begin
          process_class extract_class_name(f).constantize
        rescue Exception
          STDERR.puts "Warning: exception #{$!} raised while trying to load model class #{f}"
        end
      end
      optimize
    end

    def optimize
      @graph.each do |class_name, associations|
        associations.select! do |association|
          if association[:type] != 'is-a'
            @graph[association[:to]]
          elsif association[:type] == 'belongs_to'
            !@graph[association[:to]] || !@graph[association[:to]].select {|reverse_assoc| reverse_assoc[:to] == association[:from] && %w[one_one one_many].include?(association[:type])}.count
          else
            true
          end
        end
      end

      @graph
    end

    def get_files(prefix ='')
      files = !@options[:specify].empty? ? Dir.glob(@options[:specify]) : Dir.glob(prefix << "app/models/**/*.rb")
    end

    def process_class(current_class)
      STDERR.puts "Processing #{current_class}" if @options[:verbose]

      generated = process_active_record_model(current_class) if current_class.respond_to?'reflect_on_all_associations'

      if @options[:inheritance] && generated && include_inheritance?(current_class)
        add_edge(current_class.name, { type: 'is-a', from: current_class.superclass.name, to: current_class.name})
      end
    end

    def include_inheritance?(current_class)
      STDERR.puts current_class.superclass if @options[:verbose]
      (defined?(ActiveRecord::Base) && current_class.superclass != ActiveRecord::Base) &&
      (current_class.superclass != Object)
    end

    def process_active_record_model(current_class)
      associations = current_class.reflect_on_all_associations
      if @options[:inheritance] && ! @options[:transitive]
        superclass_associations = current_class.superclass.reflect_on_all_associations
        associations = associations.select{|a| ! superclass_associations.include? a}
      end

      associations.each do |a|
        process_association current_class.name, a
      end

      true
    end

    def process_association(class_name, assoc)
      STDERR.puts "- Processing model association #{assoc.name.to_s}" if @options[:verbose]

      macro = assoc.macro.to_s
      return if %w[belongs_to referenced_in].include?(macro) && !@options[:show_belongs_to]

      through = assoc.options.include?(:through)
      return if through && @options[:hide_through]

      assoc_class_name = assoc.class_name rescue nil
      assoc_class_name ||= assoc.name.to_s.underscore.singularize.camelize

      assoc_name = assoc.name.to_s

      if class_name.include?("::") && !assoc_class_name.include?("::")
        assoc_class_name = class_name.split("::")[0..-2].push(assoc_class_name).join("::")
      end
      assoc_class_name.gsub!(%r{^::}, '')

      if %w[has_one references_one embeds_one].include?(macro)
        assoc_type = 'one_one'
      elsif macro == 'has_many' && (!assoc.options[:through]) ||
            %w[references_many embeds_many].include?(macro)
        assoc_type = 'one_many'
      elsif %w[belongs_to referenced_in].include?(macro)
        assoc_type = 'belongs_to'
      else
        return if @habtm.include? [assoc_class_name, class_name, assoc_name]
        assoc_type = 'many_many'
        @habtm << [class_name, assoc_class_name, assoc_name]
      end

      add_edge(class_name, {type: assoc_type, from: class_name, to: assoc_class_name, label: assoc_name})
    end

    private

    def add_edge(class_name, association)
      @graph[class_name] ||= []
      @graph[class_name] << association
    end

    def extract_class_name(filename)
      filename.split('/')[2..-1].collect { |i| i.camelize }.join('::').chomp(".rb")
    end

  end
end
