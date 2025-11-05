# frozen_string_literal: true

require 'logger'

module Diataxis
  # Centralized logging configuration for the Diataxis application
  # Following best practices with singleton pattern and environment-based configuration
  class Log
    def self.instance
      @logger ||= configure_logger
    end

    def self.configure_logger
      logger = Logger.new($stdout)
      
      # Set log level based on multiple sources (priority order):
      # 1. Explicitly set level via set_level method (CLI flags)
      # 2. Environment variable DIATAXIS_LOG_LEVEL
      # 3. Test environment detection
      # 4. Default INFO level
      logger.level = determine_log_level
      
      # Custom formatter for clean CLI output
      logger.formatter = proc do |severity, datetime, progname, msg|
        case severity
        when 'INFO'
          "#{msg}\n"  # Clean info messages without timestamp for CLI
        when 'DEBUG'
          "[DEBUG] #{msg}\n"  # Include severity for debugging
        else
          "[#{severity}] #{msg}\n"  # Include severity for warnings/errors
        end
      end

      logger
    end

    def self.determine_log_level
      # Priority 1: Explicitly set level (via CLI flags)
      return @explicit_level if @explicit_level
      
      # Priority 2: Environment variable
      if ENV['DIATAXIS_LOG_LEVEL']
        case ENV['DIATAXIS_LOG_LEVEL'].upcase
        when 'DEBUG' then Logger::DEBUG
        when 'INFO' then Logger::INFO
        when 'WARN' then Logger::WARN
        when 'ERROR' then Logger::ERROR
        when 'FATAL' then Logger::FATAL
        else Logger::INFO
        end
      # Priority 3: Quiet mode (suppress INFO messages)
      elsif ENV['DIATAXIS_QUIET'] == 'true'
        Logger::WARN
      # Priority 4: Default
      else
        Logger::INFO
      end
    end

    def self.set_level(level)
      @explicit_level = level
      @logger&.level = level
    end

    # Reset logger (useful for testing)
    def self.reset!
      @logger = nil
      @explicit_level = nil
    end
  end
end