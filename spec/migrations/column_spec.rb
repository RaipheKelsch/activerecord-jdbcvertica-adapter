require 'spec_helper'

class ColumnKing < ::ActiveRecord::Migration
  def self.drop_kings
    if table_exists?(:kings)
      drop_table :kings
    end
  end

  def self.up
    create_table :kings
  end

  def self.down
    drop_table :kings
  end
end

describe ColumnKing do
  def columns
    connection.columns(:kings)
  end

  def connection
    ::ActiveRecord::Base.connection
  end

  def has_column?(name)
    columns.any? { |column| column.name == "#{name}" }
  end

  def has_column_typed?(name, type)
    !!(has_column?(name) &&
      columns.find { |column| column.name == "#{name}" }.sql_type =~ type)
  end

  before do
    ColumnKing.drop_kings
    ColumnKing.up
  end

  describe "#add_column" do
    it "throws an error if table does not exist" do
      -> {
        connection.add_column(:king2, :queen_id, :integer)
      }.must_raise(ActiveRecord::StatementInvalid)
    end

    it "creates :integer columns" do
      connection.add_column(:kings, :queen_id, :integer)
      has_column?(:queen_id).must_equal(true)
      has_column_typed?(:queen_id, /integer/i).must_equal(true)
    end

    it "creates :string columns (as varchar)" do
      connection.add_column(:kings, :name, :string)
      has_column?(:name).must_equal(true)
      has_column_typed?(:name, /varchar/i).must_equal(true)
    end

    it "creates :text columns (as varchar columns)" do
      connection.add_column(:kings, :lineage, :text)
      has_column?(:lineage).must_equal(true)
      has_column_typed?(:lineage, /varchar/i).must_equal(true)
    end
  end

  describe "#column_exists?" do
    it "is false if column not present" do
      connection.column_exists?(:kings, :name).must_equal(false)
    end

    it "is true when column exists" do
      connection.add_column(:kings, :name, :string)
      connection.column_exists?(:kings, :name).must_equal(true)
    end

    it "is false when column types does not match declared type" do
      connection.add_column(:kings, :name, :string)
      connection.column_exists?(:kings, :name, :integer)
    end

    it "is false when column sql_type matches but declared type does not (like string/text)" do
      connection.add_column(:kings, :name, :string)
      connection.column_exists?(:kings, :name, :text)
    end
  end
end