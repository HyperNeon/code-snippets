class Logger::SimpleFormatter
  def call(severity, time, progname, msg)
    "[#{time.strftime('%Y-%m-%d %H:%M:%S.%L')}] #{severity} -- #{msg}\n"
  end
end
