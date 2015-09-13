from sqlalchemy import (
    Boolean,
    Column,
    ForeignKey,
    Index,
    Integer,
    Table,
    Text,
    )

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import (
    scoped_session,
    sessionmaker,
    relationship,
    )

from sqlalchemy_utils.types.password import (
    PasswordType
)

from pyramid.security import (
    Allow,
    ALL_PERMISSIONS,
    Authenticated,
    Everyone,
)

from zope.sqlalchemy import ZopeTransactionExtension

import calendar
import time
import uuid
import random
import string

def epoch():
    return calendar.timegm(time.gmtime())

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class Page(Base):
    __tablename__ = 'pages'

    id = Column(Integer, primary_key=True)
    name = Column(Text(length=40))
    published = Column(Boolean, default=False)
    deleted = Column(Boolean, default=False)

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True)
    site = relationship('Site')

    def __json__(self, request):
        return {
            'id': self.id,
            'name': self.name,
            'sections': self.get_sections_active(),
        }

    @classmethod
    def get_active_from_site_id(cls, site_id):
        return DBSession.query(cls).filter(cls.site_id == site_id, cls.deleted == False).all()

    @classmethod
    def get_for_site_id_and_page_id(cls, site_id, page_id):
        return DBSession.query(cls).filter(cls.site_id == site_id, cls.id == page_id, cls.deleted == False).first()

    def get_sections_active(self):
        return PageSection.get_active_from_page_id(self.id)

    def get_page_section(self, page_section_id):
        return PageSection.get_from_page_id_and_page_section_id(self.id, page_section_id)

class PageSection(Base):
    __tablename__ = 'pages_sections'

    id = Column(Integer, primary_key=True)
    type = Column(Text(length=30))
    order = Column(Integer, default=epoch)
    content = Column(Text(length=65536))

    deleted = Column(Boolean, default=False)

    page_id = Column(Integer, ForeignKey('pages.id'), nullable=False, index=True)
    page = relationship('Page', backref='sections')

    gallery_id = Column(Integer, ForeignKey('galleries.id'), nullable=True)
    gallery = relationship('Gallery')

    def __json__(self, request):
        return {
            'type': self.type,
            'content': self.content,
            'gallery': self.gallery,
        }

    @classmethod
    def get_active_from_page_id(cls, page_id):
        return DBSession.query(cls).filter(cls.page_id == page_id, cls.deleted == False).order_by('order').all()

    @classmethod
    def get_from_page_id_and_page_section_id(cls, page_id, page_section_id):
        return DBSession.query(cls).filter(cls.page_id == page_id, cls.id == page_section_id, cls.deleted == False).first()

    @classmethod
    def get_from_id(cls, section_id):
        return DBSession.query(cls).filter(cls.id == section_id, cls.deleted == False).first()

    @classmethod
    def is_valid_type(cls, page_type):
        return page_type in ('text', 'gallery', )

class Gallery(Base):
    __tablename__ = 'galleries'

    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True)
    site = relationship('Site', backref='galleries')

    images = relationship('Image', backref='gallery', order_by="Image.order")

    def __json__(self, request):
        return {
            'id': self.id,
            'name': self.name,
            'images': self.images,
        }

    @classmethod
    def get_from_site_id_and_gallery_id(cls, site_id, gallery_id):
        return DBSession.query(cls).filter(cls.site_id == site_id, cls.id == gallery_id).first()

class Image(Base):
    __tablename__ = 'images'

    id = Column(Integer, primary_key=True)
    imbo_id = Column(Text(length=80))
    order = Column(Integer, default=epoch)

    title = Column(Text(length=140), nullable=True)
    description = Column(Text(length=65536), nullable=True)
    customer = Column(Text(length=140), nullable=True)
    link = Column(Text(length=200), nullable=True)
    link_text = Column(Text(length=140), nullable=True)

    deleted = Column(Boolean, default=False)

    gallery_id = Column(Integer, ForeignKey('galleries.id'), nullable=False, index=True)

    def __json__(self, request):
        data = {
            'id': self.id,
            'imbo_id': self.imbo_id,
            'title': self.title,
            'description': self.description,
            'customer': self.customer,
            'link': self.link,
            'link_text': self.link_text,
        }

        if self.imbo_id:
            data['preview'] = {
                '400x200': str(request.imbo.image_url(self.imbo_id).max_size(max_width=400, max_height=200)),
            }

            data['source'] = {
                '1280': str(request.imbo.image_url(self.imbo_id).max_size(max_width=1280))
            }

        return data

    @classmethod
    def get_from_gallery_id_and_image_id(cls, gallery_id, image_id):
        return DBSession.query(cls).filter(cls.gallery_id == gallery_id, cls.id == image_id).first()

