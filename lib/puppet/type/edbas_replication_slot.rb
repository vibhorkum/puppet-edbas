Puppet::Type.newtype(:edbas_replication_slot) do
  @doc = "Manages edbas replication slots.

This type allows to create and destroy replication slots
to register warm standby replication on a edbas
master server.
"

  ensurable

  newparam(:name) do
    desc "The name of the slot to create. Must be a valid replication slot name."
    isnamevar
    newvalues /^[a-z0-9_]+$/
  end
end
