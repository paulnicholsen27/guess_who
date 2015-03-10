import MySQLdb as db
import os
import requests
import re
from StringIO import StringIO

from PIL import Image
from bs4 import BeautifulSoup, element
from pprint import pprint

from auth import username, password

errors = []

def get_form_params(session, url):
    page = session.get(url)
    soupped_page = BeautifulSoup(page.content)
    form_build_id = soupped_page.select('input[name="form_build_id"]')[0]['value']
    form_token = soupped_page.select('input[name="form_token"]')
    if form_token:
        return form_build_id, form_token[0].get('value')
    else:
        return form_build_id, None

def login(session, username, password):
    form_build_id = get_form_params(session, "http://gmcw.groupanizer.com")
    payload = {'name': username,
                'pass': password,
                'form_build_id': form_build_id,
                'form_id': "user_login",
                'op': 'Log in'}
    logged_in = session.post("http://gmcw.groupanizer.com/g/dashboard", data=payload)
    cookies = logged_in.cookies
    return cookies

def get_member_links(session, cookies):
    url = "http://gmcw.groupanizer.com/g/members/pictures"
    page = session.get(url, cookies=cookies)
    soup = BeautifulSoup(page.content)
    links = [a["href"] for a in  soup.find_all(href=re.compile("user"))]
    return links

def parse_member_link(session, url, cookies):
    url = "http://gmcw.groupanizer.com" + url
    print url
    page = session.get(url, cookies=cookies)
    soup = BeautifulSoup(page.content)
    name = soup.find("div", property="foaf:name").string.encode('utf-8')
    name = name.replace('"', '""').replace("'", "''") #escape quotes for sql
    email = None
    for div in soup.findAll(class_="fieldset-wrapper"):
        for c in div.children:
            # If it wasn't parsed as a tag, it may be a NavigableString
            if isinstance(c, element.NavigableString):
                # Some heuristic to identify email addresses if other non-tags exist
                if '@' in c:
                    email = c.encode('utf-8')
                    break
    picture_url = soup.find("img", typeof="foaf:Image")["src"]
    if "default_user" not in picture_url:
        response = requests.get(picture_url)
        picture = Image.open(StringIO(response.content))
    else:
        picture = None
    return name, picture, email

def create_or_open_db(db_file):
    db_is_new = True #not os.path.exists(db_file)
    con = db.connect("127.0.0.1", "root", "", "members")
    cursor = con.cursor()
    if db_is_new:
        sql = "USE members;"
        cursor.execute(sql)
        sql = "DROP TABLE IF EXISTS member_data;"
        cursor.execute(sql)
        sql = '''CREATE TABLE member_data (
            id INTEGER PRIMARY KEY AUTO_INCREMENT,
            picture BLOB,
            name TEXT,
            email TEXT,
            link TEXT);'''
        cursor.execute(sql)
    else:
        print 'Schema exists\n'

    return con

def insert_into_db(con, photo, member_name, email, link):
    try:
        sql = '''INSERT INTO member_data (picture, name, email, link) VALUES ("{}", "{}", "{}", "{}")'''.format(photo, member_name, email, link)
        con.cursor().execute(sql)
        con.commit()
    except Exception as e:
        print e
        errors.append((photo, member_name, email, link))

def main():
    db_filename = "chorus.sql"
    con = create_or_open_db(db_filename)
    cur = con.cursor()
    session = requests.session()
    cookies = login(session, username, password)
    member_links = get_member_links(session, cookies)
    for link in member_links:
        name, picture, email = parse_member_link(session, link, cookies)
        if name != "test":
            insert_into_db(con, picture, name, email, link)
    #for testing one link
    # name, picture, email = parse_member_link(session, member_links[27], cookies)
    #     insert_into_db(con, picture, name, email, link)
    sql = '''select * from member_data'''
    cur.execute(sql)
    rows = cur.fetchall()
    con.close()
    if errors: print errors

if __name__ == '__main__':
    main()