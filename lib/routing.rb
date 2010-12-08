 module Routing
    module MapperExtensions
      def indexers
        @set.add_route("/indexers", {:controller => :indexers, :action => :index})
        @set.add_route("/indexers", {:controller => :indexers, :action => "create", :condition=> {:method=>:post}})
      end
    end
  end
ActionController::Routing::RouteSet::Mapper.send :include, Routing::MapperExtensions