UserSiteTable = Table('users_sites', Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id'), nullable=False, index=True, primary_key=True),
    Column('site_id', Integer, ForeignKey('sites.id'), nullable=False, index=True, primary_key=True)
)

class Site(Base):
    __tablename__ = 'sites'

    id = Column(Integer, primary_key=True)
    name = Column(Text(length=40), unique=True)
    key = Column(Text(length=32), unique=True, default=lambda: uuid.uuid4().hex)

    pages = relationship('Page')

    def __json__(self, request):
        pages = []

        for page in self.pages_active():
            pages.append({
                'id': page.id,
                'name': page.name,
                'slug': None,
            })

        return {
            'name': self.name,
            'key': self.key,
            'pages': pages,
        }

    def api_key_generate(self):
        return SiteAPIKey.generate(self.id)

    def pages_active(self):
        return Page.get_active_from_site_id(self.id)

    @classmethod
    def get_from_key(cls, key):
        return DBSession.query(cls).filter(cls.key == key).first()

    @classmethod
    def get_from_key_and_user_id(cls, key, user_id):
        site = cls.get_from_key(key)

        if not site:
            raise NotFoundException

        for user in site.users:
            if user.id == user_id:
                return site

        raise NoAccessException

    @classmethod
    def get_from_key_and_api_key(cls, key, api_key):
        site = cls.get_from_key(key)

        if not site:
            raise NotFoundException

        for api_key_obj in site.api_keys:
            if api_key_obj.key == api_key:
                return site

        raise NoAccessException

class SiteAPIKey(Base):
    __tablename__  = 'sites_api_keys'
    __key_length__ = 32

    id = Column(Integer, primary_key=True)
    key = Column(Text(length=__key_length__), unique=True, default=lambda: uuid.uuid4().hex)

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True)
    site = relationship('Site', backref='api_keys')

    @classmethod
    def generate(cls, site_id):
        key = ''
        valid = string.ascii_letters + string.digits
        rand = random.SystemRandom()

        while not key or DBSession.query(SiteAPIKey).filter(SiteAPIKey.key == key).first():
            key = ''

            for d in range(0, cls.__key_length__):
                key += rand.choice(valid)

        api_key = SiteAPIKey(site_id=site_id, key=key)
        DBSession.add(api_key)

        return api_key

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)

    email = Column(Text(length=80), unique=True)
    password = Column(PasswordType(schemes=[
            'bcrypt',
        ]))
    site_limit = Column(Integer, default=1)

    admin = Column(Boolean, default=False)
    deleted = Column(Boolean, default=False)

    sites = relationship("Site", secondary="users_sites", backref="users")

    @classmethod
    def sign_in(cls, email, password):
        user = DBSession.query(cls).filter(User.email == email).first()

        if user and user.password == password:
            return user

        return None

    @classmethod
    def get_from_id(cls, user_id):
        return DBSession.query(cls).filter(User.id == user_id).first()


"""
class UserSite(Base):
    __tablename__ = 'users_sites'

    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True, primary_key=True)
    user = relationship('User')

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True, primary_key=True)
    site = relationship('Site')"""


class RootFactory:
    __acl__ = [
        (Allow, Authenticated, Authenticated),
    ]

    def __init__(self, request):
        pass

class APIRootFactory:
    __acl__ = [
        (Allow, Everyone, 'api')
    ]

    def __init__(self, request):
        pass

class NotFoundException(BaseException):
    pass

class NoAccessException(BaseException):
    pass
