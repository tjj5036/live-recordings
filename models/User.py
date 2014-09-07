import bcrypt


class User(object):
    """ User object that potentially has administrative rights.
    """

    def __init__(self, login, password, groups=None):
        """ Inits the user
        """
        self.login = login
        self.password = password
        self.groups = groups or []
        self._id = None

    def authenticate(self, request):
        """ Authenticates a user
        """
        user = request.db['users'].find_one({"user": self.login})
        if user:
            if bcrypt.hashpw(self.password, user['salt']) == user['password']:
                self.groups = user['groups']
                self._id = user['_id']
                return True
        return False

    def role_filter(self, request):
        """ Determines what roles the user has.
        """
        user = request.db['users'].find_one({"user": self.login})
        if user:
            return [('group:%s' % role.name) for role in user['groups']]

    def create_or_update(self, request):
        """ Creates or updates a user.
        """
        salt = bcrypt.gensalt()
        save_dict = {
            'groups': self.groups,
            'user': self.login,
            'password': bcrypt.hashpw(self.password, salt),
            'salt': salt}
        request.db['users'].save(save_dict)
