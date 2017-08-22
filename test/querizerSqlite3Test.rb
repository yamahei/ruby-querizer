# TODO: tests isnt all ok.

require "../querizer/sqlite3"
require "sqlite3"

dir = "sqlite3_test_queries"
conf = {
  :file => File.expand_path("./test.sqlite3", File.dirname(__FILE__)),
}
option = {
  :querize_dir => dir,
  :tables => "parent,child".split(","),
  :save => true,
}
query = <<-"EOD"
  CREATE TABLE parent(
    key SERIAL PRIMARY KEY,
    num INTEGER DEFAULT NULL,
    category TEXT DEFAULT NULL,
    at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  CREATE TABLE child(
    parent BIGINT,
    key SERIAL,
    attribute TEXT NOT NULL,
    value TEXT DEFAULT NULL,
    at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(parent, key)
  );
  CREATE VIEW list AS(
    SELECT p.key AS parent_key, c.key AS child_key,
      p.num, p.category, c.attribute, c.value
    FROM parent AS p
    LEFT JOIN child AS c ON p.key = c.parent
    ORDER BY p.at, c.at
  );
EOD
db = SQLite3::Database.new conf[:file]
db.execute query

q = Querizer::Sqlite3.new(conf, option)

load "./querizerTest.rb"
test(q, dir)
