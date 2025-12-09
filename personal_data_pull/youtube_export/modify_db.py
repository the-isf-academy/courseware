import sqlite3


# with sqlite3.connect("youtube.db") as conn:

conn = sqlite3.connect("youtube.db")
cursor = conn.cursor()

# cursor.execute('''CREATE TABLE video_db (
#                     title TEXT,
#                     video_id TEXT,
#                     channelId TEXT,
#                     channelTitle TEXT,
#                     viewCount INTEGER,
#                     likeCount INTEGER,
#                     commentCount INTEGER,
#                     topicCategories TEXT
#                 )''')


# cursor.execute('''
#                ALTER TABLE video_db ADD COLUMN hiddenSubscriberCount INTEGER;
# ''')

# cursor.execute('''
#                ALTER TABLE video_db DROP COLUMN hiddenSubscriberCount;
# ''')

# cursor.execute('''
# #                DROP TABLE channel_db;
# # ''')

# cursor.execute("SELECT EXISTS (SELECT 1 FROM video_db WHERE channelId = ? and channelTitle IS NULL)", ("UC883KJNurPvauCdi_2DppXw",)) 

# channel_data_exists = cursor.fetchone()[0] 
# print(channel_data_exists)

cursor.execute("SELECT * FROM video_db WHERE video_id = ?", ("UCxZA5UZYFb7_O58Psi6Qdrg",))
row = cursor.fetchone()
column_names = [description[0] for description in cursor.description]
row_dict = dict(zip(column_names, row))
print(row_dict)


conn.commit()
conn.close()
    # print(f"Opened SQLite database with version {sqlite3.sqlite_version} successfully.")



