import urllib.parse
class BaseConfig(object):

    # 数据库的配置
    DIALECT = "mysql"
    DRIVER = "pymysql"
    HOST = '127.0.0.1'
    PORT = 3306
    USERNAME = "agent"
    PASSWORD = "123456" # 你自己电脑数据库的密码
    DBNAME = 'zhangsan'

    ENCODED_PASSWORD = urllib.parse.quote_plus(PASSWORD)

    REDIS_HOST = '127.0.0.1'
    REDIS_PORT = 6379

    SQLALCHEMY_DATABASE_URI = f"{DIALECT}+{DRIVER}://{USERNAME}:{ENCODED_PASSWORD}@{HOST}:{PORT}/{DBNAME}?charset=utf8mb4"
    SQLALCHEMY_TRACK_MODIFICATIONS = True

# # 密钥，可随意修改
# SECRET_KEY = '你猜'