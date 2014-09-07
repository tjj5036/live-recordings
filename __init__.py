from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.config import Configurator
from pyramid_beaker import session_factory_from_settings
from pyramid.events import NewRequest
from live_rage.views.admin_views import Root
from pyramid_beaker import set_cache_regions_from_settings
from live_rage.security import groupfinder
import pymongo


def main(global_settings, **settings):
    """ Init for setting up auth policy, routes, etc.
    """
    settings['auth.secret'] = 'seekrit'
    authn_policy = AuthTktAuthenticationPolicy(
        settings['auth.secret'],
        callback=groupfinder)

    authz_policy = ACLAuthorizationPolicy()
    session_factory = session_factory_from_settings(settings)
    set_cache_regions_from_settings(settings)

    config = Configurator(
        settings=settings,
        root_factory=Root,
        authentication_policy=authn_policy,
        authorization_policy=authz_policy,
        session_factory=session_factory)
    
    # Include Views
    config.include('pyramid_jinja2')
    config.include('.views')

    # MongoDB
    def add_mongo_db(event):
        settings = event.request.registry.settings
        url = settings['mongodb.url']
        db_name = settings['mongodb.db_name']
        db = settings['mongodb_conn'][db_name]
        event.request.db = db
    db_uri = settings['mongodb.url']
    MongoDB = pymongo.Connection

    if 'pyramid_debugtoolbar' in set(settings.values()):
        class MongoDB(pymongo.Connection):
            def __html__(self):
                return 'MongoDB: <b>{}></b>'.format(self)

    conn = MongoDB(db_uri)
    config.registry.settings['mongodb_conn'] = conn
    config.add_subscriber(add_mongo_db, NewRequest)
    config.scan('live_rage')
    return config.make_wsgi_app()
