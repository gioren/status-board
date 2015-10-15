Meteor.methods

  getGroups: ->
    Services.aggregate($group: _id: "$group").map (item) -> group: item._id

  newHttpService: HttpStatusJob.create
  editHttpService: HttpStatusJob.update
  newSshService: SshJob.create
