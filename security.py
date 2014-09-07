def groupfinder(userid, request):
    user = request.db['users'].find_one({"user":userid})
    if user:
      return ['g:%s' % role for role in user['groups']]
    else:
      return None


