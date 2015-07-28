from sqlalchemy import (
    Boolean,
    Column,
    ForeignKey,
    Index,
    Integer,
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

from zope.sqlalchemy import ZopeTransactionExtension

import calendar
import time

def epoch():
    return calendar.timegm(time.gmtime())

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class Site(Base):
    __tablename__ = 'sites'

    id = Column(Integer, primary_key=True)
    name = Column(Text(length=40), unique=True)
    key = Column(Text(length=16), unique=True)

    pages = relationship('Page')

    @classmethod
    def get_from_key(cls, key):
        return DBSession.query(cls).filter(cls.key == key).first()

    def get_pages_active(self):
        return Page.get_active_from_site_id(self.id)

class Page(Base):
    __tablename__ = 'pages'

    id = Column(Integer, primary_key=True)
    type = Column(Text(length=30))

    name = Column(Text(length=40))
    content = Column(Text(length=65536))

    deleted = Column(Boolean, default=False)

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True)
    site = relationship('Site')

    @classmethod
    def get_active_from_site_id(cls, site_id):
        return DBSession.query(cls).filter(cls.site_id == site_id, cls.deleted == False).all()

    def get_sections_active(self):
        return PageSection.get_active_from_page_id(self.id)

class PageSection(Base):
    __tablename__ = 'pages_sections'

    id = Column(Integer, primary_key=True)
    type = Column(Text(length=30))
    order = Column(Integer, default=epoch)

    deleted = Column(Boolean, default=False)

    page_id = Column(Integer, ForeignKey('pages.id'), nullable=False, index=True)
    page = relationship('Page')

    @classmethod
    def get_active_from_page_id(cls, page_id):
        return DBSession.query(cls).filter(cls.page_id == page_id, cls.deleted == False).order_by('order').all()


class Image(Base):
    __tablename__ = 'images'

    id = Column(Integer, primary_key=True)
    imbo_id = Column(Text(length=80))
    order = Column(Integer, default=epoch)

    deleted = Column(Boolean, default=False)

    page_id = Column(Integer, ForeignKey('pages.id'), nullable=False, index=True)
    page = relationship('Page')

    page_section_id = Column(Integer, ForeignKey('pages_sections.id'), nullable=False, index=True)
    page_section = relationship('PageSection')

    @classmethod
    def get_active_from_page_id(cls, page_id):
        return DBSession.query(cls).filter(cls.page_id == page_id, cls.deleted == False).order_by('order').all()

    @classmethod
    def get_active_from_page_section_id(cls, page_section_id):
        return DBSession.query(cls).filter(cls.page_section_id == page_section_id, cls.deleted == False).order_by('order').all()

    @classmethod
    def get_active_from_page_id_by_page_section_id(cls, page_id):
        images = cls.get_active_from_page_id(page_id)
        by_section_id = {}

        for image in images:
            if image.page_section_id not in by_section_id:
                by_section_id[image.page_section_id] = []

            by_section_id[image.page_section_id].append(image)

        return by_section_id

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)

    email = Column(Text(length=80), unique=True)
    password = Column(PasswordType)

    deleted = Column(Boolean, default=False)

    sites = relationship("Site", secondary="users_sites", backref="users")

class UserSite(Base):
    __tablename__ = 'users_sites'

    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True, primary_key=True)
    user = relationship('User')

    site_id = Column(Integer, ForeignKey('sites.id'), nullable=False, index=True, primary_key=True)
    site = relationship('Site')