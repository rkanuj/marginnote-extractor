import io
import json
import os
import plistlib
import re
import shutil
import sqlite3
import sys
from base64 import b64encode
from datetime import datetime
from zipfile import ZipFile

import fire
import pyperclip
from PIL import Image


def log(*args, **kwargs):
    if config['silent']:
        return

    print(*args, **kwargs)


class Config:
    def __init__(self, **kwargs):
        self.update(**kwargs)

    def __str__(self):
        return json.dumps(self.__dict__)

    def update(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

    def get(self, key, default=None):
        return getattr(self, key, default)

    def set(self, key, value):
        setattr(self, key, value)

    def remove(self, key):
        delattr(self, key)

    def __getitem__(self, key):
        return self.get(key)

    def __setitem__(self, key, value):
        self.set(key, value)


class MarginNoteDatabase:
    def __init__(self, file):
        self.conn = sqlite3.connect(file)
        self.cursor = self.conn.cursor()

    def get_note_by_id(self, note_id):
        self.cursor.execute('SELECT * from ZBOOKNOTE WHERE ZNOTEID = ?', (note_id,))
        result = self.cursor.fetchone()
        if result is None:
            return None

        columns = [description[0] for description in self.cursor.description]
        return dict(zip(columns, result))

    def get_image_by_note(self, note):
        media_list = note['ZMEDIA_LIST'].split('-')
        if len(media_list) < 2:
            return None

        md5 = media_list[1]
        self.cursor.execute('select ZDATA from ZMEDIA where ZMD5 = ?', (md5,))
        result = self.cursor.fetchone()
        if result is None:
            return None

        image_binary_data = plistlib.loads(result[0])['$objects'][1]
        if isinstance(image_binary_data, dict):
            image_binary_data = image_binary_data['NS.data']

        return compress_and_convert_image_to_base64(image_binary_data,
                                                    config['image_quality'],
                                                    config['image_resize_factor'])

    def get_topic_by_note_id(self, note_id):
        self.cursor.execute('SELECT ZMEDIA_LIST, ZTOPICID FROM ZBOOKNOTE WHERE ZNOTEID = ?', (note_id,))
        result = self.cursor.fetchone()
        if result is None:
            return None

        media_list = result[0]
        if media_list.strip() == '':
            topic_id = result[1]
        else:
            self.cursor.execute('SELECT ZTOPICID FROM ZBOOKNOTE WHERE ZMEDIA_LIST = ? and ZNOTEID != ?',
                                (media_list, note_id))
            result = self.cursor.fetchone()
            if result is None:
                return None

            topic_id = result[0]

        self.cursor.execute('SELECT ZTITLE FROM ZTOPIC WHERE ZTOPICID = ?', (topic_id,))
        result = self.cursor.fetchone()
        if result is None:
            return None

        topic_title = result[0]
        return topic_title

    def close(self):
        self.conn.close()


def clean_text(text):
    text = re.sub(r'<([^>]+)>', r'\\<\1\\>', text)
    text = re.sub(r'\r\n|\n|\t|\s+', ' ', text)
    return text


def compress_and_convert_image_to_base64(binary_data, quality, resize_factor):
    image = Image.open(io.BytesIO(binary_data))

    new_size = (int(image.width * resize_factor), int(image.height * resize_factor))
    # noinspection PyUnresolvedReferences
    image = image.resize(new_size, Image.LANCZOS)

    buffered = io.BytesIO()
    image.save(buffered, format='webp', quality=quality, method=6)
    img_str = b64encode(buffered.getvalue()).decode('utf-8')

    return f'data:image/webp;base64,{img_str}'


def get_latest_backup_db(backup_dir):
    files = os.listdir(backup_dir)

    latest_backup = None
    latest_time = None

    for file in files:
        if config['use_backup_pkg']:
            if file.endswith('.marginpkg'):
                backup_path = os.path.join(backup_dir, file)
                extract_dir = os.path.splitext(backup_path)[0]
                with ZipFile(backup_path, 'r') as zip_ref:
                    zip_ref.extractall(extract_dir)

                extracted_files = os.listdir(extract_dir)
                for extracted_file in extracted_files:
                    if not extracted_file.endswith('.marginnotes'):
                        continue

                    extracted_file_path = os.path.join(extract_dir, extracted_file)
                    new_file_path = os.path.join(backup_dir, extracted_file)
                    os.rename(extracted_file_path, new_file_path)
                    file = extracted_file
                    break

                os.remove(backup_path)
                shutil.rmtree(extract_dir)

            if not file.endswith('.marginnotes'):
                continue
        else:
            if not file.endswith('.marginbackupall'):
                continue

        datetime_str = file.split('(')[1].split(')')[0]
        datetime_obj = datetime.strptime(datetime_str, '%Y-%m-%d-%H-%M-%S')
        if latest_time is None or datetime_obj > latest_time:
            latest_backup = file
            latest_time = datetime_obj

    if latest_backup is None:
        log('No backup file found')
        sys.exit(1)

    if config['use_backup_pkg']:
        return os.path.join(backup_dir, latest_backup)
    else:
        return os.path.join(backup_dir, latest_backup, 'MarginNotes.sqlite')


def iter_notes(db, note_id, depth=0):
    note = db.get_note_by_id(note_id)
    if note is None:
        log('Note not found: ', note_id)
        return

    yield note_id, note, depth

    if note['ZMINDLINKS'] is None:
        return

    new_child_note_id_list = []
    child_note_id_list = note['ZMINDLINKS'].split('|')

    index = 0
    for child_note_id in child_note_id_list:
        note = db.get_note_by_id(child_note_id)
        if note is None:
            continue

        if note['ZHIGHLIGHTS'] is None:
            new_child_note_id_list.append(child_note_id)
        else:
            new_child_note_id_list.insert(index, child_note_id)
            index += 1

    for child_note_id in new_child_note_id_list:
        yield from iter_notes(db, child_note_id, depth + 1)


def main(root_id=None):
    if root_id is None:
        try:
            root_id = input('Please input the root ID: ').strip()
        except KeyboardInterrupt:
            log('exit')
            sys.exit(0)
        except EOFError:
            log('exit')
            sys.exit(0)

    if root_id == '':
        log('No root ID provided')
        return

    if root_id.lower() == 'exit':
        sys.exit(0)

    if root_id.startswith(config['app_url']):
        root_id = root_id[len(config['app_url']):]

    root_id = root_id.upper()

    if not re.match(r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$', root_id):
        log('Invalid root ID')
        return

    if config['use_backup']:
        latest_backup_db = get_latest_backup_db(config['backup_path'])
        log('Using latest backup Database: ', latest_backup_db)
        db = MarginNoteDatabase(latest_backup_db)
    else:
        log('Using live Database')
        db = MarginNoteDatabase(config['database_path'])

    root_note = ''
    notes = []
    image_count = 0
    no_content_count = 0

    try:
        for note_id, note, depth in iter_notes(db, root_id):
            is_chapter = False
            is_image = False

            start_page = note['ZSTARTPAGE']
            end_page = note['ZENDPAGE']
            if start_page is None or end_page is None:
                page_no = None
            elif start_page == end_page:
                page_no = f'p{start_page}'
            else:
                page_no = f'p{start_page}-{end_page}'

            if note['ZHIGHLIGHT_PIC'] is not None:
                is_image = True
                image_count += 1

                image = db.get_image_by_note(note)
                if image is None:
                    note_text = None
                else:
                    note_text = f'![]({image})'
            elif note['ZHIGHLIGHTS'] is not None:
                note_text = note['ZHIGHLIGHT_TEXT']
            else:
                note_text = note['ZNOTETITLE']
                if note_text is None:
                    note_text = note['ZHIGHLIGHT_TEXT']
                else:
                    is_chapter = True

            if note_text is None or note_text.strip() == '':
                note_text = '==**NO CONTENT**=='
                no_content_count += 1

            if not is_image:
                note_text = clean_text(note_text)

            note_comments = []
            note_link_id_list = []
            note_content = note['ZNOTES_TEXT']
            if note_content is not None and note_content.strip() != '':
                for note_comment in note_content.split('\n\n'):
                    note_comment = note_comment.strip()
                    if note_comment.startswith(config['app_url']):
                        note_link_id_list.append(note_comment[len(config['app_url']):])
                    else:
                        note_comments.append(clean_text(note_comment))

            note_link_list = []
            for link_note_id in note_link_id_list:
                topic = db.get_topic_by_note_id(link_note_id)
                if topic is None:
                    continue

                topic = topic.split('#')[0].strip()
                note_link_list.append(f'[[{topic}#^{link_note_id}|{len(note_link_list) + 1}#]]')

            notes.append(f'{' ' * 4 * depth}'
                         f'- {'[b]' if is_chapter else '["]'} '
                         f'[{note_text}]({config['app_url']}{note_id}) '
                         f'{f'{' | '.join([f'*{x}*' for x in note_comments])} ' if len(note_comments) > 0 else ''}'
                         f'{f'{' | '.join(note_link_list)} ' if len(note_link_list) > 0 else ''}'
                         f'{f'`{page_no}` ' if page_no is not None else ''}'
                         f'^{note_id}')

            if root_note == '':
                if is_image:
                    root_note = 'Image'
                else:
                    root_note = note_text
    finally:
        db.close()

    if len(notes) > 0:
        text = '\n'.join(notes)
        if config['use_clipboard']:
            pyperclip.copy(text)
        else:
            log()
            print(text)

        if config['use_clipboard']:
            log(f'Outline of "{root_note}" copied to clipboard:')
        else:
            log(f'\nSummary:')

        log(f'- Characters: {len(text)}\n'
            f'- Notes: {len(notes)}\n'
            f'- Images: {image_count}\n'
            f'- No content: {no_content_count}')
    else:
        log('No notes found')


def loop_main(root_id=None,
              silent=False,
              use_clipboard=True,
              use_backup=False,
              use_backup_pkg=False,
              backup_path=os.path.expanduser('~/Downloads/MarginNoteBackup'),
              image_quality=25,
              image_resize_factor=0.5):
    config['silent'] = silent
    config['use_clipboard'] = use_clipboard
    config['use_backup'] = use_backup
    config['use_backup_pkg'] = use_backup_pkg
    config['backup_path'] = backup_path
    config['image_quality'] = image_quality
    config['image_resize_factor'] = image_resize_factor

    try:
        if root_id is not None:
            main(str(root_id))
        else:
            while True:
                main()
    except KeyboardInterrupt:
        log('exit')


config = Config()
config['app_url'] = 'marginnote4app://note/'
config['database_path'] = os.path.expanduser('~/Library/Containers/QReader.MarginStudy.easy'
                                             '/Data/Library/Private Documents/MN4NotebookDatabase/0'
                                             '/MarginNotes.sqlite')

if __name__ == '__main__':
    fire.Fire(loop_main, name='MarginNoteExtractor')
