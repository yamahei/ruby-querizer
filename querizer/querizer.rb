require 'fileutils'
require File.expand_path("./table", File.dirname(__FILE__))

module Querizer
  class Querizer

    # @param conf hash {
    #   connection settings for target db
    # }
    # @param option hash {
    #   :querize_dir => "queries",
    #   :tables => ["table_name", ...],
    #   :save => boolean,
    # }
    def initialize(conf={}, option={})#=> nil
      @conf = conf
      @dir = option[:querize_dir] || "queries"
      @tables = option[:tables] || []
      @save = option[:save] || true
      @cache = {}
    end

    #abstract method
    def exec(query, params)
      raise RuntimeError.new("'exec' is abstract method.")
    end

    #abstract method
    def tran
      raise RuntimeError.new("'tran' is abstract method.")
    end

    def method_missing(method, *args)
      table = method.to_s
      super unless @tables.include?(table)
      if !@cache[table] then
        @cache[table] = Table.new(table, self, @dir, @save)
      end
      @cache[table]
    end

  end
end
