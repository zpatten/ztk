module ZTK
  class SSH

    # SSH Private Functionality
    module Private

      # Builds our SSH options hash.
      def ssh_options
        options = {}

        # These are plainly documented on the Net::SSH config class.
        options.merge!(:encryption => config.encryption) if config.encryption
        options.merge!(:compression => config.compression) if config.compression
        options.merge!(:compression_level => config.compression_level) if config.compression_level
        options.merge!(:timeout => config.timeout) if config.timeout
        options.merge!(:forward_agent => config.forward_agent) if config.forward_agent
        options.merge!(:global_known_hosts_file => config.global_known_hosts_file) if config.global_known_hosts_file
        options.merge!(:auth_methods => config.auth_methods) if config.auth_methods
        options.merge!(:host_key => config.host_key) if config.host_key
        options.merge!(:host_key_alias => config.host_key_alias) if config.host_key_alias
        options.merge!(:host_name => config.host_name) if config.host_name
        options.merge!(:keys => config.keys) if config.keys
        options.merge!(:keys_only => config.keys_only) if config.keys_only
        options.merge!(:hmac => config.hmac) if config.hmac
        options.merge!(:port => config.port) if config.port
        options.merge!(:proxy => Net::SSH::Proxy::Command.new(proxy_command)) if config.proxy_host_name
        options.merge!(:rekey_limit => config.rekey_limit) if config.rekey_limit
        options.merge!(:user => config.user) if config.user
        options.merge!(:user_known_hosts_file => config.user_known_hosts_file) if config.user_known_hosts_file

        # This is not plainly documented on the Net::SSH config class.
        options.merge!(:password => config.password) if config.password

        config.ui.logger.debug { "ssh_options(#{options.inspect})" }
        options
      end

      # Builds a human readable tag about our connection.  Used for internal
      # logging purposes.
      def tag
        tags = Array.new

        if config.proxy_host_name
          proxy_user_host = "#{config.proxy_user}@#{config.proxy_host_name}"
          proxy_port = (config.proxy_port ? ":#{config.proxy_port}" : nil)
          tags << [proxy_user_host, proxy_port].compact.join
          tags << " >>> "
        end

        user_host = "#{config.user}@#{config.host_name}"
        port = (config.port ? ":#{config.port}" : nil)
        tags << [user_host, port].compact.join

        tags.join.strip
      end

      def log_header(what)
        count = 8
        sep = ("=" * count)
        header = [sep, "[ #{what} ]", sep, "[ #{tag} ]", sep, "[ #{what} ]", sep].join
        "#{header}\n"
      end

    end

  end
end
