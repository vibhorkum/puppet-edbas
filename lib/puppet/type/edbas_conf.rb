Puppet::Type.newtype(:edbas_conf) do

  @doc = "This type allows puppet to manage edbas.conf parameters."

  ensurable

  newparam(:name) do
    desc "The edbas parameter name to manage."
    isnamevar

    newvalues(/^[\w\.]+$/)
  end

  newproperty(:value) do
    desc "The value to set for this parameter."
  end

  newproperty(:target) do
    desc "The path to edbas.conf"
    defaultto {
      if @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
        @resource.class.defaultprovider.default_target
      else
        nil
      end
    }
  end

end
