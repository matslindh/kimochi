import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(here, 'README.txt')) as f:
    README = f.read()
with open(os.path.join(here, 'CHANGES.txt')) as f:
    CHANGES = f.read()

requires = [
    'alembic',
    'bcrypt',
    'imboclient',
    'mysqlclient',
    'passlib',
    'pyramid',
    'pyramid_beaker',
    'pyramid_mako',
    'pyramid-tm',
    'SQLAlchemy',
    'sqlalchemy_utils',
    'transaction',
    'unicode-slugify',
    'zope.sqlalchemy',
    'waitress',
    ]

setup(name='kimochi',
      version='0.0',
      description='kimochi',
      long_description=README + '\n\n' + CHANGES,
      dependency_links = ['https://github.com/imbo/imboclient-python/archive/master.zip#egg=imboclient-python'],
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='',
      author_email='',
      url='',
      keywords='web wsgi bfg pylons pyramid',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      test_suite='kimochi',
      install_requires=requires,
      entry_points="""\
      [paste.app_factory]
      main = kimochi:main
      [console_scripts]
      initialize_kimochi_db = kimochi.scripts.initializedb:main
      """,      
      )
