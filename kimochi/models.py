from sqlalchemy import (
    Boolean,
    Column,
    desc,
    ForeignKey,
    Index,
    Integer,
    Table,
    Text,
    UniqueConstraint,
    )

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import (
    scoped_session,
    sessionmaker,
    relationship,
    validates,
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
from slugify import slugify

import calendar
import time
import uuid
import random
import string
import datetime

def epoch():
    return calendar.timegm(time.gmtime())

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class Page(Base):
    __tablename__ = 'pages'

    id = Column(Integer, primary_key=True)
    name = Column(Text(length=40))

    # populated by @validates rule for name
    slug = Column(Text(length=80), nullable=True)
    published = Column(Boolean, default=False)
    deleted = Column(Boolean, default=False)

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True)
    site = relationship('Site')

    def __json__(self, request):
        return {
            'id': self.id,
            'name': self.name,
            'slug': self.slug,
            'sections': self.get_sections_active(),
        }

    @validates("name")
    def _update_slug(self, key, name):
        self.slug = slugify(name, only_ascii=True)
        return name

    @classmethod
    def get_published_from_site_id(cls, site_id):
        return DBSession.query(cls).filter(cls.site_id == site_id, cls.published == True, cls.deleted == False).all()

    @classmethod
    def get_for_site_id_and_page_id(cls, site_id, page_id):
        return DBSession.query(cls).filter(cls.site_id == site_id, cls.id == page_id, cls.deleted == False).first()

    @classmethod
    def get_for_site_id_and_page_alias(cls, site_id, alias):
        return DBSession.query(cls).join(PageAlias).filter(cls.site_id == site_id, cls.deleted == False, PageAlias.alias == alias).first()

    @classmethod
    def get_for_site_id_and_page_id_or_alias(cls, site_id, page_lookup):
        page = cls.get_for_site_id_and_page_id(site_id, page_lookup)

        if page:
            return page

        return cls.get_for_site_id_and_page_alias(site_id, page_lookup)

    @classmethod
    def remove_alias_for_site(cls, site_id, alias):
        for al in DBSession.query(Page, PageAlias).\
                filter(PageAlias.page_id == Page.id, PageAlias.alias == alias, Page.site_id == site_id).\
                all():
            DBSession.delete(al[1])

    def add_alias(self, alias):
        pa = PageAlias()
        pa.alias = alias
        pa.page = self

        DBSession.add(pa)

    def get_sections_active(self):
        return PageSection.get_active_from_page_id(self.id)

    def get_page_section(self, page_section_id):
        return PageSection.get_from_page_id_and_page_section_id(self.id, page_section_id)

class PageAlias(Base):
    __tablename__ = 'pages_aliases'

    id = Column(Integer, primary_key=True)
    alias = Column(Text(length=40))

    page_id = Column(Integer, ForeignKey('pages.id'), nullable=False, index=True)
    page = relationship('Page', backref='aliases')


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

    images = relationship('PageSectionImage', cascade="save-update, merge, delete, delete-orphan")

    parent_section_id = Column(Integer, ForeignKey('pages_sections.id'))
    sections = relationship("PageSection")

    def __json__(self, request):
        return {
            'id': self.id,
            'type': self.type,
            'content': self.content,
            'gallery': self.gallery,
            'images': [page_section_image.image for page_section_image in self.images] if self.images else [],
            'sections': self.sections,
        }

    @classmethod
    def get_active_from_page_id(cls, page_id):
        return DBSession.query(cls).filter(cls.page_id == page_id, cls.deleted == False, cls.parent_section_id == None).order_by('order').all()

    @classmethod
    def get_from_page_id_and_page_section_id(cls, page_id, page_section_id):
        return DBSession.query(cls).filter(cls.page_id == page_id, cls.id == page_section_id, cls.deleted == False).first()

    @classmethod
    def get_from_id(cls, section_id):
        return DBSession.query(cls).filter(cls.id == section_id, cls.deleted == False).first()

    @classmethod
    def is_valid_type(cls, section_type):
        return section_type in ('text', 'gallery', 'two_columns', 'image')

    @classmethod
    def is_valid_parent_type(cls, section_type):
        return section_type in ('two_columns', )

    @classmethod
    def create_two_columns(cls, page):
        two_columns = PageSection(page=page, type='two_columns')
        container_left = PageSection(page=page, order=1, type='container')
        container_right = PageSection(page=page, order=2, type='container')

        text_left = PageSection(page=page, type='text')
        text_right = PageSection(page=page, type='text')

        container_left.sections.append(text_left)
        container_right.sections.append(text_right)

        two_columns.sections.append(container_left)
        two_columns.sections.append(container_right)

        return two_columns


class PageSectionImage(Base):
    __tablename__ = 'pages_sections_images'

    page_section_id = Column(Integer, ForeignKey('pages_sections.id'), primary_key=True)
    image_id = Column(Integer, ForeignKey('images.id'), primary_key=True)

    image = relationship('Image')
    page_section = relationship('PageSection')


