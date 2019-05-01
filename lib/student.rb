require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade
  
  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade

  end

  def self.create_table
    sql = %Q[
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT)
    ]
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = %Q[DROP TABLE students]
    DB[:conn].execute(sql)
  end

  def save
    if @id
      self.update
    else
      sql = %Q[
        INSERT INTO students (name, grade)
        VALUES ("#{@name}", "#{@grade}")
      ]
      DB[:conn].execute(sql)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = %Q[
      SELECT * FROM students WHERE name = '#{name}'
    ]
    row = DB[:conn].execute(sql)[0]
    new_from_db(row)
  end

  def update
    sql = %Q[
      UPDATE students SET name = ?, grade =? WHERE id = ?
    ]
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
