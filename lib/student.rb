require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id
  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  def save
    if @id
      self.update
    else
      sql = <<-SQL 
        INSERT INTO students(name, grade)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students LIMIT 1")[0][0]
    end
  end

  def update
    sql = <<-SQL 
      UPDATE students SET name=?, grade=? WHERE id=?
    SQL
    DB[:conn].execute(sql, @name, @grade, @id)
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM students WHERE name=? LIMIT 1
    SQL
    new_from_db(DB[:conn].execute(sql, name)[0])
  end

end
