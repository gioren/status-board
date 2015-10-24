Meteor.methods

  getGroups: ->
    Services.aggregate($group: _id: "$info.group").map (item) -> group: item._id

  addHttpService: HttpStatusJob.create
  updateHttpService: HttpStatusJob.update
  addSshService: SshJob.create
  updateSshService: SshJob.update
  removeService: StatusJob.remove
  addService: (serviceDetails) ->
    Services.insert serviceDetails
