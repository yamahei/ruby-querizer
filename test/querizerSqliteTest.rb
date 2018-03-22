require "../querizer/sqlite"
require "sqlite3"

file = File.expand_path("./test.sqlite")
File.delete(file) if File.exist?(file)
conf = {
	:file => file,
}
dir = "sqlite3_test_queries"
option = {
  :querize_dir => dir,
  :tables => "parent,child".split(","),
  :save => true,
  :debug => true,
}
SQLite3::Database.new(file).execute_batch <<-"EOD"
  DROP VIEW IF EXISTS list;
  DROP TABLE IF EXISTS child;
  DROP TABLE IF EXISTS parent;
  CREATE TABLE parent(
    id SERIAL PRIMARY KEY,
    num INTEGER DEFAULT NULL,
    category TEXT DEFAULT NULL,
    at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  CREATE TABLE child(
    parent BIGINT,
    id SERIAL,
    attribute TEXT NOT NULL,
    value TEXT DEFAULT NULL,
    at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(parent, id)
  );
  CREATE VIEW list AS
    SELECT p.id AS parent_id, c.id AS child_id,
      p.num, p.category, c.attribute, c.value
    FROM parent AS p
    LEFT JOIN child AS c ON p.id = c.parent
    ORDER BY p.at, c.at
  ;
EOD

q = Querizer::Sqlite.new(conf, option)

load "./querizerTest.rb"
test(q, dir)
