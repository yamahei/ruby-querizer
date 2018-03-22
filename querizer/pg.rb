require File.expand_path("./querizer", File.dirname(__FILE__))
#requiere "pg"

module Querizer
  class Pg < Querizer
    def initialize conf={}, option={}
      super conf, option
      @conf = {
       :host => conf[:host] || "localhost",
       :user => conf[:user] || "postgres",
       :password => conf[:password] || "postgres",
       :dbname => conf[:dbname] || "test",
       :port => conf[:port] || 5432,
      }
      @conn = PG::connect @conf
    end

    def exec query, param={}
      query, _param = *trans_placeholder(query, param)
<<<<<<< HEAD
      return @conn.exec(query, _param)
=======
      p query
      p _param
      return @conn.exec query, _param
>>>>>>> 9eb658f87055ed7d9ec1c1722c2ffbf8f99f2175
    end

    def tran
      begin
        @conn.exec("BEGIN")
        yield
        @conn.exec("COMMIT")
      rescue
        @conn.exec("ROLLBACK") if @conn
        raise $!
      end
    end

    private

    def trans_placeholder query, param#=> [query, param]
      index = 0
      _param = []
      _query = query.gsub(/:\w+/m){|m|
        key = m[1..-1].to_sym
        _param.push(param[key])
        index += 1
        "$#{index}"
      }
      [_query, _param]
    end

  end
end