class Gallery(Base):
    __tablename__ = 'galleries'

    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True)
    site = relationship('Site', backref='galleries')

    images = relationship('Image', backref='gallery', order_by="desc(Image.order)")

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
    width = Column(Integer, nullable=False)
    height = Column(Integer, nullable=False)
    order = Column(Integer, default=epoch)

    title = Column(Text(length=140), nullable=True)
    description = Column(Text(length=65536), nullable=True)
    customer = Column(Text(length=140), nullable=True)
    link = Column(Text(length=200), nullable=True)
    link_text = Column(Text(length=140), nullable=True)

    deleted = Column(Boolean, default=False)

    gallery_id = Column(Integer, ForeignKey('galleries.id'), nullable=True, index=True)
    variations = relationship("ImageVariation")

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True)
    site = relationship('Site', backref='images')

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

            data['variations'] = {}

            for variation in self.variations:
                var_key = str(variation.aspect_width) + ':' + str(variation.aspect_width)
                data['variations'][var_key] = {
                    '270x270': str(request.imbo.image_url(self.imbo_id).crop(variation.offset_width,
                                                                             variation.offset_height,
                                                                             variation.width,
                                                                             variation.height
                                                                             ).max_size(270, 270))
                }

        return data

    def variations_and_site_aspect_ratios(self, site_aspect_ratios):
        variations = {}

        for variation in self.variations:
            variations[str(variation.aspect_width) + ':' + str(variation.aspect_height)] = {
                'width': variation.aspect_width,
                'height': variation.aspect_height,
                'has_variation': True,
            }

        for ar in site_aspect_ratios:
            k = str(ar.width) + ':' + str(ar.height)

            if k not in variations:
                variations[k] = {
                    'width': ar.width,
                    'height': ar.height,
                    'has_variation': False,
                }

        return sorted(variations.values(), key=lambda x: float(x['width']) / float(x['height']))

    @classmethod
    def get_from_gallery_id_and_image_id(cls, gallery_id, image_id):
        return DBSession.query(cls).filter(cls.gallery_id == gallery_id, cls.id == image_id).first()

    @classmethod
    def get_from_site_id_and_image_id(cls, site_id, image_id):
        return DBSession.query(cls).filter(cls.site_id == site_id, cls.id == image_id).first()

    @classmethod
    def get_next_and_previous_from_image(cls, image):
        image_next = DBSession.query(cls).filter(cls.gallery_id == image.gallery_id, cls.order < image.order).\
            order_by(desc(cls.order)).first()
        image_prev = DBSession.query(cls).filter(cls.gallery_id == image.gallery_id, cls.order > image.order).\
            order_by(cls.order).first()

        return {
            'next': image_next,
            'previous': image_prev,
        }

class ImageVariation(Base):
    __tablename__ = 'images_variations'

    id = Column(Integer, primary_key=True)
    aspect_width = Column(Integer, nullable=False)
    aspect_height = Column(Integer, nullable=False)
    width = Column(Integer, nullable=False)
    height = Column(Integer, nullable=False)
    offset_width = Column(Integer, nullable=False)
    offset_height = Column(Integer, nullable=False)

    image_id = Column(Integer, ForeignKey('images.id'), nullable=False, index=True)
    image = relationship("Image")

    @classmethod
    def get_from_image_id_and_aspect(cls, image_id, width, height):
        return DBSession.query(cls).filter(
            cls.image_id == image_id,
            cls.aspect_width == width,
            cls.aspect_height == height).first()

UserSiteTable = Table('users_sites', Base.metadata,
                      Column('user_id', Integer, ForeignKey('users.id'), nullable=False, index=True, primary_key=True),
                      Column('site_id', Integer, ForeignKey('sites.id'), nullable=False, index=True, primary_key=True)
                      )

class Site(Base):
    __tablename__ = 'sites'

    id = Column(Integer, primary_key=True)
    name = Column(Text(length=40), unique=True)
    tagline = Column(Text(length=200), nullable=True)
    meta_description = Column(Text(length=600), nullable=True)

    header_imbo_id = Column(Text(length=80), nullable=True)

    key = Column(Text(length=32), unique=True, default=lambda: uuid.uuid4().hex)

    footer = Column(Text, nullable=True)

    pages = relationship('Page')
    aspect_ratios = relationship('SiteAspectRatio')

    def __json__(self, request):
        pages = []

        for page in self.pages_active():
            pages.append({
                'id': page.id,
                'name': page.name,
                'slug': page.slug,
            })

        return {
            'name': self.name,
            'tagline': self.tagline if self.tagline else None,
            'meta_description': self.meta_description if self.meta_description else None,
            'key': self.key,
            'pages': pages,
            'footer': {
                'text': replace_placeholders(self.footer) if self.footer else '',
            }
        }

    def api_key_generate(self):
        return SiteAPIKey.generate(self.id)

    def get_active_page(self, page_id):
        page_id = int(page_id)
        for page in self.pages_active():
            if page.id == page_id:
                return page

        return None

    def get_index_page(self):
        return Page.get_for_site_id_and_page_alias(self.id, 'index')

    def pages_active(self):
        return Page.get_published_from_site_id(self.id)

    def set_default_index_page(self, page):
        Page.remove_alias_for_site(self.id, 'index')
        page.add_alias('index')
        return True

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


class SiteAspectRatio(Base):
    __tablename__ = 'sites_aspect_ratios'
    __table_args__ = (UniqueConstraint('width', 'height', name='_sites_aspect_ratios_width_height'), )

    id = Column(Integer, primary_key=True)
    width = Column(Integer, nullable=False)
    height = Column(Integer, nullable=False)

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True)
    site = relationship('Site')


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

def replace_placeholders(text):
    return text.replace("%YEAR%", str(datetime.datetime.now().year))
