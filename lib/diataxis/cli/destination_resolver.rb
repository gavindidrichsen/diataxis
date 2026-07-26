# frozen_string_literal: true

require_relative '../config'
require_relative '../errors'

module Diataxis
  module CLI
    # Decides where a newly-created document should be written.
    #
    # Two independent signals matter: whether DIATAXIS_ROOT points somewhere
    # other than the current directory, and whether a local .diataxis config
    # governs the current directory (found by the same upward walk
    # Config.find_config already does). Only when both signals are present
    # AND disagree is there a genuine ambiguity worth asking about -- see
    # docs/adr/0018-prompt-on-diataxis-root-and-local-diataxis-conflict.md.
    class DestinationResolver
      Destination = Struct.new(:directory, :standalone, keyword_init: true) do
        def standalone?
          standalone
        end
      end

      # `override` forces the outcome without consulting `prompt` at all --
      # :local forces CWD, :root forces DIATAXIS_ROOT (raises if unset). This
      # is how the `--here`/`--root` flags let a script or an AI-agent session
      # route each document individually without blocking on a prompt.
      #
      # `prompt` is only consulted for the genuine conflict case, and is
      # injected (rather than reading STDIN directly here) so callers/tests
      # can supply a deterministic answer. It receives (local_dir, root_dir)
      # and must return :local or :root.
      def self.resolve(root:, override: nil, cwd: Dir.pwd, prompt: method(:ask_interactively))
        root_dir = normalize_root(root)
        local_config_found = !Config.find_config(cwd).nil?

        return resolve_override(override, cwd, root_dir, local_config_found) if override

        distinct_root = root_dir && canonicalize(root_dir) != canonicalize(cwd)
        return Destination.new(directory: cwd, standalone: !local_config_found) unless distinct_root
        return Destination.new(directory: root_dir, standalone: false) unless local_config_found

        chosen = prompt.call(cwd, root_dir) == :root ? root_dir : cwd
        Destination.new(directory: chosen, standalone: false)
      end

      private_class_method def self.normalize_root(root)
        return nil if root.nil? || root.to_s.empty?

        File.expand_path(root)
      end

      # Resolves symlinks (e.g. macOS's /var -> /private/var) so that a
      # DIATAXIS_ROOT given as a logical path (as a shell's $PWD often is)
      # still compares equal to Dir.pwd's physical path when they name the
      # same directory. Falls back to expand_path so a not-yet-created
      # DIATAXIS_ROOT (mkdir_p'd later by Document) doesn't blow up here.
      private_class_method def self.canonicalize(path)
        File.realpath(path)
      rescue Errno::ENOENT, Errno::ENOTDIR
        File.expand_path(path)
      end

      private_class_method def self.resolve_override(override, cwd, root_dir, local_config_found)
        case override
        when :local
          Destination.new(directory: cwd, standalone: !local_config_found)
        when :root
          raise ConfigurationError, 'DIATAXIS_ROOT is not set; nothing to target with --root.' unless root_dir

          Destination.new(directory: root_dir, standalone: false)
        else
          raise ArgumentError, "Unknown destination override: #{override.inspect}"
        end
      end

      # Blocking on $stdin.gets when stdin isn't a real terminal (CI, a script,
      # a spawned subprocess, an agent session) would hang rather than fail --
      # so this refuses to guess and tells the caller how to be explicit.
      private_class_method def self.ask_interactively(local_dir, root_dir)
        unless $stdin.respond_to?(:tty?) && $stdin.tty?
          raise ConfigurationError,
                "Both a local .diataxis (#{local_dir}) and DIATAXIS_ROOT (#{root_dir}) apply here, and input " \
                "isn't interactive. Re-run with --here or --root to choose explicitly."
        end

        warn "A local .diataxis config was found in #{local_dir}, and DIATAXIS_ROOT is set to #{root_dir}."
        print 'Save this document in this directory, or your DIATAXIS_ROOT central knowledge store? [l]ocal/[R]oot: '
        answer = $stdin.gets.to_s.strip.downcase
        answer.start_with?('l') ? :local : :root
      end
    end
  end
end
