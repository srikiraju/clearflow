require 'sqlite3'

def osascript(script)
  system 'osascript', *script.split(/\n/).map { |line| ['-e', line] }.flatten
end

cleardb = SQLite3::Database.new("/Users/srikanthraju/Library/Containers/com.realmacsoftware.clear.mac/Data/Library/Application Support/com.realmacsoftware.clear.mac/LocalTasks.sqlite")
done_rows = cleardb.execute("select * from completed_tasks")

localdb = SQLite3::Database.new("/Users/srikanthraju/clearflow.db")
localdb.execute("create table if not exists completed_tasks (hash varchar(255))")


baseScript = <<-END
tell application "Evernote"
    set note1 to find notes "intitle:cleardone"
    set yo to item 1 of note1
    set myDate to date string of (current date)
    
    tell yo to append html myDate & ":   " & "gsubtulla<br>"
end tell
END

if done_rows.length == 0
    localdb.execute("delete from completed_tasks")
end

done_rows.each do |row|
    found = localdb.execute("select * from completed_tasks where hash =\"" + row[1] + "\"")
    if found.length == 0
        runScript = baseScript.gsub("gsubtulla", row[3])
        osascript runScript
        localdb.execute("insert into completed_tasks values(\"" + row[1] + "\")")
    end
end

