require File.expand_path("./querizer", File.dirname(__FILE__))
#requiere "sqlite3"

module Querizer
  class Sqlite < Querizer
    def initialize(conf={}, option={})
      super(conf, option)
      @conf = {
       :file => File.expand_path(conf[:file] || "./db.sqlite"),
      }
      @conn = SQLite3::Database.new(@conf[:file])
    end

    def exec(query, param)
      return @conn.execute(query, param)
    end

    def tran
      begin
        @conn.transaction {
	        yield
        }
      rescue
        raise $!
      end
    end

  end
end
