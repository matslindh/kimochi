import os
import sys
import transaction

from sqlalchemy import engine_from_config

from pyramid.paster import (
    get_appsettings,
    setup_logging,
    )

from pyramid.scripts.common import parse_vars

from ..models import (
    DBSession,
    Base,
    User,
    Site,
    SiteAPIKey,
    SiteAspectRatio,
)


def usage(argv):
    cmd = os.path.basename(argv[0])
    print('usage: %s <config_uri> [var=value]\n'
          '(example: "%s development.ini")' % (cmd, cmd))
    sys.exit(1)


def main(argv=sys.argv):
    if len(argv) < 2:
        usage(argv)
    config_uri = argv[1]
    options = parse_vars(argv[2:])
    setup_logging(config_uri)
    settings = get_appsettings(config_uri, options=options)
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)
    Base.metadata.create_all(engine)

    with transaction.manager:
        user = User(email='test@example.com', password='test', admin=True)
        DBSession.add(user)
        site = Site(name='asd', key='80d621df066348e5938a469730ae0cab')
        DBSession.add(site)
        site.api_keys.append(SiteAPIKey(key='GIKfxIcIHPbM0uX9PrQ1To29Pb2on0pa'))
        site.users.append(user)

        aspect_ratio_1_1 = SiteAspectRatio(width=1, height=1)
        aspect_ratio_3_1 = SiteAspectRatio(width=3, height=1)
        site.aspect_ratios.append(aspect_ratio_1_1)
        site.aspect_ratios.append(aspect_ratio_3_1)

    from alembic.config import Config
    from alembic import command
    alembic_cfg = Config("alembic.ini")
    command.stamp(alembic_cfg, "head")

