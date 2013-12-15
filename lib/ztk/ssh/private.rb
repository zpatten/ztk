module ZTK
  class SSH

    # SSH Private Functionality
    module Private

      # Builds our core options
      def base_options
        options = Hash.new

        config.encryption.nil? or              options.merge!(:encryption => config.encryption)
        config.compression.nil? or             options.merge!(:compression => config.compression)
        config.compression_level.nil? or       options.merge!(:compression_level => config.compression_level)
        config.timeout.nil? or                 options.merge!(:timeout => config.timeout)
        config.forward_agent.nil? or           options.merge!(:forward_agent => config.forward_agent)
        config.global_known_hosts_file.nil? or options.merge!(:global_known_hosts_file => config.global_known_hosts_file)
        config.auth_methods.nil? or            options.merge!(:auth_methods => config.auth_methods)
        config.host_key.nil? or                options.merge!(:host_key => config.host_key)
        config.host_key_alias.nil? or          options.merge!(:host_key_alias => config.host_key_alias)
        config.keys_only.nil? or               options.merge!(:keys_only => config.keys_only)
        config.hmac.nil? or                    options.merge!(:hmac => config.hmac)
        config.rekey_limit.nil? or             options.merge!(:rekey_limit => config.rekey_limit)
        config.user_known_hosts_file.nil? or   options.merge!(:user_known_hosts_file => config.user_known_hosts_file)

        options
      end

      # Builds our SSH options hash.
      def ssh_options
        options = base_options

        config.user.nil? or      options.merge!(:user => config.user)
        config.password.nil? or  options.merge!(:password => config.password)
        config.keys.nil? or      options.merge!(:keys => config.keys)

        config.host_name.nil? or options.merge!(:host_name => config.host_name)
        config.port.nil? or      options.merge!(:port => config.port)

        # if @gateway.nil?
        #   config.proxy_host_name.nil? or options.merge!(:proxy => Net::SSH::Proxy::Command.new(proxy_command))
        # end

        config.ui.logger.debug { "ssh_options(#{options.inspect})" }
        options
      end

      # Builds our SSH gateway options hash.
      def gateway_options
        options = base_options

        config.proxy_user.nil? or      options.merge!(:user => config.proxy_user)
        config.proxy_password.nil? or  options.merge!(:password => config.proxy_password)
        config.proxy_keys.nil? or      options.merge!(:keys => config.proxy_keys)

        config.proxy_host_name.nil? or options.merge!(:host_name => config.proxy_host_name)
        config.proxy_port.nil? or      options.merge!(:port => config.proxy_port)

        config.ui.logger.debug { "gateway_options(#{options.inspect})" }
        options
      end

      # Builds a human readable tag about our connection.  Used for internal
      # logging purposes.
      def tag
        tags = Array.new

        user_host = "#{config.user}@#{config.host_name}"
        port = (config.port ? ":#{config.port}" : nil)
        tags << [user_host, port].compact.join

        if config.proxy_host_name
          tags << " via "

          proxy_user_host = "#{config.proxy_user}@#{config.proxy_host_name}"
          proxy_port = (config.proxy_port ? ":#{config.proxy_port}" : nil)
          tags << [proxy_user_host, proxy_port].compact.join
        end

        tags.join.strip
      end

      def log_header(what, char='=')
        count = 16
        sep = (char * count)
        header = [sep, "[ #{tag} >>> #{what} ]", sep].join
        "#{header}\n"
      end

    end

  end
end
