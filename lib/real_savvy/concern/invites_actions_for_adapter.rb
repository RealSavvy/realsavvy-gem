module RealSavvy::Concern::InvitesActionsForAdapter
  def invite(id:, email:)
    put("./api/v3/#{path_prefix}/#{id}/invite", {email: email})
  end

  def accept_invite(id:, given:)
    put("./api/v3/#{path_prefix}/#{id}/accept_invite", {given: given})
  end

  def uninvite(id:, email:)
    delete("./api/v3/#{path_prefix}/#{id}/uninvite", {email: email})
  end
end
