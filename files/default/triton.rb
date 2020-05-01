Ohai.plugin(:Triton) do
  provides 'triton'
  depends 'platform'

  def find_mdata_tools
    case platform
    when 'windows'
      ::File.join('C:', 'smartdc', 'bin')
    when 'ubuntu', 'redhat', 'centos'
      if ::File.exist?('/native/usr/sbin')
        '/native/usr/sbin'
      else
        '/usr/sbin'
      end
    when 'smartos'
      '/usr/sbin'
    end
  end

  collect_data(:default) do
    triton Mash.new unless triton
    mdata_path = find_mdata_tools
    Ohai::Log.debug("triton: found mdata tools in #{mdata_path}")
    mdata_get = ::File.join(find_mdata_tools, 'mdata-get')
    mdata_list = ::File.join(find_mdata_tools, 'mdata-list')

    # Process known read-only keys provided by triton
    triton[:datacenter_name] = shell_out("#{mdata_get} sdc:datacenter_name").stdout.strip
    triton[:alias] = shell_out("#{mdata_get} sdc:alias").stdout.strip
    triton[:uuid] = shell_out("#{mdata_get} sdc:uuid").stdout.strip
    triton[:image_uuid] = shell_out("#{mdata_get} sdc:image_uuid").stdout.strip
    triton[:owner_uuid] = shell_out("#{mdata_get} sdc:owner_uuid").stdout.strip
    triton[:server_uuid] = shell_out("#{mdata_get} sdc:owner_uuid").stdout.strip
    # Process user-defined instance metadata
    shell_out(mdata_list.to_s).stdout.each_line do |key|
      mdata = key.strip
      Ohai::Log.debug("Processing instance metadata: #{mdata}")
      # Note: We skip the root_authorized_keys and user-script keys because they
      # already have defined behavior in the context of Joyent images.
      next if mdata.match('root_authorized_keys') || mdata.match('user-script')
      # skip administrator_pw
      next if mdata.match('administrator_pw')
      triton[mdata] = shell_out("#{mdata_get} #{mdata}").stdout.strip
    end
  end
end
