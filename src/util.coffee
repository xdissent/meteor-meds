
class Meds.Util

  @wrapAsyncSuper: (proto, methods) ->
    for m in methods
      proto["_meds_#{m}"] = proto.constructor.__super__[m]
      proto[m] = Meteor._wrapAsync proto["_meds_#{m}"]
