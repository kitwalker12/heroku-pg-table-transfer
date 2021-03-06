require "heroku/command/base"

class Heroku::Command::Pg < Heroku::Command::Base

  # pg:transfer_tables
  #
  # transfer data between databases
  def transfer_tables
    from = options[:from] || ENV["FROM_URL"] || "DATABASE"
    to   = options[:to]   || ENV["TO_URL"]
    tables = (options[:tables] || "").split(",")

    error <<-ERROR unless to
No local DATABASE_URL detected and --to not specified.
For information on using config vars locally, see:
https://devcenter.heroku.com/articles/config-vars#local_setup
    ERROR

    from_url = transfer_resolve(from)
    to_url   = transfer_resolve(to)

    error "You cannot transfer a database to itself" if from_url == to_url

    validate_transfer_db from_url
    validate_transfer_db to_url

    puts "Source database: #{transfer_pretty_name(from)}"
    puts "Target database: #{transfer_pretty_name(to)}"

    return unless confirm_command

    system %{ #{pg_dump_command(from_url, tables)} | #{pg_restore_command(to_url)} }
  end

private

  def pg_dump_command(url, tables)
    uri = URI.parse(url)
    database = uri.path[1..-1]
    host = uri.host || "localhost"
    port = uri.port || "5432"
    user = uri.user ? "-U #{uri.user}" : ""
    %{ env PGPASSWORD=#{uri.password} pg_dump --verbose -F c -h #{host} #{user} -p #{port} #{tables.map{|name| "-t #{name}" }.join(" ")} #{database} }
  end

  def pg_restore_command(url)
    uri = URI.parse(url)
    database = uri.path[1..-1]
    host = uri.host || "localhost"
    port = uri.port || "5432"
    user = uri.user ? "-U #{uri.user}" : ""
    %{ env PGPASSWORD=#{uri.password} pg_restore --verbose --clean --no-acl --no-owner #{user} -h #{host} -d #{database} -p #{port} }
  end

  def transfer_pretty_name(db_name)
    if (uri = URI.parse(db_name)).scheme
      "#{uri.path[1..-1]} on #{uri.host||"localhost"}:#{uri.port||5432}"
    else
      "#{hpg_resolve(db_name).config_var} on #{app}.herokuapp.com"
    end
  end

  def transfer_resolve(name_or_url)
    if URI.parse(name_or_url).scheme
      name_or_url
    else
      hpg_resolve(name_or_url).url
    end
  end

  def validate_transfer_db(url)
    unless %w( postgres postgresql ).include? URI.parse(url).scheme
      error <<-ERROR
Only PostgreSQL databases can be transferred with this command.
For information on transferring other database types, see:
https://devcenter.heroku.com/articles/import-data-heroku-postgres
      ERROR
    end
  end

end