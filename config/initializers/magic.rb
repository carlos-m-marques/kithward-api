module D
  def self.shitty_debuger(*subjects)
    $stdout.sync = true

    puts (5.times.map{ ("#{("="*50)}").green }.join("\n"))
    subjects.each { |subject| ap subject }
    puts (5.times.map{ ("#{("="*50)}").green }.join("\n"))
  end

  def self.uber_debug(*subjects)
    $stdout.sync = true

    puts (5.times.map{ ("#{("="*50)}").green }.join("\n"))
    subjects.each { |subject| ap subject }
    puts (5.times.map{ ("#{("="*50)}").green }.join("\n"))

    $stdout.sync = false
  end
end

module Kernel
  private
  include D # This is where the method gets added to Kernel
end
