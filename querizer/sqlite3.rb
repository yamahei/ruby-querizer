require File.expand_path("./querizer", File.dirname(__FILE__))
require "sqlite3"

module Querizer
  class Sqlite3 < Querizer
    def initialize conf={}, option={}
      super conf, option
      @conf = {
       :file => conf[:file] || File.expand_path("./data.sqlite3"),
       :ddl => conf[:ddl] || "",
      }
      create? = !File.exist?(@conf[:file]) && !@conf[:ddl].empty?
      @conn = SQLite3::Database.new @conf[:file]
      if create? then
        db.execute @conf[:ddl]
      end
    end

    def exec query, param={}
      return @conn.execute query, param
    end

    def tran
      begin
        @conn.transaction
        yield
        @conn.commit
      rescue
        @conn.rollback if @conn
        raise $!
      end
    end

    private

  end
end
