module Querizer
  class Table
    def initialize(name, querizer, dir, save)
      @name = name
      @db = querizer
      @dir = File.join(dir, name)
      FileUtils.mkdir_p(@dir)
      @save = save
      @cache = {}
    end

    def insert(record)
      raise ArgumentError.new("record is required.") if !record || record.empty?
      fields = record.keys.map{|field| field.to_s }
      values = record.keys.map{|field| ":#{field.to_s}" }
      query = <<-"EOQ"
        INSERT INTO #{@name} ( #{fields.join(", ")} )
        VALUES ( #{values.join(", ")} )
      EOQ
      @db.exec(query, record)
    end

    def update(params, record)
      raise ArgumentError.new("params is required.") if !params || params.empty?
      raise ArgumentError.new("record is required.") if !record || record.empty?
      _params = record.dup
      sets = params.keys.map{|field|
        key = field.to_s + "_set_params"
        _params[key.to_sym] = params[field]
        "#{field.to_s} = :#{key}"
      }
      query = <<-"EOQ"
        UPDATE #{@name}
        SET #{sets.join(", ")}
        #{where(record)}
      EOQ
      @db.exec(query, _params)
    end

    def delete(record)
      raise ArgumentError.new("record is required.") if !record || record.empty?
      query = <<-"EOQ"
        DELETE FROM #{@name}
        #{where(record)}
      EOQ
      @db.exec(query, record)
    end

    def method_missing(method, *args)
      command = method.to_s
      case command
      when /^select/i then
        where, order = args[0], args[1]
        __selector(command, where, order) || super
      else
        params, order = args[0], args[1]
        __executer(command, params, order) || super
      end
    end

    private

    def __selector(command, where, order)#=> [record] || false
      query = from_file(command)
      unless query then
        query = __parse(command)
        query += order_by(order) if order && !order.empty?
        if @save then
          filename = File.join(@dir, command)
          File.open(filename, "w") {|f| f.puts(query)}
        end
      end
      @cache[command] = query
      @db.exec(query, where)
    end

    def __parse(command)#=>"query"
      entries = []
      if command =~ /_/ then
        entries = command.downcase.split("_")
      else
        entries = command.split(/(?=[A-Z])/).map{|e| e.downcase}
      end
      return __prase_top(entries, "SELECT ")
    end

    def __prase_top(entries, query)#=>"query"
      entry = entries.shift
      if entry != "select" then
        raise ArgumentError.new("Extract queries must start with 'SELECT'.")
      end
      entry = entries.shift
      if entry == "distinct" then
        query += " DISTINCT "
      else
        entries.unshift(entry)
      end
      query += " * FROM #{@name} "
      entry = entries.shift
      case entry
      when "by" then
        return __parse_codition(entries, query + " WHERE ")
      when nil then
        return query
      else
        raise ArgumentError.new("Unknown word is given: #{entry}.")
      end
    end

    def __parse_codition(entries, query)
      entry = entries.shift
      query += " #{entry} = :#{entry} "
      entry = entries.shift
      case entry
      when "and", "or" then
        query += " #{entry.upcase} "
        return __parse_codition(entries, query)
      when nil then
        return query
      else
        raise ArgumentError.new("Unknown word is given: #{entry}.")
      end
    end

    def __executer(command, params={}, order=[])#=> result of query
      query = from_file(command)
      return false unless query
      query += where(params) if params.length > 0
      query += order_by(order) if order.length > 0
      @db.exec(query, params)
    end

    def where(params)#=>"WHERE EXPRESSION AND ..."
      raise ArgumentError.new("params is required.") if !params || params.empty?
      " WHERE " + params.keys.map{|field|
        " #{field.to_s} = :#{field.to_s} "
      }.join(" AND ")
    end

    def order_by(order)#=>"ORDER BY FILED, ..."
      raise ArgumentError.new("order is required.") if !order || order.empty?
      return <<-"EOQ"
        ORDER BY #{order.join(", ")}
      EOQ
    end

    def from_file(file)#=> "query" or false
      raise ArgumentError.new("file is required.") if !file || file.empty?
      return @cache[file] if @cache[file]
      return false unless File.exists?(file)
      @cache[file] = File.open{|f| f.read}
    end
  end
end
