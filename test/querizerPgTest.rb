require "../querizer/pg"
require "pg"

conf = {
  :host => "localhost",
  :user => "postgres",
  :password => "postgres",
  :dbname => "test",
  :port => 5432,
}
dir = "pg_test_queries"
option = {
  :querize_dir => dir,
  :tables => "parent,child".split(","),
  :save => true,
  :debug => true,
}
PG::connect(conf).exec <<-"EOD"
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
  CREATE OR REPLACE VIEW list AS(
    SELECT p.id AS parent_id, c.id AS child_id,
      p.num, p.category, c.attribute, c.value
    FROM parent AS p
    LEFT JOIN child AS c ON p.id = c.parent
    ORDER BY p.at, c.at
  );
EOD

q = Querizer::Pg.new(conf, option)

load "./querizerTest.rb"
test(q, dir)
